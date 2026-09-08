/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:starguide_client/src/protocol/markdown_resource_info.dart'
    as _i1vbny65;
import 'cached_session_count.dart' as _iubbw449;
import 'chat_message.dart' as _ivuncx2e;
import 'chat_message_type.dart' as _itrf31vi;
import 'chat_session.dart' as _i3zhwn74;
import 'exceptions/generative_ai_exception.dart' as _i3yrs0ae;
import 'markdown_resource_info.dart' as _i8dvauvz;
import 'markdown_resource_list.dart' as _ihj0qgwk;
import 'rag_document.dart' as _i8io6bl4;
import 'rag_document_type.dart' as _i19rymhs;
import 'recaptcha/recaptcha_exception.dart' as _i2oyqbrq;
import 'table_of_contents.dart' as _ikwqo0g2;
export 'cached_session_count.dart';
export 'chat_message.dart';
export 'chat_message_type.dart';
export 'chat_session.dart';
export 'exceptions/generative_ai_exception.dart';
export 'markdown_resource_info.dart';
export 'markdown_resource_list.dart';
export 'rag_document.dart';
export 'rag_document_type.dart';
export 'recaptcha/recaptcha_exception.dart';
export 'table_of_contents.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iubbw449.CachedSessionCount) {
      return _iubbw449.CachedSessionCount.fromJson(data) as T;
    }
    if (t == _ivuncx2e.ChatMessage) {
      return _ivuncx2e.ChatMessage.fromJson(data) as T;
    }
    if (t == _itrf31vi.ChatMessageType) {
      return _itrf31vi.ChatMessageType.fromJson(data) as T;
    }
    if (t == _i3zhwn74.ChatSession) {
      return _i3zhwn74.ChatSession.fromJson(data) as T;
    }
    if (t == _i3yrs0ae.GenerativeAiException) {
      return _i3yrs0ae.GenerativeAiException.fromJson(data) as T;
    }
    if (t == _i8dvauvz.MarkdownResourceInfo) {
      return _i8dvauvz.MarkdownResourceInfo.fromJson(data) as T;
    }
    if (t == _ihj0qgwk.MarkdownResourceList) {
      return _ihj0qgwk.MarkdownResourceList.fromJson(data) as T;
    }
    if (t == _i8io6bl4.RAGDocument) {
      return _i8io6bl4.RAGDocument.fromJson(data) as T;
    }
    if (t == _i19rymhs.RAGDocumentType) {
      return _i19rymhs.RAGDocumentType.fromJson(data) as T;
    }
    if (t == _i2oyqbrq.RecaptchaException) {
      return _i2oyqbrq.RecaptchaException.fromJson(data) as T;
    }
    if (t == _ikwqo0g2.TableOfContents) {
      return _ikwqo0g2.TableOfContents.fromJson(data) as T;
    }
    if (t == _isc.getType<_iubbw449.CachedSessionCount?>()) {
      return (data != null ? _iubbw449.CachedSessionCount.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivuncx2e.ChatMessage?>()) {
      return (data != null ? _ivuncx2e.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_itrf31vi.ChatMessageType?>()) {
      return (data != null ? _itrf31vi.ChatMessageType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3zhwn74.ChatSession?>()) {
      return (data != null ? _i3zhwn74.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3yrs0ae.GenerativeAiException?>()) {
      return (data != null
              ? _i3yrs0ae.GenerativeAiException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8dvauvz.MarkdownResourceInfo?>()) {
      return (data != null
              ? _i8dvauvz.MarkdownResourceInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ihj0qgwk.MarkdownResourceList?>()) {
      return (data != null
              ? _ihj0qgwk.MarkdownResourceList.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8io6bl4.RAGDocument?>()) {
      return (data != null ? _i8io6bl4.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i19rymhs.RAGDocumentType?>()) {
      return (data != null ? _i19rymhs.RAGDocumentType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2oyqbrq.RecaptchaException?>()) {
      return (data != null ? _i2oyqbrq.RecaptchaException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikwqo0g2.TableOfContents?>()) {
      return (data != null ? _ikwqo0g2.TableOfContents.fromJson(data) : null)
          as T;
    }
    if (t == List<_i8dvauvz.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_i8dvauvz.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i1vbny65.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_i1vbny65.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iubbw449.CachedSessionCount => 'CachedSessionCount',
      _ivuncx2e.ChatMessage => 'ChatMessage',
      _itrf31vi.ChatMessageType => 'ChatMessageType',
      _i3zhwn74.ChatSession => 'ChatSession',
      _i3yrs0ae.GenerativeAiException => 'GenerativeAiException',
      _i8dvauvz.MarkdownResourceInfo => 'MarkdownResourceInfo',
      _ihj0qgwk.MarkdownResourceList => 'MarkdownResourceList',
      _i8io6bl4.RAGDocument => 'RAGDocument',
      _i19rymhs.RAGDocumentType => 'RAGDocumentType',
      _i2oyqbrq.RecaptchaException => 'RecaptchaException',
      _ikwqo0g2.TableOfContents => 'TableOfContents',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('starguide.', '');
    }

    switch (data) {
      case _iubbw449.CachedSessionCount():
        return 'CachedSessionCount';
      case _ivuncx2e.ChatMessage():
        return 'ChatMessage';
      case _itrf31vi.ChatMessageType():
        return 'ChatMessageType';
      case _i3zhwn74.ChatSession():
        return 'ChatSession';
      case _i3yrs0ae.GenerativeAiException():
        return 'GenerativeAiException';
      case _i8dvauvz.MarkdownResourceInfo():
        return 'MarkdownResourceInfo';
      case _ihj0qgwk.MarkdownResourceList():
        return 'MarkdownResourceList';
      case _i8io6bl4.RAGDocument():
        return 'RAGDocument';
      case _i19rymhs.RAGDocumentType():
        return 'RAGDocumentType';
      case _i2oyqbrq.RecaptchaException():
        return 'RecaptchaException';
      case _ikwqo0g2.TableOfContents():
        return 'TableOfContents';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
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
      return deserialize<_iubbw449.CachedSessionCount>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_ivuncx2e.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatMessageType') {
      return deserialize<_itrf31vi.ChatMessageType>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i3zhwn74.ChatSession>(data['data']);
    }
    if (dataClassName == 'GenerativeAiException') {
      return deserialize<_i3yrs0ae.GenerativeAiException>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceInfo') {
      return deserialize<_i8dvauvz.MarkdownResourceInfo>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceList') {
      return deserialize<_ihj0qgwk.MarkdownResourceList>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i8io6bl4.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RAGDocumentType') {
      return deserialize<_i19rymhs.RAGDocumentType>(data['data']);
    }
    if (dataClassName == 'RecaptchaException') {
      return deserialize<_i2oyqbrq.RecaptchaException>(data['data']);
    }
    if (dataClassName == 'TableOfContents') {
      return deserialize<_ikwqo0g2.TableOfContents>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('starguide', this);
    _iaic.Protocol().registerHostProtocol('starguide', this);
  }

  @override
  String getModuleName() => 'starguide';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
