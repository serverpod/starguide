abstract class DataSource {
  Stream<RawRAGDocuement> fetch();
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
