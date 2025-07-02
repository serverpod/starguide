import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';

abstract class DataSource {
  Stream<RawRAGDocument> fetch(Session session, DataFetcher fetcher);

  String get name;
}

enum DataSourceType {
  html,
  markdown,
  text,
}

class RawRAGDocument {
  final Uri sourceUrl;
  final String document;
  final DataSourceType type;

  RawRAGDocument({
    required this.sourceUrl,
    required this.document,
    required this.type,
  });
}
