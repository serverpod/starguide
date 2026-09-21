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
import 'document_index_group.dart' as _iliwdnyq;

/// The table of contents of the documentation and website pages, in the
/// form it is handed to Jev: one choice question per group, where every
/// page is an option. Cached by `DocumentIndexCache`.
abstract class DocumentIndex
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DocumentIndex._({required this.generatedAt, required this.groups});

  factory DocumentIndex({
    required DateTime generatedAt,
    required List<_iliwdnyq.DocumentIndexGroup> groups,
  }) = _DocumentIndexImpl;

  factory DocumentIndex.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentIndex(
      generatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
      groups: _ix1idbfg.Protocol()
          .deserialize<List<_iliwdnyq.DocumentIndexGroup>>(
            jsonSerialization['groups'],
          ),
    );
  }

  DateTime generatedAt;

  List<_iliwdnyq.DocumentIndexGroup> groups;

  /// Returns a shallow copy of this [DocumentIndex]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DocumentIndex copyWith({
    DateTime? generatedAt,
    List<_iliwdnyq.DocumentIndexGroup>? groups,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentIndex',
      'generatedAt': generatedAt.toJson(),
      'groups': groups.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentIndex',
      'generatedAt': generatedAt.toJson(),
      'groups': groups.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DocumentIndexImpl extends DocumentIndex {
  _DocumentIndexImpl({
    required DateTime generatedAt,
    required List<_iliwdnyq.DocumentIndexGroup> groups,
  }) : super._(generatedAt: generatedAt, groups: groups);

  /// Returns a shallow copy of this [DocumentIndex]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DocumentIndex copyWith({
    DateTime? generatedAt,
    List<_iliwdnyq.DocumentIndexGroup>? groups,
  }) {
    return DocumentIndex(
      generatedAt: generatedAt ?? this.generatedAt,
      groups: groups ?? this.groups.map((e0) => e0.copyWith()).toList(),
    );
  }
}
