import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/generated/protocol.dart';

abstract class DataSource {
  Stream<RawRAGDocument> fetch(Session session, DataFetcher fetcher);

  /// Unique name of the data source, used to schedule its fetching.
  String get name;

  /// The domain of the documents produced by this source, e.g. the product
  /// they document. Together with [documentType] it identifies the source's
  /// documents in the database.
  String get domain;

  /// The type of the documents produced by this source.
  RAGDocumentType get documentType;

  /// What the domain is, in a sentence. It describes the domain to the model
  /// that picks the pages to answer a question from.
  String get description;
}

enum DataSourceType { html, markdown, text }

class RawRAGDocument {
  final Uri sourceUrl;
  final String document;
  final String title;
  final DataSourceType dataSourceType;
  final RAGDocumentType documentType;
  final String domain;

  RawRAGDocument({
    required this.sourceUrl,
    required this.document,
    required this.title,
    required this.dataSourceType,
    required this.documentType,
    required this.domain,
  });
}
