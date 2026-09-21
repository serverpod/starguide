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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:starguide_server/src/generated/answer_outcome.dart'
    as _i5aaccr8;
import 'package:starguide_server/src/generated/chat_session.dart' as _icpeorlm;
import 'package:starguide_server/src/generated/future_calls.dart' as _inaozf8m;
import 'package:starguide_server/src/generated/rag_document_type.dart'
    as _id162qm6;
import '../endpoints/admin_endpoint.dart' as _i5t1w2d2;
import '../endpoints/google_idp_endpoint.dart' as _iiimk4ot;
import '../endpoints/mcp_endpoint.dart' as _i7ut3egp;
import '../endpoints/refresh_jwt_tokens_endpoint.dart' as _iaxm0zi1;
import '../endpoints/starguide_endpoint.dart' as _iaui8z7d;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'admin': _i5t1w2d2.AdminEndpoint()..initialize(server, 'admin', null),
      'googleIdp': _iiimk4ot.GoogleIdpEndpoint()
        ..initialize(server, 'googleIdp', null),
      'mcp': _i7ut3egp.McpEndpoint()..initialize(server, 'mcp', null),
      'refreshJwtTokens': _iaxm0zi1.RefreshJwtTokensEndpoint()
        ..initialize(server, 'refreshJwtTokens', null),
      'starguide': _iaui8z7d.StarguideEndpoint()
        ..initialize(server, 'starguide', null),
    };
    connectors['admin'] = _is.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'getOverview': _is.MethodConnector(
          name: 'getOverview',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).getOverview(
                session,
              ),
        ),
        'listDocuments': _is.MethodConnector(
          name: 'listDocuments',
          params: {
            'page': _is.ParameterDescription(
              name: 'page',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'type': _is.ParameterDescription(
              name: 'type',
              type: _is.getType<_id162qm6.RAGDocumentType?>(),
              nullable: true,
            ),
            'domain': _is.ParameterDescription(
              name: 'domain',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'search': _is.ParameterDescription(
              name: 'search',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).listDocuments(
                session,
                page: params['page'],
                pageSize: params['pageSize'],
                type: params['type'],
                domain: params['domain'],
                search: params['search'],
              ),
        ),
        'listDocumentDomains': _is.MethodConnector(
          name: 'listDocumentDomains',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .listDocumentDomains(session),
        ),
        'getDocument': _is.MethodConnector(
          name: 'getDocument',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).getDocument(
                session,
                params['id'],
              ),
        ),
        'getDocumentIndex': _is.MethodConnector(
          name: 'getDocumentIndex',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).getDocumentIndex(
                session,
              ),
        ),
        'rebuildDocumentIndex': _is.MethodConnector(
          name: 'rebuildDocumentIndex',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .rebuildDocumentIndex(session),
        ),
        'listChatSessions': _is.MethodConnector(
          name: 'listChatSessions',
          params: {
            'page': _is.ParameterDescription(
              name: 'page',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'goodAnswer': _is.ParameterDescription(
              name: 'goodAnswer',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'votedOnly': _is.ParameterDescription(
              name: 'votedOnly',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'outcomes': _is.ParameterDescription(
              name: 'outcomes',
              type: _is.getType<List<_i5aaccr8.AnswerOutcome>?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).listChatSessions(
                session,
                page: params['page'],
                pageSize: params['pageSize'],
                goodAnswer: params['goodAnswer'],
                votedOnly: params['votedOnly'],
                outcomes: params['outcomes'],
              ),
        ),
        'getChatSession': _is.MethodConnector(
          name: 'getChatSession',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).getChatSession(
                session,
                params['id'],
              ),
        ),
      },
    );
    connectors['googleIdp'] = _is.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'accessToken': _is.ParameterDescription(
              name: 'accessToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint).login(
                session,
                idToken: params['idToken'],
                accessToken: params['accessToken'],
              ),
        ),
        'loginWithCode': _is.MethodConnector(
          name: 'loginWithCode',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'codeVerifier': _is.ParameterDescription(
              name: 'codeVerifier',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'redirectUri': _is.ParameterDescription(
              name: 'redirectUri',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint)
                  .loginWithCode(
                    session,
                    code: params['code'],
                    codeVerifier: params['codeVerifier'],
                    redirectUri: params['redirectUri'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['googleIdp'] as _iiimk4ot.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['mcp'] = _is.EndpointConnector(
      name: 'mcp',
      endpoint: endpoints['mcp']!,
      methodConnectors: {
        'mcpInstructions': _is.MethodConnector(
          name: 'mcpInstructions',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['mcp'] as _i7ut3egp.McpEndpoint).mcpInstructions(
                session,
              ),
        ),
        'getAllResources': _is.MethodConnector(
          name: 'getAllResources',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['mcp'] as _i7ut3egp.McpEndpoint).getAllResources(
                session,
              ),
        ),
        'ask': _is.MethodConnector(
          name: 'ask',
          params: {
            'question': _is.ParameterDescription(
              name: 'question',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'geminiAPIKey': _is.ParameterDescription(
              name: 'geminiAPIKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['mcp'] as _i7ut3egp.McpEndpoint).ask(
                session,
                params['question'],
                params['geminiAPIKey'],
              ),
        ),
      },
    );
    connectors['refreshJwtTokens'] = _is.EndpointConnector(
      name: 'refreshJwtTokens',
      endpoint: endpoints['refreshJwtTokens']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['refreshJwtTokens']
                      as _iaxm0zi1.RefreshJwtTokensEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['starguide'] = _is.EndpointConnector(
      name: 'starguide',
      endpoint: endpoints['starguide']!,
      methodConnectors: {
        'createChatSession': _is.MethodConnector(
          name: 'createChatSession',
          params: {
            'reCaptchaToken': _is.ParameterDescription(
              name: 'reCaptchaToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['starguide'] as _iaui8z7d.StarguideEndpoint)
                  .createChatSession(session, params['reCaptchaToken']),
        ),
        'vote': _is.MethodConnector(
          name: 'vote',
          params: {
            'chatSession': _is.ParameterDescription(
              name: 'chatSession',
              type: _is.getType<_icpeorlm.ChatSession>(),
              nullable: false,
            ),
            'goodAnswer': _is.ParameterDescription(
              name: 'goodAnswer',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['starguide'] as _iaui8z7d.StarguideEndpoint).vote(
                session,
                params['chatSession'],
                params['goodAnswer'],
              ),
        ),
        'ask': _is.MethodStreamConnector(
          name: 'ask',
          params: {
            'chatSession': _is.ParameterDescription(
              name: 'chatSession',
              type: _is.getType<_icpeorlm.ChatSession>(),
              nullable: false,
            ),
            'question': _is.ParameterDescription(
              name: 'question',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['starguide'] as _iaui8z7d.StarguideEndpoint).ask(
                session,
                params['chatSession'],
                params['question'],
              ),
        ),
      },
    );
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _inaozf8m.FutureCalls();
  }
}
