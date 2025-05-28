import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class DataFetcher {
  final List<DataSource> dataSources;
  final Duration cacheDuration;

  DataFetcher({
    required this.dataSources,
    this.cacheDuration = const Duration(days: 1),
  });

  Future<void> fetchAndOrganize(Session session) async {
    // Setup Generative AI.
    // final genAi = GenerativeAi();

    // Start fetching data.
    print('FETCH DATA');
    for (var dataSource in dataSources) {
      await for (final rawDocument in dataSource.fetch(this)) {
        print('RAW DOCUMENT: ${rawDocument.sourceUrl}');
        // Process the document.
      }
    }
    print('FETCH DONE');
  }

  Future<bool> shouldFetchUrl(Session session, Uri sourceUrl) async {
    // Check if the url is already in the database.
    final document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.sourceUrl.equals(sourceUrl) &
          (t.fetchTime > (DateTime.now().subtract(cacheDuration))),
    );
    return document == null;
  }
}
