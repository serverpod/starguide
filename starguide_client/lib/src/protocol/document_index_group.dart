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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:starguide_client/src/protocol/protocol.dart' as _ix1idbfg;
import 'document_index_entry.dart' as _idhgvu66;
import 'rag_document_type.dart' as _i19rymhs;

/// The pages of one data source, asked about as one choice question.
abstract class DocumentIndexGroup
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DocumentIndexGroup._({
    required this.name,
    required this.domain,
    required this.description,
    required this.type,
    required this.entries,
    required this.sizeInBytes,
  });

  factory DocumentIndexGroup({
    required String name,
    required String domain,
    required String description,
    required _i19rymhs.RAGDocumentType type,
    required List<_idhgvu66.DocumentIndexEntry> entries,
    required int sizeInBytes,
  }) = _DocumentIndexGroupImpl;

  factory DocumentIndexGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentIndexGroup(
      name: jsonSerialization['name'] as String,
      domain: jsonSerialization['domain'] as String,
      description: jsonSerialization['description'] as String,
      type: _i19rymhs.RAGDocumentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      entries: _ix1idbfg.Protocol()
          .deserialize<List<_idhgvu66.DocumentIndexEntry>>(
            jsonSerialization['entries'],
          ),
      sizeInBytes: jsonSerialization['sizeInBytes'] as int,
    );
  }

  /// Unique name of the group. The domain, with a number appended when a
  /// source has more pages than fit in one question.
  String name;

  /// The domain of the pages, which is an option of the domain question.
  String domain;

  /// What the domain is, as the description of its option.
  String description;

  _i19rymhs.RAGDocumentType type;

  List<_idhgvu66.DocumentIndexEntry> entries;

  /// UTF-8 bytes of the options as sent to Jev.
  int sizeInBytes;

  /// Returns a shallow copy of this [DocumentIndexGroup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DocumentIndexGroup copyWith({
    String? name,
    String? domain,
    String? description,
    _i19rymhs.RAGDocumentType? type,
    List<_idhgvu66.DocumentIndexEntry>? entries,
    int? sizeInBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentIndexGroup',
      'name': name,
      'domain': domain,
      'description': description,
      'type': type.toJson(),
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      'sizeInBytes': sizeInBytes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentIndexGroup',
      'name': name,
      'domain': domain,
      'description': description,
      'type': type.toJson(),
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'sizeInBytes': sizeInBytes,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DocumentIndexGroupImpl extends DocumentIndexGroup {
  _DocumentIndexGroupImpl({
    required String name,
    required String domain,
    required String description,
    required _i19rymhs.RAGDocumentType type,
    required List<_idhgvu66.DocumentIndexEntry> entries,
    required int sizeInBytes,
  }) : super._(
         name: name,
         domain: domain,
         description: description,
         type: type,
         entries: entries,
         sizeInBytes: sizeInBytes,
       );

  /// Returns a shallow copy of this [DocumentIndexGroup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DocumentIndexGroup copyWith({
    String? name,
    String? domain,
    String? description,
    _i19rymhs.RAGDocumentType? type,
    List<_idhgvu66.DocumentIndexEntry>? entries,
    int? sizeInBytes,
  }) {
    return DocumentIndexGroup(
      name: name ?? this.name,
      domain: domain ?? this.domain,
      description: description ?? this.description,
      type: type ?? this.type,
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
    );
  }
}
