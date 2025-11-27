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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ChatSession implements _i1.SerializableModel {
  ChatSession._({
    this.id,
    this.userId,
    required this.keyToken,
    this.goodAnswer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatSession({
    int? id,
    int? userId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int?,
      keyToken: jsonSerialization['keyToken'] as String,
      goodAnswer: jsonSerialization['goodAnswer'] as bool?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? userId;

  String keyToken;

  bool? goodAnswer;

  DateTime createdAt;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSession copyWith({
    int? id,
    int? userId,
    String? keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    int? userId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         keyToken: keyToken,
         goodAnswer: goodAnswer,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    Object? userId = _Undefined,
    String? keyToken,
    Object? goodAnswer = _Undefined,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      userId: userId is int? ? userId : this.userId,
      keyToken: keyToken ?? this.keyToken,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
