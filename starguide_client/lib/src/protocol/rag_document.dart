/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'rag_document_type.dart' as _i2;

abstract class RAGDocument implements _i1.SerializableModel {
  RAGDocument._({
    this.id,
    required this.embedding,
    required this.fetchTime,
    required this.sourceUrl,
    required this.content,
    required this.title,
    required this.embeddingSummary,
    required this.shortDescription,
    required this.type,
  });

  factory RAGDocument({
    int? id,
    required _i1.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String title,
    required String embeddingSummary,
    required String shortDescription,
    required _i2.RAGDocumentType type,
  }) = _RAGDocumentImpl;

  factory RAGDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return RAGDocument(
      id: jsonSerialization['id'] as int?,
      embedding:
          _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      fetchTime:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchTime']),
      sourceUrl: _i1.UriJsonExtension.fromJson(jsonSerialization['sourceUrl']),
      content: jsonSerialization['content'] as String,
      title: jsonSerialization['title'] as String,
      embeddingSummary: jsonSerialization['embeddingSummary'] as String,
      shortDescription: jsonSerialization['shortDescription'] as String,
      type: _i2.RAGDocumentType.fromJson((jsonSerialization['type'] as int)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.Vector embedding;

  DateTime fetchTime;

  Uri sourceUrl;

  String content;

  String title;

  String embeddingSummary;

  String shortDescription;

  _i2.RAGDocumentType type;

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RAGDocument copyWith({
    int? id,
    _i1.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? title,
    String? embeddingSummary,
    String? shortDescription,
    _i2.RAGDocumentType? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'embedding': embedding.toJson(),
      'fetchTime': fetchTime.toJson(),
      'sourceUrl': sourceUrl.toJson(),
      'content': content,
      'title': title,
      'embeddingSummary': embeddingSummary,
      'shortDescription': shortDescription,
      'type': type.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RAGDocumentImpl extends RAGDocument {
  _RAGDocumentImpl({
    int? id,
    required _i1.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String title,
    required String embeddingSummary,
    required String shortDescription,
    required _i2.RAGDocumentType type,
  }) : super._(
          id: id,
          embedding: embedding,
          fetchTime: fetchTime,
          sourceUrl: sourceUrl,
          content: content,
          title: title,
          embeddingSummary: embeddingSummary,
          shortDescription: shortDescription,
          type: type,
        );

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RAGDocument copyWith({
    Object? id = _Undefined,
    _i1.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? title,
    String? embeddingSummary,
    String? shortDescription,
    _i2.RAGDocumentType? type,
  }) {
    return RAGDocument(
      id: id is int? ? id : this.id,
      embedding: embedding ?? this.embedding.clone(),
      fetchTime: fetchTime ?? this.fetchTime,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      content: content ?? this.content,
      title: title ?? this.title,
      embeddingSummary: embeddingSummary ?? this.embeddingSummary,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
    );
  }
}
