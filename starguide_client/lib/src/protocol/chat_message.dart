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
import 'chat_message_type.dart' as _i2;

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.chatSessionId,
    required this.message,
    required this.type,
  });

  factory ChatMessage({
    int? id,
    required int chatSessionId,
    required String message,
    required _i2.ChatMessageType type,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      chatSessionId: jsonSerialization['chatSessionId'] as int,
      message: jsonSerialization['message'] as String,
      type: _i2.ChatMessageType.fromJson((jsonSerialization['type'] as int)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int chatSessionId;

  String message;

  _i2.ChatMessageType type;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    int? id,
    int? chatSessionId,
    String? message,
    _i2.ChatMessageType? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chatSessionId': chatSessionId,
      'message': message,
      'type': type.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required int chatSessionId,
    required String message,
    required _i2.ChatMessageType type,
  }) : super._(
          id: id,
          chatSessionId: chatSessionId,
          message: message,
          type: type,
        );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    int? chatSessionId,
    String? message,
    _i2.ChatMessageType? type,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}
