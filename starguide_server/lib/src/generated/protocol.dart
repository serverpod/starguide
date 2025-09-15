/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i3;
import 'cached_session_count.dart' as _i4;
import 'chat_message.dart' as _i5;
import 'chat_message_type.dart' as _i6;
import 'chat_session.dart' as _i7;
import 'data_fetcher_task.dart' as _i8;
import 'data_fetcher_task_type.dart' as _i9;
import 'exceptions/generative_ai_exception.dart' as _i10;
import 'markdown_resource_info.dart' as _i11;
import 'markdown_resource_list.dart' as _i12;
import 'rag_document.dart' as _i13;
import 'rag_document_type.dart' as _i14;
import 'table_of_contents.dart' as _i15;
import 'recaptcha/recaptcha_exception.dart' as _i16;
import 'package:starguide_server/src/generated/markdown_resource_info.dart'
    as _i17;
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
export 'table_of_contents.dart';
export 'recaptcha/recaptcha_exception.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'chat_message',
      dartName: 'ChatMessage',
      schema: 'public',
      module: 'starguide',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_message_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatSessionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'message',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ChatMessageType',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_message_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'chat_session',
      dartName: 'ChatSession',
      schema: 'public',
      module: 'starguide',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_session_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'keyToken',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'goodAnswer',
          columnType: _i2.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_session_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'createdAt',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'rag_document',
      dartName: 'RAGDocument',
      schema: 'public',
      module: 'starguide',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'rag_document_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'embedding',
          columnType: _i2.ColumnType.vector,
          isNullable: false,
          dartType: 'Vector(1536)',
          vectorDimension: 1536,
        ),
        _i2.ColumnDefinition(
          name: 'fetchTime',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'sourceUrl',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'Uri',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'embeddingSummary',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'shortDescription',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:RAGDocumentType',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'rag_document_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'rag_document_sourceUrl',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sourceUrl',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'rag_document_vector',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'embedding',
            )
          ],
          type: 'hnsw',
          isUnique: false,
          isPrimary: false,
          vectorDistanceFunction: _i2.VectorDistanceFunction.cosine,
          vectorColumnType: _i2.ColumnType.vector,
        ),
        _i2.IndexDefinition(
          indexName: 'rag_document_type',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'type',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i4.CachedSessionCount) {
      return _i4.CachedSessionCount.fromJson(data) as T;
    }
    if (t == _i5.ChatMessage) {
      return _i5.ChatMessage.fromJson(data) as T;
    }
    if (t == _i6.ChatMessageType) {
      return _i6.ChatMessageType.fromJson(data) as T;
    }
    if (t == _i7.ChatSession) {
      return _i7.ChatSession.fromJson(data) as T;
    }
    if (t == _i8.DataFetcherTask) {
      return _i8.DataFetcherTask.fromJson(data) as T;
    }
    if (t == _i9.DataFetcherTaskType) {
      return _i9.DataFetcherTaskType.fromJson(data) as T;
    }
    if (t == _i10.GenerativeAiException) {
      return _i10.GenerativeAiException.fromJson(data) as T;
    }
    if (t == _i11.MarkdownResourceInfo) {
      return _i11.MarkdownResourceInfo.fromJson(data) as T;
    }
    if (t == _i12.MarkdownResourceList) {
      return _i12.MarkdownResourceList.fromJson(data) as T;
    }
    if (t == _i13.RAGDocument) {
      return _i13.RAGDocument.fromJson(data) as T;
    }
    if (t == _i14.RAGDocumentType) {
      return _i14.RAGDocumentType.fromJson(data) as T;
    }
    if (t == _i15.TableOfContents) {
      return _i15.TableOfContents.fromJson(data) as T;
    }
    if (t == _i16.RecaptchaException) {
      return _i16.RecaptchaException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i4.CachedSessionCount?>()) {
      return (data != null ? _i4.CachedSessionCount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ChatMessage?>()) {
      return (data != null ? _i5.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatMessageType?>()) {
      return (data != null ? _i6.ChatMessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatSession?>()) {
      return (data != null ? _i7.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DataFetcherTask?>()) {
      return (data != null ? _i8.DataFetcherTask.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DataFetcherTaskType?>()) {
      return (data != null ? _i9.DataFetcherTaskType.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.GenerativeAiException?>()) {
      return (data != null ? _i10.GenerativeAiException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.MarkdownResourceInfo?>()) {
      return (data != null ? _i11.MarkdownResourceInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.MarkdownResourceList?>()) {
      return (data != null ? _i12.MarkdownResourceList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.RAGDocument?>()) {
      return (data != null ? _i13.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.RAGDocumentType?>()) {
      return (data != null ? _i14.RAGDocumentType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.TableOfContents?>()) {
      return (data != null ? _i15.TableOfContents.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.RecaptchaException?>()) {
      return (data != null ? _i16.RecaptchaException.fromJson(data) : null)
          as T;
    }
    if (t == List<_i11.MarkdownResourceInfo>) {
      return (data as List)
          .map((e) => deserialize<_i11.MarkdownResourceInfo>(e))
          .toList() as T;
    }
    if (t == List<_i17.MarkdownResourceInfo>) {
      return (data as List)
          .map((e) => deserialize<_i17.MarkdownResourceInfo>(e))
          .toList() as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i4.CachedSessionCount) {
      return 'CachedSessionCount';
    }
    if (data is _i5.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i6.ChatMessageType) {
      return 'ChatMessageType';
    }
    if (data is _i7.ChatSession) {
      return 'ChatSession';
    }
    if (data is _i8.DataFetcherTask) {
      return 'DataFetcherTask';
    }
    if (data is _i9.DataFetcherTaskType) {
      return 'DataFetcherTaskType';
    }
    if (data is _i10.GenerativeAiException) {
      return 'GenerativeAiException';
    }
    if (data is _i11.MarkdownResourceInfo) {
      return 'MarkdownResourceInfo';
    }
    if (data is _i12.MarkdownResourceList) {
      return 'MarkdownResourceList';
    }
    if (data is _i13.RAGDocument) {
      return 'RAGDocument';
    }
    if (data is _i14.RAGDocumentType) {
      return 'RAGDocumentType';
    }
    if (data is _i15.TableOfContents) {
      return 'TableOfContents';
    }
    if (data is _i16.RecaptchaException) {
      return 'RecaptchaException';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
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
      return deserialize<_i4.CachedSessionCount>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i5.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatMessageType') {
      return deserialize<_i6.ChatMessageType>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i7.ChatSession>(data['data']);
    }
    if (dataClassName == 'DataFetcherTask') {
      return deserialize<_i8.DataFetcherTask>(data['data']);
    }
    if (dataClassName == 'DataFetcherTaskType') {
      return deserialize<_i9.DataFetcherTaskType>(data['data']);
    }
    if (dataClassName == 'GenerativeAiException') {
      return deserialize<_i10.GenerativeAiException>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceInfo') {
      return deserialize<_i11.MarkdownResourceInfo>(data['data']);
    }
    if (dataClassName == 'MarkdownResourceList') {
      return deserialize<_i12.MarkdownResourceList>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i13.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RAGDocumentType') {
      return deserialize<_i14.RAGDocumentType>(data['data']);
    }
    if (dataClassName == 'TableOfContents') {
      return deserialize<_i15.TableOfContents>(data['data']);
    }
    if (dataClassName == 'RecaptchaException') {
      return deserialize<_i16.RecaptchaException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i3.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.ChatMessage:
        return _i5.ChatMessage.t;
      case _i7.ChatSession:
        return _i7.ChatSession.t;
      case _i13.RAGDocument:
        return _i13.RAGDocument.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'starguide';
}
