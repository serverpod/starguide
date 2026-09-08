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
import '../rag_document_type.dart' as _i23831eq;

/// The state of one configured data source.
abstract class AdminSourceStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminSourceStatus._({
    required this.name,
    required this.domain,
    required this.type,
    required this.documentCount,
    this.lastFetchTime,
    this.oldestFetchTime,
    this.nextFetchTime,
    this.runningSince,
    this.retryTime,
  });

  factory AdminSourceStatus({
    required String name,
    required String domain,
    required _i23831eq.RAGDocumentType type,
    required int documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextFetchTime,
    DateTime? runningSince,
    DateTime? retryTime,
  }) = _AdminSourceStatusImpl;

  factory AdminSourceStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminSourceStatus(
      name: jsonSerialization['name'] as String,
      domain: jsonSerialization['domain'] as String,
      type: _i23831eq.RAGDocumentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      documentCount: jsonSerialization['documentCount'] as int,
      lastFetchTime: jsonSerialization['lastFetchTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastFetchTime'],
            ),
      oldestFetchTime: jsonSerialization['oldestFetchTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['oldestFetchTime'],
            ),
      nextFetchTime: jsonSerialization['nextFetchTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextFetchTime'],
            ),
      runningSince: jsonSerialization['runningSince'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['runningSince'],
            ),
      retryTime: jsonSerialization['retryTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['retryTime']),
    );
  }

  String name;

  String domain;

  _i23831eq.RAGDocumentType type;

  int documentCount;

  /// When the most recently fetched document of the source was fetched.
  DateTime? lastFetchTime;

  /// When the least recently fetched document of the source was fetched.
  DateTime? oldestFetchTime;

  /// When the next recurring fetch of the source is scheduled. In the past
  /// if the fetch is due but has not started yet.
  DateTime? nextFetchTime;

  /// When the fetch that is currently running was due, or null if no fetch
  /// of the source is running.
  DateTime? runningSince;

  /// When a retry is scheduled after a failed fetch, if any.
  DateTime? retryTime;

  /// Returns a shallow copy of this [AdminSourceStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminSourceStatus copyWith({
    String? name,
    String? domain,
    _i23831eq.RAGDocumentType? type,
    int? documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextFetchTime,
    DateTime? runningSince,
    DateTime? retryTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminSourceStatus',
      'name': name,
      'domain': domain,
      'type': type.toJson(),
      'documentCount': documentCount,
      if (lastFetchTime != null) 'lastFetchTime': lastFetchTime?.toJson(),
      if (oldestFetchTime != null) 'oldestFetchTime': oldestFetchTime?.toJson(),
      if (nextFetchTime != null) 'nextFetchTime': nextFetchTime?.toJson(),
      if (runningSince != null) 'runningSince': runningSince?.toJson(),
      if (retryTime != null) 'retryTime': retryTime?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminSourceStatus',
      'name': name,
      'domain': domain,
      'type': type.toJson(),
      'documentCount': documentCount,
      if (lastFetchTime != null) 'lastFetchTime': lastFetchTime?.toJson(),
      if (oldestFetchTime != null) 'oldestFetchTime': oldestFetchTime?.toJson(),
      if (nextFetchTime != null) 'nextFetchTime': nextFetchTime?.toJson(),
      if (runningSince != null) 'runningSince': runningSince?.toJson(),
      if (retryTime != null) 'retryTime': retryTime?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminSourceStatusImpl extends AdminSourceStatus {
  _AdminSourceStatusImpl({
    required String name,
    required String domain,
    required _i23831eq.RAGDocumentType type,
    required int documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextFetchTime,
    DateTime? runningSince,
    DateTime? retryTime,
  }) : super._(
         name: name,
         domain: domain,
         type: type,
         documentCount: documentCount,
         lastFetchTime: lastFetchTime,
         oldestFetchTime: oldestFetchTime,
         nextFetchTime: nextFetchTime,
         runningSince: runningSince,
         retryTime: retryTime,
       );

  /// Returns a shallow copy of this [AdminSourceStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminSourceStatus copyWith({
    String? name,
    String? domain,
    _i23831eq.RAGDocumentType? type,
    int? documentCount,
    Object? lastFetchTime = _Undefined,
    Object? oldestFetchTime = _Undefined,
    Object? nextFetchTime = _Undefined,
    Object? runningSince = _Undefined,
    Object? retryTime = _Undefined,
  }) {
    return AdminSourceStatus(
      name: name ?? this.name,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      documentCount: documentCount ?? this.documentCount,
      lastFetchTime: lastFetchTime is DateTime?
          ? lastFetchTime
          : this.lastFetchTime,
      oldestFetchTime: oldestFetchTime is DateTime?
          ? oldestFetchTime
          : this.oldestFetchTime,
      nextFetchTime: nextFetchTime is DateTime?
          ? nextFetchTime
          : this.nextFetchTime,
      runningSince: runningSince is DateTime?
          ? runningSince
          : this.runningSince,
      retryTime: retryTime is DateTime? ? retryTime : this.retryTime,
    );
  }
}
