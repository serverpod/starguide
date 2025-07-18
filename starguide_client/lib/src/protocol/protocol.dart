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
import 'cached_session_count.dart' as _i2;
import 'chat_message.dart' as _i3;
import 'chat_message_type.dart' as _i4;
import 'chat_session.dart' as _i5;
import 'data_fetcher_task.dart' as _i6;
import 'data_fetcher_task_type.dart' as _i7;
import 'rag_document.dart' as _i8;
import 'rag_document_type.dart' as _i9;
import 'table_of_contents.dart' as _i10;
import 'recaptcha/recaptcha_exception.dart' as _i11;
export 'cached_session_count.dart';
export 'chat_message.dart';
export 'chat_message_type.dart';
export 'chat_session.dart';
export 'data_fetcher_task.dart';
export 'data_fetcher_task_type.dart';
export 'rag_document.dart';
export 'rag_document_type.dart';
export 'table_of_contents.dart';
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
    if (t == _i2.CachedSessionCount) {
      return _i2.CachedSessionCount.fromJson(data) as T;
    }
    if (t == _i3.ChatMessage) {
      return _i3.ChatMessage.fromJson(data) as T;
    }
    if (t == _i4.ChatMessageType) {
      return _i4.ChatMessageType.fromJson(data) as T;
    }
    if (t == _i5.ChatSession) {
      return _i5.ChatSession.fromJson(data) as T;
    }
    if (t == _i6.DataFetcherTask) {
      return _i6.DataFetcherTask.fromJson(data) as T;
    }
    if (t == _i7.DataFetcherTaskType) {
      return _i7.DataFetcherTaskType.fromJson(data) as T;
    }
    if (t == _i8.RAGDocument) {
      return _i8.RAGDocument.fromJson(data) as T;
    }
    if (t == _i9.RAGDocumentType) {
      return _i9.RAGDocumentType.fromJson(data) as T;
    }
    if (t == _i10.TableOfContents) {
      return _i10.TableOfContents.fromJson(data) as T;
    }
    if (t == _i11.RecaptchaException) {
      return _i11.RecaptchaException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CachedSessionCount?>()) {
      return (data != null ? _i2.CachedSessionCount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatMessage?>()) {
      return (data != null ? _i3.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatMessageType?>()) {
      return (data != null ? _i4.ChatMessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ChatSession?>()) {
      return (data != null ? _i5.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DataFetcherTask?>()) {
      return (data != null ? _i6.DataFetcherTask.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DataFetcherTaskType?>()) {
      return (data != null ? _i7.DataFetcherTaskType.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.RAGDocument?>()) {
      return (data != null ? _i8.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.RAGDocumentType?>()) {
      return (data != null ? _i9.RAGDocumentType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.TableOfContents?>()) {
      return (data != null ? _i10.TableOfContents.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.RecaptchaException?>()) {
      return (data != null ? _i11.RecaptchaException.fromJson(data) : null)
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.CachedSessionCount) {
      return 'CachedSessionCount';
    }
    if (data is _i3.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i4.ChatMessageType) {
      return 'ChatMessageType';
    }
    if (data is _i5.ChatSession) {
      return 'ChatSession';
    }
    if (data is _i6.DataFetcherTask) {
      return 'DataFetcherTask';
    }
    if (data is _i7.DataFetcherTaskType) {
      return 'DataFetcherTaskType';
    }
    if (data is _i8.RAGDocument) {
      return 'RAGDocument';
    }
    if (data is _i9.RAGDocumentType) {
      return 'RAGDocumentType';
    }
    if (data is _i10.TableOfContents) {
      return 'TableOfContents';
    }
    if (data is _i11.RecaptchaException) {
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
    if (dataClassName == 'CachedSessionCount') {
      return deserialize<_i2.CachedSessionCount>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i3.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatMessageType') {
      return deserialize<_i4.ChatMessageType>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i5.ChatSession>(data['data']);
    }
    if (dataClassName == 'DataFetcherTask') {
      return deserialize<_i6.DataFetcherTask>(data['data']);
    }
    if (dataClassName == 'DataFetcherTaskType') {
      return deserialize<_i7.DataFetcherTaskType>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i8.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RAGDocumentType') {
      return deserialize<_i9.RAGDocumentType>(data['data']);
    }
    if (dataClassName == 'TableOfContents') {
      return deserialize<_i10.TableOfContents>(data['data']);
    }
    if (dataClassName == 'RecaptchaException') {
      return deserialize<_i11.RecaptchaException>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
