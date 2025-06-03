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
import 'chat_message.dart' as _i2;
import 'chat_message_type.dart' as _i3;
import 'chat_session.dart' as _i4;
import 'rag_document.dart' as _i5;
import 'recaptcha/recaptcha_exception.dart' as _i6;
export 'chat_message.dart';
export 'chat_message_type.dart';
export 'chat_session.dart';
export 'rag_document.dart';
export 'recaptcha/recaptcha_exception.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.ChatMessage) {
      return _i2.ChatMessage.fromJson(data) as T;
    }
    if (t == _i3.ChatMessageType) {
      return _i3.ChatMessageType.fromJson(data) as T;
    }
    if (t == _i4.ChatSession) {
      return _i4.ChatSession.fromJson(data) as T;
    }
    if (t == _i5.RAGDocument) {
      return _i5.RAGDocument.fromJson(data) as T;
    }
    if (t == _i6.RecaptchaException) {
      return _i6.RecaptchaException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ChatMessage?>()) {
      return (data != null ? _i2.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatMessageType?>()) {
      return (data != null ? _i3.ChatMessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatSession?>()) {
      return (data != null ? _i4.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.RAGDocument?>()) {
      return (data != null ? _i5.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.RecaptchaException?>()) {
      return (data != null ? _i6.RecaptchaException.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i3.ChatMessageType) {
      return 'ChatMessageType';
    }
    if (data is _i4.ChatSession) {
      return 'ChatSession';
    }
    if (data is _i5.RAGDocument) {
      return 'RAGDocument';
    }
    if (data is _i6.RecaptchaException) {
      return 'RecaptchaException';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i2.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatMessageType') {
      return deserialize<_i3.ChatMessageType>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i4.ChatSession>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i5.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RecaptchaException') {
      return deserialize<_i6.RecaptchaException>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
