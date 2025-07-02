class DataSourceException implements Exception {
  final String message;
  final int? statusCode;

  DataSourceException(this.message, {this.statusCode});

  @override
  String toString() {
    final buffer = StringBuffer('DataSourceException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    return buffer.toString();
  }
}
