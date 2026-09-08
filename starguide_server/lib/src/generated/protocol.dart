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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:starguide_server/src/generated/markdown_resource_info.dart'
    as _iwjynyqq;
import 'admin/admin_chat_session_detail.dart' as _ivo4zckc;
import 'admin/admin_chat_session_page.dart' as _i3zfrlvg;
import 'admin/admin_chat_session_summary.dart' as _iv6n96x1;
import 'admin/admin_document_detail.dart' as _i7rng5on;
import 'admin/admin_document_page.dart' as _ip2h1oy2;
import 'admin/admin_document_summary.dart' as _i71m5mgs;
import 'admin/admin_overview.dart' as _ihz32ruq;
import 'admin/admin_source_status.dart' as _i9jun6dq;
import 'admin/daily_stats.dart' as _i9f4s87t;
import 'admin/vote_stats.dart' as _in6jcx54;
import 'cached_session_count.dart' as _iubbw449;
import 'chat_message.dart' as _ivuncx2e;
import 'chat_message_type.dart' as _itrf31vi;
import 'chat_session.dart' as _i3zhwn74;
import 'exceptions/generative_ai_exception.dart' as _i3yrs0ae;
import 'future_calls_generated_models/data_fetcher_future_call_fetch_data_source_model.dart'
    as _iz53h8dc;
import 'markdown_resource_info.dart' as _i8dvauvz;
import 'markdown_resource_list.dart' as _ihj0qgwk;
import 'rag_document.dart' as _i8io6bl4;
import 'rag_document_type.dart' as _i19rymhs;
import 'recaptcha/recaptcha_exception.dart' as _i2oyqbrq;
import 'table_of_contents.dart' as _ikwqo0g2;
export 'admin/admin_chat_session_detail.dart';
export 'admin/admin_chat_session_page.dart';
export 'admin/admin_chat_session_summary.dart';
export 'admin/admin_document_detail.dart';
export 'admin/admin_document_page.dart';
export 'admin/admin_document_summary.dart';
export 'admin/admin_overview.dart';
export 'admin/admin_source_status.dart';
export 'admin/daily_stats.dart';
export 'admin/vote_stats.dart';
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

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'chat_message',
      dartName: 'ChatMessage',
      schema: 'public',
      module: 'starguide',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'chatSessionId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ChatMessageType',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'chat_session',
      dartName: 'ChatSession',
      schema: 'public',
      module: 'starguide',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'keyToken',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'goodAnswer',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'createdAt',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'daily_stats',
      dartName: 'DailyStats',
      schema: 'public',
      module: 'starguide',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'day',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'sessionCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'goodAnswerCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'poorAnswerCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'daily_stats_day',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'day',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'rag_document',
      dartName: 'RAGDocument',
      schema: 'public',
      module: 'starguide',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'embedding',
          columnType: _isp.ColumnType.vector,
          isNullable: false,
          dartType: 'Vector(768)',
          vectorDimension: 768,
        ),
        _isp.ColumnDefinition(
          name: 'fetchTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'sourceUrl',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'Uri',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'embeddingSummary',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'shortDescription',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:RAGDocumentType',
        ),
        _isp.ColumnDefinition(
          name: 'domain',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'rag_document_sourceUrl',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceUrl',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'rag_document_vector',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'embedding',
            ),
          ],
          type: 'hnsw',
          isUnique: false,
          isPrimary: false,
          vectorDistanceFunction: _isp.VectorDistanceFunction.cosine,
          vectorColumnType: _isp.ColumnType.vector,
        ),
        _isp.IndexDefinition(
          indexName: 'rag_document_type',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'type',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ivo4zckc.AdminChatSessionDetail) {
      return _ivo4zckc.AdminChatSessionDetail.fromJson(data) as T;
    }
    if (t == _i3zfrlvg.AdminChatSessionPage) {
      return _i3zfrlvg.AdminChatSessionPage.fromJson(data) as T;
    }
    if (t == _iv6n96x1.AdminChatSessionSummary) {
      return _iv6n96x1.AdminChatSessionSummary.fromJson(data) as T;
    }
    if (t == _i7rng5on.AdminDocumentDetail) {
      return _i7rng5on.AdminDocumentDetail.fromJson(data) as T;
    }
    if (t == _ip2h1oy2.AdminDocumentPage) {
      return _ip2h1oy2.AdminDocumentPage.fromJson(data) as T;
    }
    if (t == _i71m5mgs.AdminDocumentSummary) {
      return _i71m5mgs.AdminDocumentSummary.fromJson(data) as T;
    }
    if (t == _ihz32ruq.AdminOverview) {
      return _ihz32ruq.AdminOverview.fromJson(data) as T;
    }
    if (t == _i9jun6dq.AdminSourceStatus) {
      return _i9jun6dq.AdminSourceStatus.fromJson(data) as T;
    }
    if (t == _i9f4s87t.DailyStats) {
      return _i9f4s87t.DailyStats.fromJson(data) as T;
    }
    if (t == _in6jcx54.VoteStats) {
      return _in6jcx54.VoteStats.fromJson(data) as T;
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
    if (t == _iz53h8dc.DataFetcherFutureCallFetchDataSourceModel) {
      return _iz53h8dc.DataFetcherFutureCallFetchDataSourceModel.fromJson(data)
          as T;
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
    if (t == _is.getType<_ivo4zckc.AdminChatSessionDetail?>()) {
      return (data != null
              ? _ivo4zckc.AdminChatSessionDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3zfrlvg.AdminChatSessionPage?>()) {
      return (data != null
              ? _i3zfrlvg.AdminChatSessionPage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iv6n96x1.AdminChatSessionSummary?>()) {
      return (data != null
              ? _iv6n96x1.AdminChatSessionSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7rng5on.AdminDocumentDetail?>()) {
      return (data != null
              ? _i7rng5on.AdminDocumentDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ip2h1oy2.AdminDocumentPage?>()) {
      return (data != null ? _ip2h1oy2.AdminDocumentPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i71m5mgs.AdminDocumentSummary?>()) {
      return (data != null
              ? _i71m5mgs.AdminDocumentSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihz32ruq.AdminOverview?>()) {
      return (data != null ? _ihz32ruq.AdminOverview.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9jun6dq.AdminSourceStatus?>()) {
      return (data != null ? _i9jun6dq.AdminSourceStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9f4s87t.DailyStats?>()) {
      return (data != null ? _i9f4s87t.DailyStats.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_in6jcx54.VoteStats?>()) {
      return (data != null ? _in6jcx54.VoteStats.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iubbw449.CachedSessionCount?>()) {
      return (data != null ? _iubbw449.CachedSessionCount.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ivuncx2e.ChatMessage?>()) {
      return (data != null ? _ivuncx2e.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itrf31vi.ChatMessageType?>()) {
      return (data != null ? _itrf31vi.ChatMessageType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3zhwn74.ChatSession?>()) {
      return (data != null ? _i3zhwn74.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3yrs0ae.GenerativeAiException?>()) {
      return (data != null
              ? _i3yrs0ae.GenerativeAiException.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_iz53h8dc.DataFetcherFutureCallFetchDataSourceModel?>()) {
      return (data != null
              ? _iz53h8dc.DataFetcherFutureCallFetchDataSourceModel.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_i8dvauvz.MarkdownResourceInfo?>()) {
      return (data != null
              ? _i8dvauvz.MarkdownResourceInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihj0qgwk.MarkdownResourceList?>()) {
      return (data != null
              ? _ihj0qgwk.MarkdownResourceList.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8io6bl4.RAGDocument?>()) {
      return (data != null ? _i8io6bl4.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i19rymhs.RAGDocumentType?>()) {
      return (data != null ? _i19rymhs.RAGDocumentType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2oyqbrq.RecaptchaException?>()) {
      return (data != null ? _i2oyqbrq.RecaptchaException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikwqo0g2.TableOfContents?>()) {
      return (data != null ? _ikwqo0g2.TableOfContents.fromJson(data) : null)
          as T;
    }
    if (t == List<_ivuncx2e.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_ivuncx2e.ChatMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_iv6n96x1.AdminChatSessionSummary>) {
      return (data as List)
              .map((e) => deserialize<_iv6n96x1.AdminChatSessionSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i71m5mgs.AdminDocumentSummary>) {
      return (data as List)
              .map((e) => deserialize<_i71m5mgs.AdminDocumentSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i9jun6dq.AdminSourceStatus>) {
      return (data as List)
              .map((e) => deserialize<_i9jun6dq.AdminSourceStatus>(e))
              .toList()
          as T;
    }
    if (t == List<_i9f4s87t.DailyStats>) {
      return (data as List)
              .map((e) => deserialize<_i9f4s87t.DailyStats>(e))
              .toList()
          as T;
    }
    if (t == List<_i8dvauvz.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_i8dvauvz.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_iwjynyqq.MarkdownResourceInfo>) {
      return (data as List)
              .map((e) => deserialize<_iwjynyqq.MarkdownResourceInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ivo4zckc.AdminChatSessionDetail => 'AdminChatSessionDetail',
      _i3zfrlvg.AdminChatSessionPage => 'AdminChatSessionPage',
      _iv6n96x1.AdminChatSessionSummary => 'AdminChatSessionSummary',
      _i7rng5on.AdminDocumentDetail => 'AdminDocumentDetail',
      _ip2h1oy2.AdminDocumentPage => 'AdminDocumentPage',
      _i71m5mgs.AdminDocumentSummary => 'AdminDocumentSummary',
      _ihz32ruq.AdminOverview => 'AdminOverview',
      _i9jun6dq.AdminSourceStatus => 'AdminSourceStatus',
      _i9f4s87t.DailyStats => 'DailyStats',
      _in6jcx54.VoteStats => 'VoteStats',
      _iubbw449.CachedSessionCount => 'CachedSessionCount',
      _ivuncx2e.ChatMessage => 'ChatMessage',
      _itrf31vi.ChatMessageType => 'ChatMessageType',
      _i3zhwn74.ChatSession => 'ChatSession',
      _i3yrs0ae.GenerativeAiException => 'GenerativeAiException',
      _iz53h8dc.DataFetcherFutureCallFetchDataSourceModel =>
        'DataFetcherFutureCallFetchDataSourceModel',
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
      case _ivo4zckc.AdminChatSessionDetail():
        return 'AdminChatSessionDetail';
      case _i3zfrlvg.AdminChatSessionPage():
        return 'AdminChatSessionPage';
      case _iv6n96x1.AdminChatSessionSummary():
        return 'AdminChatSessionSummary';
      case _i7rng5on.AdminDocumentDetail():
        return 'AdminDocumentDetail';
      case _ip2h1oy2.AdminDocumentPage():
        return 'AdminDocumentPage';
      case _i71m5mgs.AdminDocumentSummary():
        return 'AdminDocumentSummary';
      case _ihz32ruq.AdminOverview():
        return 'AdminOverview';
      case _i9jun6dq.AdminSourceStatus():
        return 'AdminSourceStatus';
      case _i9f4s87t.DailyStats():
        return 'DailyStats';
      case _in6jcx54.VoteStats():
        return 'VoteStats';
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
      case _iz53h8dc.DataFetcherFutureCallFetchDataSourceModel():
        return 'DataFetcherFutureCallFetchDataSourceModel';
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
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminChatSessionDetail') {
      return deserialize<_ivo4zckc.AdminChatSessionDetail>(data['data']);
    }
    if (dataClassName == 'AdminChatSessionPage') {
      return deserialize<_i3zfrlvg.AdminChatSessionPage>(data['data']);
    }
    if (dataClassName == 'AdminChatSessionSummary') {
      return deserialize<_iv6n96x1.AdminChatSessionSummary>(data['data']);
    }
    if (dataClassName == 'AdminDocumentDetail') {
      return deserialize<_i7rng5on.AdminDocumentDetail>(data['data']);
    }
    if (dataClassName == 'AdminDocumentPage') {
      return deserialize<_ip2h1oy2.AdminDocumentPage>(data['data']);
    }
    if (dataClassName == 'AdminDocumentSummary') {
      return deserialize<_i71m5mgs.AdminDocumentSummary>(data['data']);
    }
    if (dataClassName == 'AdminOverview') {
      return deserialize<_ihz32ruq.AdminOverview>(data['data']);
    }
    if (dataClassName == 'AdminSourceStatus') {
      return deserialize<_i9jun6dq.AdminSourceStatus>(data['data']);
    }
    if (dataClassName == 'DailyStats') {
      return deserialize<_i9f4s87t.DailyStats>(data['data']);
    }
    if (dataClassName == 'VoteStats') {
      return deserialize<_in6jcx54.VoteStats>(data['data']);
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
    if (dataClassName == 'DataFetcherFutureCallFetchDataSourceModel') {
      return deserialize<_iz53h8dc.DataFetcherFutureCallFetchDataSourceModel>(
        data['data'],
      );
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
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('starguide', this);
    _iais.Protocol().registerHostProtocol('starguide', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i9f4s87t.DailyStats:
        return _i9f4s87t.DailyStats.t;
      case _ivuncx2e.ChatMessage:
        return _ivuncx2e.ChatMessage.t;
      case _i3zhwn74.ChatSession:
        return _i3zhwn74.ChatSession.t;
      case _i8io6bl4.RAGDocument:
        return _i8io6bl4.RAGDocument.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
