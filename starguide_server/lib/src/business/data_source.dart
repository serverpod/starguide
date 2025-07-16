import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/generated/protocol.dart';

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
  final String title;
  final DataSourceType dataSourceType;
  final RAGDocumentType documentType;

  RawRAGDocument({
    required this.sourceUrl,
    required this.document,
    required this.title,
    required this.dataSourceType,
    required this.documentType,
  });
}
