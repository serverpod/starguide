/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import '../rag_document_type.dart' as _i23831eq;

/// A RAG document without its content and embedding, for listing.
abstract class AdminDocumentSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminDocumentSummary._({
    required this.id,
    required this.title,
    required this.sourceUrl,
    required this.type,
    required this.domain,
    required this.fetchTime,
    required this.shortDescription,
    required this.contentLength,
  });

  factory AdminDocumentSummary({
    required int id,
    required String title,
    required Uri sourceUrl,
    required _i23831eq.RAGDocumentType type,
    required String domain,
    required DateTime fetchTime,
    required String shortDescription,
    required int contentLength,
  }) = _AdminDocumentSummaryImpl;

  factory AdminDocumentSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminDocumentSummary(
      id: jsonSerialization['id'] as int,
      title: jsonSerialization['title'] as String,
      sourceUrl: _is.UriJsonExtension.fromJson(jsonSerialization['sourceUrl']),
      type: _i23831eq.RAGDocumentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      domain: jsonSerialization['domain'] as String,
      fetchTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchTime'],
      ),
      shortDescription: jsonSerialization['shortDescription'] as String,
      contentLength: jsonSerialization['contentLength'] as int,
    );
  }

  int id;

  String title;

  Uri sourceUrl;

  _i23831eq.RAGDocumentType type;

  String domain;

  DateTime fetchTime;

  String shortDescription;

  int contentLength;

  /// Returns a shallow copy of this [AdminDocumentSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminDocumentSummary copyWith({
    int? id,
    String? title,
    Uri? sourceUrl,
    _i23831eq.RAGDocumentType? type,
    String? domain,
    DateTime? fetchTime,
    String? shortDescription,
    int? contentLength,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDocumentSummary',
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl.toJson(),
      'type': type.toJson(),
      'domain': domain,
      'fetchTime': fetchTime.toJson(),
      'shortDescription': shortDescription,
      'contentLength': contentLength,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDocumentSummary',
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl.toJson(),
      'type': type.toJson(),
      'domain': domain,
      'fetchTime': fetchTime.toJson(),
      'shortDescription': shortDescription,
      'contentLength': contentLength,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AdminDocumentSummaryImpl extends AdminDocumentSummary {
  _AdminDocumentSummaryImpl({
    required int id,
    required String title,
    required Uri sourceUrl,
    required _i23831eq.RAGDocumentType type,
    required String domain,
    required DateTime fetchTime,
    required String shortDescription,
    required int contentLength,
  }) : super._(
         id: id,
         title: title,
         sourceUrl: sourceUrl,
         type: type,
         domain: domain,
         fetchTime: fetchTime,
         shortDescription: shortDescription,
         contentLength: contentLength,
       );

  /// Returns a shallow copy of this [AdminDocumentSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminDocumentSummary copyWith({
    int? id,
    String? title,
    Uri? sourceUrl,
    _i23831eq.RAGDocumentType? type,
    String? domain,
    DateTime? fetchTime,
    String? shortDescription,
    int? contentLength,
  }) {
    return AdminDocumentSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      type: type ?? this.type,
      domain: domain ?? this.domain,
      fetchTime: fetchTime ?? this.fetchTime,
      shortDescription: shortDescription ?? this.shortDescription,
      contentLength: contentLength ?? this.contentLength,
    );
  }
}
