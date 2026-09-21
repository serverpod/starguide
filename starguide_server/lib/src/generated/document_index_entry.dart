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

/// One page of the index, an option of its group's choice question.
abstract class DocumentIndexEntry
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DocumentIndexEntry._({
    required this.documentId,
    required this.label,
    required this.title,
    required this.description,
    required this.sourceUrl,
    required this.sizeInBytes,
  });

  factory DocumentIndexEntry({
    required int documentId,
    required String label,
    required String title,
    required String description,
    required Uri sourceUrl,
    required int sizeInBytes,
  }) = _DocumentIndexEntryImpl;

  factory DocumentIndexEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentIndexEntry(
      documentId: jsonSerialization['documentId'] as int,
      label: jsonSerialization['label'] as String,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      sourceUrl: _is.UriJsonExtension.fromJson(jsonSerialization['sourceUrl']),
      sizeInBytes: jsonSerialization['sizeInBytes'] as int,
    );
  }

  int documentId;

  /// The option label, the page's URL path relative to its group.
  String label;

  String title;

  /// The option description, the page's short description.
  String description;

  Uri sourceUrl;

  /// UTF-8 bytes of the label and description as sent to Jev.
  int sizeInBytes;

  /// Returns a shallow copy of this [DocumentIndexEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DocumentIndexEntry copyWith({
    int? documentId,
    String? label,
    String? title,
    String? description,
    Uri? sourceUrl,
    int? sizeInBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentIndexEntry',
      'documentId': documentId,
      'label': label,
      'title': title,
      'description': description,
      'sourceUrl': sourceUrl.toJson(),
      'sizeInBytes': sizeInBytes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentIndexEntry',
      'documentId': documentId,
      'label': label,
      'title': title,
      'description': description,
      'sourceUrl': sourceUrl.toJson(),
      'sizeInBytes': sizeInBytes,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DocumentIndexEntryImpl extends DocumentIndexEntry {
  _DocumentIndexEntryImpl({
    required int documentId,
    required String label,
    required String title,
    required String description,
    required Uri sourceUrl,
    required int sizeInBytes,
  }) : super._(
         documentId: documentId,
         label: label,
         title: title,
         description: description,
         sourceUrl: sourceUrl,
         sizeInBytes: sizeInBytes,
       );

  /// Returns a shallow copy of this [DocumentIndexEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DocumentIndexEntry copyWith({
    int? documentId,
    String? label,
    String? title,
    String? description,
    Uri? sourceUrl,
    int? sizeInBytes,
  }) {
    return DocumentIndexEntry(
      documentId: documentId ?? this.documentId,
      label: label ?? this.label,
      title: title ?? this.title,
      description: description ?? this.description,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
    );
  }
}
