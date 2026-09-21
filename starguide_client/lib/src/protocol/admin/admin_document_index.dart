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
import '../document_index.dart' as _i5wvvsfl;

/// The cached document index with the payloads sent to Jev and totals, for
/// the admin interface.
abstract class AdminDocumentIndex
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminDocumentIndex._({
    required this.index,
    required this.expiresAt,
    required this.entryCount,
    required this.totalSizeInBytes,
    required this.estimatedTokens,
    required this.domainPayload,
    required this.groupPayloads,
  });

  factory AdminDocumentIndex({
    required _i5wvvsfl.DocumentIndex index,
    required DateTime expiresAt,
    required int entryCount,
    required int totalSizeInBytes,
    required int estimatedTokens,
    required String domainPayload,
    required List<String> groupPayloads,
  }) = _AdminDocumentIndexImpl;

  factory AdminDocumentIndex.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminDocumentIndex(
      index: _ix1idbfg.Protocol().deserialize<_i5wvvsfl.DocumentIndex>(
        jsonSerialization['index'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      entryCount: jsonSerialization['entryCount'] as int,
      totalSizeInBytes: jsonSerialization['totalSizeInBytes'] as int,
      estimatedTokens: jsonSerialization['estimatedTokens'] as int,
      domainPayload: jsonSerialization['domainPayload'] as String,
      groupPayloads: _ix1idbfg.Protocol().deserialize<List<String>>(
        jsonSerialization['groupPayloads'],
      ),
    );
  }

  _i5wvvsfl.DocumentIndex index;

  /// When the cached index expires and is rebuilt on the next question.
  DateTime expiresAt;

  int entryCount;

  int totalSizeInBytes;

  /// A rough token count of the payloads, at four bytes per token.
  int estimatedTokens;

  /// The options of the domain question, as JSON.
  String domainPayload;

  /// The options of each group's question, as JSON, in the order of the
  /// groups of the index.
  List<String> groupPayloads;

  /// Returns a shallow copy of this [AdminDocumentIndex]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminDocumentIndex copyWith({
    _i5wvvsfl.DocumentIndex? index,
    DateTime? expiresAt,
    int? entryCount,
    int? totalSizeInBytes,
    int? estimatedTokens,
    String? domainPayload,
    List<String>? groupPayloads,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDocumentIndex',
      'index': index.toJson(),
      'expiresAt': expiresAt.toJson(),
      'entryCount': entryCount,
      'totalSizeInBytes': totalSizeInBytes,
      'estimatedTokens': estimatedTokens,
      'domainPayload': domainPayload,
      'groupPayloads': groupPayloads.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDocumentIndex',
      'index': index.toJsonForProtocol(),
      'expiresAt': expiresAt.toJson(),
      'entryCount': entryCount,
      'totalSizeInBytes': totalSizeInBytes,
      'estimatedTokens': estimatedTokens,
      'domainPayload': domainPayload,
      'groupPayloads': groupPayloads.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminDocumentIndexImpl extends AdminDocumentIndex {
  _AdminDocumentIndexImpl({
    required _i5wvvsfl.DocumentIndex index,
    required DateTime expiresAt,
    required int entryCount,
    required int totalSizeInBytes,
    required int estimatedTokens,
    required String domainPayload,
    required List<String> groupPayloads,
  }) : super._(
         index: index,
         expiresAt: expiresAt,
         entryCount: entryCount,
         totalSizeInBytes: totalSizeInBytes,
         estimatedTokens: estimatedTokens,
         domainPayload: domainPayload,
         groupPayloads: groupPayloads,
       );

  /// Returns a shallow copy of this [AdminDocumentIndex]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminDocumentIndex copyWith({
    _i5wvvsfl.DocumentIndex? index,
    DateTime? expiresAt,
    int? entryCount,
    int? totalSizeInBytes,
    int? estimatedTokens,
    String? domainPayload,
    List<String>? groupPayloads,
  }) {
    return AdminDocumentIndex(
      index: index ?? this.index.copyWith(),
      expiresAt: expiresAt ?? this.expiresAt,
      entryCount: entryCount ?? this.entryCount,
      totalSizeInBytes: totalSizeInBytes ?? this.totalSizeInBytes,
      estimatedTokens: estimatedTokens ?? this.estimatedTokens,
      domainPayload: domainPayload ?? this.domainPayload,
      groupPayloads:
          groupPayloads ?? this.groupPayloads.map((e0) => e0).toList(),
    );
  }
}
