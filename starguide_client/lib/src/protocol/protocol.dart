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
import 'cached_session_count.dart' as _i2;
import 'chat_message.dart' as _i3;
import 'chat_message_type.dart' as _i4;
import 'chat_session.dart' as _i5;
import 'data_fetcher_task.dart' as _i6;
import 'data_fetcher_task_type.dart' as _i7;
import 'exceptions/generative_ai_exception.dart' as _i8;
import 'markdown_resource_info.dart' as _i9;
import 'markdown_resource_list.dart' as _i10;
import 'rag_document.dart' as _i11;
import 'rag_document_type.dart' as _i12;
import 'recaptcha/recaptcha_exception.dart' as _i13;
import 'table_of_contents.dart' as _i14;
import 'package:starguide_client/src/protocol/markdown_resource_info.dart'
    as _i15;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i16;
export 'cached_session_count.dart';
export 'chat_message.dart';
export 'chat_message_type.dart';
export 'chat_session.dart';
export 'data_fetcher_task.dart';
export 'data_fetcher_task_type.dart';
export 'exceptions/generative_ai_exception.dart';
export 'markdown_resource_info.dart';
export 'markdown_resource_list.dart';
export 'rag_document.dart';
export 'rag_document_type.dart';
export 'recaptcha/recaptcha_exception.dart';
export 'table_of_contents.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != t.toString()) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

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
    if (t == _i8.GenerativeAiException) {
      return _i8.GenerativeAiException.fromJson(data) as T;
    }
    if (t == _i9.MarkdownResourceInfo) {
      return _i9.MarkdownResourceInfo.fromJson(data) as T;
    }
    if (t == _i10.MarkdownResourceList) {
      return _i10.MarkdownResourceList.fromJson(data) as T;
    }
    if (t == _i11.RAGDocument) {
      return _i11.RAGDocument.fromJson(data) as T;
    }
    if (t == _i12.RAGDocumentType) {
      return _i12.RAGDocumentType.fromJson(data) as T;
    }
    if (t == _i13.RecaptchaException) {
      return _i13.RecaptchaException.fromJson(data) as T;
    }
    if (t == _i14.TableOfContents) {
      return _i14.TableOfContents.fromJson(data) as T;
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
    if (t == _i1.getType<_i8.GenerativeAiException?>()) {
      return (data != null ? _i8.GenerativeAiException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.MarkdownResourceInfo?>()) {
      return (data != null ? _i9.MarkdownResourceInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.MarkdownResourceList?>()) {
      return (data != null ? _i10.MarkdownResourceList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.RAGDocument?>()) {
      return (data != null ? _i11.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.RAGDocumentType?>()) {
      return (data != null ? _i12.RAGDocumentType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.RecaptchaException?>()) {
      return (data != null ? _i13.RecaptchaException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.TableOfContents?>()) {
      return (data != null ? _i14.TableOfContents.fromJson(data) : null) as T;
    }
    if (t == List<_i9.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_i9.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_i15.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    try {
      return _i16.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('starguide.', '');
    }

    switch (data) {
      case _i2.CachedSessionCount():
        return 'CachedSessionCount';
      case _i3.ChatMessage():
        return 'ChatMessage';
      case _i4.ChatMessageType():
        return 'ChatMessageType';
      case _i5.ChatSession():
        return 'ChatSession';
      case _i6.DataFetcherTask():
        return 'DataFetcherTask';
      case _i7.DataFetcherTaskType():
        return 'DataFetcherTaskType';
      case _i8.GenerativeAiException():
        return 'GenerativeAiException';
      case _i9.MarkdownResourceInfo():
        return 'MarkdownResourceInfo';
      case _i10.MarkdownResourceList():
        return 'MarkdownResourceList';
      case _i11.RAGDocument():
        return 'RAGDocument';
      case _i12.RAGDocumentType():
        return 'RAGDocumentType';
      case _i13.RecaptchaException():
        return 'RecaptchaException';
      case _i14.TableOfContents():
        return 'TableOfContents';
    }
    className = _i16.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
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
    if (dataClassName == 'GenerativeAiException') {
      return deserialize<_i8.GenerativeAiException>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceInfo') {
      return deserialize<_i9.MarkdownResourceInfo>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceList') {
      return deserialize<_i10.MarkdownResourceList>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i11.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RAGDocumentType') {
      return deserialize<_i12.RAGDocumentType>(data['data']);
    }
    if (dataClassName == 'RecaptchaException') {
      return deserialize<_i13.RecaptchaException>(data['data']);
    }
    if (dataClassName == 'TableOfContents') {
      return deserialize<_i14.TableOfContents>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i16.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
