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

abstract class ChatSession
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChatSession._({
    this.id,
    this.authUserId,
    required this.keyToken,
    this.goodAnswer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatSession({
    int? id,
    _isc.UuidValue? authUserId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      keyToken: jsonSerialization['keyToken'] as String,
      goodAnswer: jsonSerialization['goodAnswer'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['goodAnswer']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue? authUserId;

  String keyToken;

  bool? goodAnswer;

  DateTime createdAt;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ChatSession copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    String? keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    _isc.UuidValue? authUserId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         keyToken: keyToken,
         goodAnswer: goodAnswer,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    String? keyToken,
    Object? goodAnswer = _Undefined,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      keyToken: keyToken ?? this.keyToken,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
