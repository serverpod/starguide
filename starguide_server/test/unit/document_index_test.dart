import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/document_index.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:test/test.dart';

RAGDocument _document(
  int id,
  String url, {
  String domain = 'Serverpod framework',
  RAGDocumentType type = RAGDocumentType.documentation,
  String title = 'Title',
  String description = 'Description',
}) {
  return RAGDocument(
    id: id,
    embedding: Vector(const [0, 0]),
    fetchTime: DateTime.utc(2026, 9, 21),
    sourceUrl: Uri.parse(url),
    content: 'Content',
    title: title,
    embeddingSummary: 'Summary',
    shortDescription: description,
    type: type,
    domain: domain,
  );
}

void main() {
  group('Given documents of several sources', () {
    final documents = [
      _document(1, 'https://docs.serverpod.dev/concepts/database/relations'),
      _document(2, 'https://docs.serverpod.dev/get-started'),
      _document(
        3,
        'https://docs.serverpod.dev/cloud/deploy',
        domain: 'Serverpod Cloud',
      ),
      _document(
        4,
        'https://serverpod.dev/feature/orm',
        domain: 'Serverpod',
        type: RAGDocumentType.site,
      ),
      _document(
        5,
        'https://docs.serverpod.dev/cloud/secrets',
        domain: 'Serverpod Cloud',
      ),
    ];
    final index = DocumentIndexCache.fromDocuments(
      documents,
      descriptions: {
        ('Serverpod Cloud', RAGDocumentType.documentation): 'Hosting',
      },
    );

    test('then the documents are grouped by domain and type', () {
      expect(index.groups.map((g) => g.name), [
        'Serverpod framework',
        'Serverpod Cloud',
        'Serverpod',
      ]);
      expect(index.groups[1].type, RAGDocumentType.documentation);
      expect(index.groups[2].type, RAGDocumentType.site);
      expect(index.entryCount, 5);
    });

    test('then labels are the paths without the shared directory', () {
      expect(index.groups[0].entries.map((e) => e.label), [
        'concepts/database/relations',
        'get-started',
      ]);
      expect(index.groups[1].entries.map((e) => e.label), [
        'deploy',
        'secrets',
      ]);
      expect(index.groups[2].entries.single.label, 'feature/orm');
    });

    test('then options describe every page and a none option', () {
      final criteria = index.groups[1].criteria;
      expect(criteria.keys, ['deploy', 'secrets', 'none']);
      expect(criteria['deploy'], 'Title: Description');
      expect(criteria['none'], DocumentIndexCache.nonePageDescription);
    });

    test('then the domain question lists every domain once', () {
      expect(index.domainCriteria, {
        'Serverpod framework': null,
        'Serverpod Cloud': 'Hosting',
        'Serverpod': null,
        'none': DocumentIndexCache.noneDomainDescription,
      });
    });

    test('then entries map back to their documents', () {
      final group = index.groups[1];
      expect(index.entryFor(group, 'secrets')?.documentId, 5);
      expect(index.entryFor(group, 'none'), isNull);
      expect(index.entryFor(group, 'missing'), isNull);
    });

    test('then sizes are those of the options as JSON', () {
      final group = index.groups[1];
      expect(
        group.sizeInBytes,
        '{"deploy":"Title: Description","secrets":"Title: Description","none":"${DocumentIndexCache.nonePageDescription}"}'
            .length,
      );
      expect(
        group.entries.first.sizeInBytes,
        '"deploy":"Title: Description"'.length,
      );
      expect(
        index.sizeInBytes,
        index.groups.fold(0, (sum, g) => sum + g.sizeInBytes),
      );
    });
  });

  test('Given a page without a summary then its option is the title', () {
    final index = DocumentIndexCache.fromDocuments([
      _document(1, 'https://docs.serverpod.dev/a', description: '  '),
    ]);
    expect(index.groups.single.criteria['a'], 'Title');
  });

  test('Given pages with the same path then their labels are made unique', () {
    final index = DocumentIndexCache.fromDocuments([
      _document(1, 'https://a.example.com/docs/none'),
      _document(2, 'https://b.example.com/docs/none'),
      _document(3, 'https://c.example.com/docs/none'),
    ]);
    expect(index.groups.single.entries.map((e) => e.label), [
      'a.example.com/none',
      'b.example.com/none',
      'c.example.com/none',
    ]);
  });

  test(
    'Given a page whose label would be the none option then it is renamed',
    () {
      final index = DocumentIndexCache.fromDocuments([
        _document(1, 'https://docs.serverpod.dev/x/none'),
        _document(2, 'https://docs.serverpod.dev/x/other'),
      ]);
      expect(index.groups.single.entries.map((e) => e.label), [
        'docs.serverpod.dev/none',
        'other',
      ]);
      expect(
        index
            .entryFor(index.groups.single, 'docs.serverpod.dev/none')
            ?.documentId,
        1,
      );
    },
  );

  test('Given more pages than fit in a question then the group is split', () {
    final count = DocumentIndexCache.maxOptionsPerQuestion + 10;
    final index = DocumentIndexCache.fromDocuments([
      for (var i = 0; i < count; i++)
        _document(
          i + 1,
          'https://docs.serverpod.dev/page-${i.toString().padLeft(3, '0')}',
        ),
    ]);
    expect(index.groups.map((g) => g.name), [
      'Serverpod framework 1',
      'Serverpod framework 2',
    ]);
    for (final group in index.groups) {
      expect(group.domain, 'Serverpod framework');
      expect(
        group.criteria.length,
        lessThanOrEqualTo(DocumentIndexCache.maxOptionsPerQuestion),
      );
    }
    expect(index.entryCount, count);
    expect(index.domainCriteria.keys, ['Serverpod framework', 'none']);
  });
}
