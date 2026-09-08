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

/// A RAG document with its content, but without the embedding vector.
abstract class AdminDocumentDetail
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminDocumentDetail._({
    required this.id,
    required this.title,
    required this.sourceUrl,
    required this.type,
    required this.domain,
    required this.fetchTime,
    required this.shortDescription,
    required this.embeddingSummary,
    required this.content,
  });

  factory AdminDocumentDetail({
    required int id,
    required String title,
    required Uri sourceUrl,
    required _i23831eq.RAGDocumentType type,
    required String domain,
    required DateTime fetchTime,
    required String shortDescription,
    required String embeddingSummary,
    required String content,
  }) = _AdminDocumentDetailImpl;

  factory AdminDocumentDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminDocumentDetail(
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
      embeddingSummary: jsonSerialization['embeddingSummary'] as String,
      content: jsonSerialization['content'] as String,
    );
  }

  int id;

  String title;

  Uri sourceUrl;

  _i23831eq.RAGDocumentType type;

  String domain;

  DateTime fetchTime;

  String shortDescription;

  String embeddingSummary;

  String content;

  /// Returns a shallow copy of this [AdminDocumentDetail]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminDocumentDetail copyWith({
    int? id,
    String? title,
    Uri? sourceUrl,
    _i23831eq.RAGDocumentType? type,
    String? domain,
    DateTime? fetchTime,
    String? shortDescription,
    String? embeddingSummary,
    String? content,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDocumentDetail',
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl.toJson(),
      'type': type.toJson(),
      'domain': domain,
      'fetchTime': fetchTime.toJson(),
      'shortDescription': shortDescription,
      'embeddingSummary': embeddingSummary,
      'content': content,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDocumentDetail',
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl.toJson(),
      'type': type.toJson(),
      'domain': domain,
      'fetchTime': fetchTime.toJson(),
      'shortDescription': shortDescription,
      'embeddingSummary': embeddingSummary,
      'content': content,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AdminDocumentDetailImpl extends AdminDocumentDetail {
  _AdminDocumentDetailImpl({
    required int id,
    required String title,
    required Uri sourceUrl,
    required _i23831eq.RAGDocumentType type,
    required String domain,
    required DateTime fetchTime,
    required String shortDescription,
    required String embeddingSummary,
    required String content,
  }) : super._(
         id: id,
         title: title,
         sourceUrl: sourceUrl,
         type: type,
         domain: domain,
         fetchTime: fetchTime,
         shortDescription: shortDescription,
         embeddingSummary: embeddingSummary,
         content: content,
       );

  /// Returns a shallow copy of this [AdminDocumentDetail]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminDocumentDetail copyWith({
    int? id,
    String? title,
    Uri? sourceUrl,
    _i23831eq.RAGDocumentType? type,
    String? domain,
    DateTime? fetchTime,
    String? shortDescription,
    String? embeddingSummary,
    String? content,
  }) {
    return AdminDocumentDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      type: type ?? this.type,
      domain: domain ?? this.domain,
      fetchTime: fetchTime ?? this.fetchTime,
      shortDescription: shortDescription ?? this.shortDescription,
      embeddingSummary: embeddingSummary ?? this.embeddingSummary,
      content: content ?? this.content,
    );
  }
}
