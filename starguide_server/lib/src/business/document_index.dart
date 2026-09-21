import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// Builds and caches the [DocumentIndex]: the table of contents of the
/// documentation and website pages, in the form Jev picks pages from.
///
/// Documents of the types in [includedTypes] are listed in the index, grouped
/// by data source. Each group becomes one choice question, with every page as
/// an option labelled by its URL path. Documents of other types are found by
/// embedding search instead.
class DocumentIndexCache {
  /// The document types listed in the index.
  static const includedTypes = {
    RAGDocumentType.documentation,
    RAGDocumentType.site,
  };

  /// The most options Jev accepts in one choice question. A group with more
  /// pages, counting the [noneLabel] option, is split into numbered chunks.
  static const maxOptionsPerQuestion = 255;

  /// The option that means no page of the group answers the question. It is
  /// added to every question and is never a page's label.
  static const noneLabel = 'none';

  /// The description of the [noneLabel] option of a page question.
  static const nonePageDescription =
      'No page in this list answers the question';

  /// The description of the [noneLabel] option of the domain question.
  static const noneDomainDescription = 'The question is not about any of these';

  /// How long a built index is cached. It is also invalidated whenever a
  /// listed document is stored.
  static const lifetime = Duration(hours: 1);

  static const int _batchSize = 100;
  static const String _cacheKey = 'document_index';

  /// The documents listed in the cached index, keyed by id, with the
  /// generation time of that index. They are kept outside the local cache,
  /// which serializes on every read, so that picked pages need neither a
  /// database query nor decoding.
  static ({DateTime generatedAt, Map<int, RAGDocument> byId})? _documents;

  /// Returns the cached index, building it from the database on a miss.
  static Future<DocumentIndex> get(Session session) async {
    final index = await session.caches.local.get<DocumentIndex>(
      _cacheKey,
      CacheMissHandler(() => build(session), lifetime: lifetime),
    );
    return index!;
  }

  /// Drops the cached index, so that the next [get] rebuilds it.
  static Future<void> invalidate(Session session) async {
    _documents = null;
    await session.caches.local.invalidateKey(_cacheKey);
  }

  /// The listed documents with [ids], keyed by id. They come from memory if
  /// they were loaded when [index] was built, and from the database
  /// otherwise. Documents that no longer exist are left out.
  static Future<Map<int, RAGDocument>> findDocuments(
    Session session,
    DocumentIndex index,
    Set<int> ids,
  ) async {
    final cached = _documents;
    if (cached != null &&
        cached.generatedAt.isAtSameMomentAs(index.generatedAt)) {
      final byId = <int, RAGDocument>{};
      for (final id in ids) {
        final document = cached.byId[id];
        if (document != null) byId[id] = document;
      }
      return byId;
    }

    final found = await RAGDocument.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );
    return {for (final document in found) document.id!: document};
  }

  /// Builds the index from all documents of the [includedTypes] in the
  /// database.
  static Future<DocumentIndex> build(Session session) async {
    final documents = <RAGDocument>[];
    var lastDocumentId = 0;
    while (true) {
      final batch = await RAGDocument.db.find(
        session,
        where: (d) => (d.id > lastDocumentId) & d.type.inSet(includedTypes),
        limit: _batchSize,
        orderBy: (d) => d.id,
      );
      if (batch.isEmpty) break;
      lastDocumentId = batch.last.id!;
      documents.addAll(batch);
    }

    final index = fromDocuments(documents, descriptions: _domainDescriptions());
    _documents = (
      generatedAt: index.generatedAt,
      byId: {for (final document in documents) document.id!: document},
    );
    session.log(
      'Built document index with ${index.groups.length} groups and '
      '${documents.length} documents.',
      level: LogLevel.debug,
    );
    return index;
  }

  /// Builds the index from [documents], grouped by domain and type in the
  /// order they first appear. [descriptions] gives the description of each
  /// domain and type, from the configured data sources.
  static DocumentIndex fromDocuments(
    List<RAGDocument> documents, {
    Map<(String, RAGDocumentType), String> descriptions = const {},
    DateTime? generatedAt,
  }) {
    final grouped = <(String, RAGDocumentType), List<RAGDocument>>{};
    for (final document in documents) {
      grouped
          .putIfAbsent((document.domain, document.type), () => [])
          .add(document);
    }

    final groups = <DocumentIndexGroup>[];
    for (final entry in grouped.entries) {
      final (domain, type) = entry.key;
      final description = descriptions[entry.key] ?? '';
      final entries = _entries(entry.value);

      // Split the group into chunks that fit in one question, leaving room
      // for the none option.
      final chunkSize = maxOptionsPerQuestion - 1;
      final chunkCount = (entries.length / chunkSize).ceil();
      for (var chunk = 0; chunk < chunkCount; chunk++) {
        final chunkEntries = entries.sublist(
          chunk * chunkSize,
          ((chunk + 1) * chunkSize).clamp(0, entries.length),
        );
        final group = DocumentIndexGroup(
          name: chunkCount == 1 ? domain : '$domain ${chunk + 1}',
          domain: domain,
          description: description,
          type: type,
          entries: chunkEntries,
          sizeInBytes: 0,
        );
        groups.add(group.copyWith(sizeInBytes: _utf8Length(group.criteria)));
      }
    }

    return DocumentIndex(
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      groups: groups,
    );
  }

  /// The entries of one group, labelled by their URL paths relative to the
  /// path all of them share, sorted by label.
  static List<DocumentIndexEntry> _entries(List<RAGDocument> documents) {
    final paths = [for (final d in documents) _cleanPath(d.sourceUrl)];
    final prefix = _commonDirectory(paths);

    final labels = <String>{noneLabel};
    final entries = <DocumentIndexEntry>[];
    for (var i = 0; i < documents.length; i++) {
      final document = documents[i];
      var label = paths[i].substring(prefix.length);
      if (label.isEmpty) label = document.sourceUrl.host;

      // Labels are unique within a group, as they identify the picked page.
      // A clash is resolved with the host, then with a number.
      var unique = label;
      if (labels.contains(unique)) {
        label = '${document.sourceUrl.host}/$label';
        unique = label;
      }
      var suffix = 2;
      while (!labels.add(unique)) {
        unique = '$label-${suffix++}';
      }

      final description = _describe(document);
      entries.add(
        DocumentIndexEntry(
          documentId: document.id!,
          label: unique,
          title: document.title,
          description: description,
          sourceUrl: document.sourceUrl,
          sizeInBytes: _utf8Length({unique: description}) - 2,
        ),
      );
    }
    entries.sort((a, b) => a.label.compareTo(b.label));
    return entries;
  }

  /// The description of a page as an option: its title and summary.
  static String _describe(RAGDocument document) {
    final summary = document.shortDescription.trim();
    return summary.isEmpty ? document.title : '${document.title}: $summary';
  }

  /// The path of [url] without leading or trailing slashes, or its host if
  /// it has no path.
  static String _cleanPath(Uri url) {
    final segments = url.pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.join('/');
  }

  /// The longest directory prefix, ending in a slash, that all [paths]
  /// share. Empty if there is none, or if only one path is given, as its
  /// whole path is then the most useful label.
  static String _commonDirectory(List<String> paths) {
    if (paths.length < 2) return '';
    var prefix = paths.first;
    for (final path in paths.skip(1)) {
      var length = 0;
      while (length < prefix.length &&
          length < path.length &&
          prefix[length] == path[length]) {
        length++;
      }
      prefix = prefix.substring(0, length);
      if (prefix.isEmpty) return '';
    }
    final slash = prefix.lastIndexOf('/');
    return slash < 0 ? '' : prefix.substring(0, slash + 1);
  }

  /// The descriptions of the configured data sources, keyed by domain and
  /// type. Empty if the data fetcher is not configured, as in tests.
  static Map<(String, RAGDocumentType), String> _domainDescriptions() {
    if (!DataFetcher.isConfigured) return const {};
    return {
      for (final source in DataFetcher.instance.dataSources)
        (source.domain, source.documentType): source.description,
    };
  }

  static int _utf8Length(Object value) => utf8.encode(jsonEncode(value)).length;
}

extension DocumentIndexQuestions on DocumentIndex {
  /// The options of the domain question: every domain of the index with its
  /// description, and a none option.
  Map<String, Object?> get domainCriteria {
    final criteria = <String, Object?>{};
    for (final group in groups) {
      criteria.putIfAbsent(
        group.domain,
        () => group.description.isEmpty ? null : group.description,
      );
    }
    criteria[DocumentIndexCache.noneLabel] =
        DocumentIndexCache.noneDomainDescription;
    return criteria;
  }

  /// The total number of pages in the index.
  int get entryCount => groups.fold(0, (sum, g) => sum + g.entries.length);

  /// The total size of all questions' options, in bytes.
  int get sizeInBytes => groups.fold(0, (sum, g) => sum + g.sizeInBytes);

  /// The entry of a group's option, or null for the none option.
  DocumentIndexEntry? entryFor(DocumentIndexGroup group, String label) {
    for (final entry in group.entries) {
      if (entry.label == label) return entry;
    }
    return null;
  }
}

extension DocumentIndexGroupQuestions on DocumentIndexGroup {
  /// The options of the group's page question: every page with its
  /// description, and a none option.
  Map<String, Object?> get criteria => {
    for (final entry in entries) entry.label: entry.description,
    DocumentIndexCache.noneLabel: DocumentIndexCache.nonePageDescription,
  };
}
