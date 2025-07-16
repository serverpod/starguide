import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

const _futureCallName = 'DataFetcher';
const _futureCallIdentifier = 'DataFetcher';

const _fetchRetryDelay = Duration(minutes: 1);

class DataFetcher {
  static DataFetcher? _instance;

  final List<DataSource> dataSources;
  final Duration cacheDuration;
  final Duration removeOldDataAfter;

  static void configure(
    List<DataSource> dataSources, {
    Duration cacheDuration = const Duration(days: 1),
    Duration removeOldDataAfter = const Duration(days: 3),
  }) {
    _instance ??= DataFetcher._(
      dataSources: dataSources,
      cacheDuration: cacheDuration,
      removeOldDataAfter: removeOldDataAfter,
    );
  }

  static DataFetcher get instance => _instance!;

  DataFetcher._({
    required this.dataSources,
    this.cacheDuration = const Duration(days: 1),
    this.removeOldDataAfter = const Duration(days: 3),
  });

  void register(Serverpod pod) {
    pod.registerFutureCall(_FetchDataFutureCall(), _futureCallName);
  }

  Future<void> startFetching(Serverpod pod) async {
    // Cancel any existing future calls, to avoid duplicates.
    await pod.cancelFutureCall(_futureCallIdentifier);

    // Kick off the data fetcher.
    pod.futureCallWithDelay(
      _futureCallName,
      DataFetcherTask(
        type: DataFetcherTaskType.startFetching,
      ),
      const Duration(),
      identifier: _futureCallIdentifier,
    );
  }

  Future<void> _fetchDataSource(Session session, DataSource dataSource) async {
    await for (final rawDocument in dataSource.fetch(session, this)) {
      session.log('Loaded document: ${rawDocument.sourceUrl}');

      final ragDocument = await _createRagDocument(session, rawDocument);
      await _saveRagDocument(session, ragDocument);

      // Pause as to not exhuast Gemini's quota
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<RAGDocument> _createRagDocument(
    Session session,
    RawRAGDocument rawDocument,
  ) async {
    final genAi = GenerativeAi();

    session.log('Summarizing document for description.');
    final shortDescription = await genAi.generateSimpleAnswer(
      Prompts.instance.get('summarize_document_for_description')! +
          rawDocument.document,
    );

    session.log('Summarizing document for embedding.');
    final embeddingSummary = await genAi.generateSimpleAnswer(
      Prompts.instance.get('summarize_document_for_embedding')! +
          rawDocument.document,
    );

    session.log('Generating embedding for summary.');
    final embedding = await genAi.generateEmbedding(embeddingSummary);

    session.log('Embeddings generated.');

    return RAGDocument(
      title: rawDocument.title,
      sourceUrl: rawDocument.sourceUrl,
      fetchTime: DateTime.now(),
      content: rawDocument.document,
      embeddingSummary: embeddingSummary,
      shortDescription: shortDescription,
      embedding: embedding,
      type: rawDocument.documentType,
    );
  }

  Future<void> _saveRagDocument(
    Session session,
    RAGDocument ragDocument,
  ) async {
    session.log('Saving rag document: ${ragDocument.sourceUrl}');

    final existingDocument = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(ragDocument.sourceUrl),
    );

    if (existingDocument == null) {
      await RAGDocument.db.insertRow(session, ragDocument);
    } else {
      ragDocument.id = existingDocument.id;
      await RAGDocument.db.updateRow(
        session,
        ragDocument,
      );
    }
  }

  Future<bool> shouldFetchUrl(Session session, Uri sourceUrl) async {
    session.log('Checking if should fetch url: $sourceUrl');

    // Check if the url is already in the database.
    final document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.sourceUrl.equals(sourceUrl) &
          (t.fetchTime > (DateTime.now().subtract(cacheDuration))),
    );
    return document == null;
  }

  Future<void> _cleanUp(Session session) async {
    await RAGDocument.db.deleteWhere(
      session,
      where: (t) => t.fetchTime < DateTime.now().subtract(removeOldDataAfter),
    );
  }
}

class _FetchDataFutureCall extends FutureCall<DataFetcherTask> {
  @override
  Future<void> invoke(Session session, DataFetcherTask? task) async {
    final dataFetcher = DataFetcher.instance;
    task!;

    if (task.type == DataFetcherTaskType.startFetching) {
      // Spawn tasks for each data source.
      session.log('Starting data fetcher.');

      for (var dataSource in dataFetcher.dataSources) {
        session.serverpod.futureCallWithDelay(
          _futureCallName,
          DataFetcherTask(
            type: DataFetcherTaskType.dataSource,
            name: dataSource.name,
          ),
          const Duration(),
          identifier: _futureCallIdentifier,
        );
      }

      // Schedule cleanup.
      session.serverpod.futureCallWithDelay(
        _futureCallName,
        DataFetcherTask(
          type: DataFetcherTaskType.cleanUp,
        ),
        const Duration(),
        identifier: _futureCallIdentifier,
      );
    } else if (task.type == DataFetcherTaskType.dataSource) {
      // Fetch data from a specific data source.
      session.log('Fetching data from ${task.name}.');

      bool success = false;

      final dataSource = dataFetcher.dataSources.firstWhere(
        (dataSource) => dataSource.name == task.name,
      );
      try {
        await dataFetcher._fetchDataSource(session, dataSource);
        success = true;
      } catch (e, stackTrace) {
        session.log(
          'Error fetching data from $dataSource: $e',
          exception: e,
          stackTrace: stackTrace,
        );
        success = false;
      }

      if (success) {
        // We successfully fetched data, so we'll schedule the next fetch.
        session.serverpod.futureCallWithDelay(
          _futureCallName,
          DataFetcherTask(
            type: DataFetcherTaskType.dataSource,
            name: dataSource.name,
          ),
          dataFetcher.cacheDuration,
          identifier: _futureCallIdentifier,
        );
      } else {
        // We failed to fetch data, so we'll try again in a minute.
        session.serverpod.futureCallWithDelay(
          _futureCallName,
          DataFetcherTask(
            type: DataFetcherTaskType.dataSource,
            name: dataSource.name,
          ),
          _fetchRetryDelay,
          identifier: _futureCallIdentifier,
        );
      }
    } else if (task.type == DataFetcherTaskType.cleanUp) {
      // Remove old data.
      session.log('Cleaning up data.');
      bool success = false;
      try {
        await dataFetcher._cleanUp(session);
        success = true;
      } catch (e, stackTrace) {
        session.log(
          'Error cleaning up data: $e',
          exception: e,
          stackTrace: stackTrace,
        );
        success = false;
      }

      if (success) {
        session.serverpod.futureCallWithDelay(
          _futureCallName,
          DataFetcherTask(type: DataFetcherTaskType.cleanUp),
          dataFetcher.cacheDuration,
          identifier: _futureCallIdentifier,
        );
      } else {
        session.serverpod.futureCallWithDelay(
          _futureCallName,
          DataFetcherTask(type: DataFetcherTaskType.cleanUp),
          _fetchRetryDelay,
          identifier: _futureCallIdentifier,
        );
      }
    }
  }
}
