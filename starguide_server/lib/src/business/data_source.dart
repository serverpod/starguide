import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';

abstract class DataSource {
  Stream<RawRAGDocuement> fetch(Session session, DataFetcher fetcher);
}

enum DataSourceType {
  html,
  markdown,
  text,
}

class RawRAGDocuement {
  final Uri sourceUrl;
  final String document;
  final DataSourceType type;

  RawRAGDocuement({
    required this.sourceUrl,
    required this.document,
    required this.type,
  });
}
