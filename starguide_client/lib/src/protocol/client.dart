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
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:starguide_client/src/protocol/chat_session.dart' as _ioqsfhvv;
import 'package:starguide_client/src/protocol/markdown_resource_info.dart'
    as _i1vbny65;
import 'protocol.dart' as _il2as5qe;

/// Exposes the Google sign-in endpoints of the auth module.
/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>('googleIdp', 'login', {
    'idToken': idToken,
    'accessToken': accessToken,
  });

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {'code': code, 'codeVerifier': codeVerifier, 'redirectUri': redirectUri},
  );

  @override
  _ida.Future<bool> hasAccount() =>
      caller.callServerEndpoint<bool>('googleIdp', 'hasAccount', {});
}

/// Endpoint for handling Model Context Protocol (MCP) related operations.
///
/// Exposes utilities used by MCP-compatible clients to:
/// - Retrieve markdown resources describing the Serverpod framework.
/// - Ask questions answered via RAG (Retrieval-Augmented Generation) over
///   Serverpod documentation and GitHub discussions.
/// - Load and parse markdown resources with metadata extraction.
///
/// {@category Endpoint}
/// {@category Endpoint}
class EndpointMcp extends _isc.EndpointRef {
  EndpointMcp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mcp';

  /// Returns the MCP instruction string presented to MCP clients.
  ///
  /// The returned text outlines the available tools (e.g., list-guides,
  /// get-guide, ask-docs) and how to interact with this server.
  _ida.Future<String> mcpInstructions() =>
      caller.callServerEndpoint<String>('mcp', 'mcpInstructions', {});

  /// Retrieves all markdown resources.
  ///
  /// Returns a list of [MarkdownResourceInfo] objects containing:
  /// - Resource name (extracted from first heading).
  /// - URI (serverpod:// prefixed path).
  /// - Description (first paragraph after title).
  /// - Full text content.
  ///
  /// The resources are discovered by scanning the `assets/resources` directory
  /// for files ending in `.md`. Each file is parsed and converted to a
  /// [MarkdownResourceInfo].
  ///
  /// Throws [FileSystemException] if the resources cannot be accessed.
  _ida.Future<List<_i1vbny65.MarkdownResourceInfo>> getAllResources() =>
      caller.callServerEndpoint<List<_i1vbny65.MarkdownResourceInfo>>(
        'mcp',
        'getAllResources',
        {},
      );

  /// Processes a question using RAG (Retrieval-Augmented Generation).
  ///
  /// Searches both documentation and discussions to find relevant context,
  /// then generates an answer using the generative AI system.
  ///
  /// [session] - The server session for database access.
  /// [question] - The user's question to be answered.
  /// [geminiAPIKey] - API key for the Gemini generative AI service.
  ///
  /// Returns a [String] containing the generated answer based on the retrieved
  /// context and the user's question.
  ///
  /// This method returns a fully assembled answer (non-streaming). For a
  /// streaming, conversational experience see the `starguide.ask` endpoint.
  ///
  /// May throw if the generative AI provider rejects the request or if the
  /// provided [geminiAPIKey] is invalid.
  _ida.Future<String> ask(String question, String geminiAPIKey) =>
      caller.callServerEndpoint<String>('mcp', 'ask', {
        'question': question,
        'geminiAPIKey': geminiAPIKey,
      });
}

/// Exposes the JWT refresh endpoint so clients can renew expired access
/// tokens without signing in again.
/// {@category Endpoint}
class EndpointRefreshJwtTokens extends _iacc.EndpointRefreshJwtTokens {
  EndpointRefreshJwtTokens(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'refreshJwtTokens';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'refreshJwtTokens',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Endpoint for chat sessions and Q&A powered by RAG over Serverpod docs.
/// {@category Endpoint}
class EndpointStarguide extends _isc.EndpointRef {
  EndpointStarguide(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'starguide';

  /// Creates a new chat session for a user after reCAPTCHA check.
  ///
  /// Throws [RecaptchaException] if reCAPTCHA verification fails in
  /// non-development environments. Limits total monthly requests.
  _ida.Future<_ioqsfhvv.ChatSession> createChatSession(String reCaptchaToken) =>
      caller.callServerEndpoint<_ioqsfhvv.ChatSession>(
        'starguide',
        'createChatSession',
        {'reCaptchaToken': reCaptchaToken},
      );

  /// Asks a question and streams the generated answer as chunks.
  ///
  /// Combines previous conversation context with searched RAG documents
  /// from docs and discussions to produce the answer.
  _ida.Stream<String> ask(_ioqsfhvv.ChatSession chatSession, String question) =>
      caller.callStreamingServerEndpoint<_ida.Stream<String>, String>(
        'starguide',
        'ask',
        {'chatSession': chatSession, 'question': question},
        {},
      );

  /// Records a thumbs up or down for the final answer of a chat session.
  _ida.Future<void> vote(_ioqsfhvv.ChatSession chatSession, bool goodAnswer) =>
      caller.callServerEndpoint<void>('starguide', 'vote', {
        'chatSession': chatSession,
        'goodAnswer': goodAnswer,
      });
}

class Modules {
  Modules(Client client) {
    auth = _iacc.Caller(client);
    serverpod_auth_idp = _iaic.Caller(client);
  }

  late final _iacc.Caller auth;

  late final _iaic.Caller serverpod_auth_idp;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(_isc.MethodCallContext, Object, StackTrace)? onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    googleIdp = EndpointGoogleIdp(this);
    mcp = EndpointMcp(this);
    refreshJwtTokens = EndpointRefreshJwtTokens(this);
    starguide = EndpointStarguide(this);
    modules = Modules(this);
  }

  late final EndpointGoogleIdp googleIdp;

  late final EndpointMcp mcp;

  late final EndpointRefreshJwtTokens refreshJwtTokens;

  late final EndpointStarguide starguide;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'googleIdp': googleIdp,
    'mcp': mcp,
    'refreshJwtTokens': refreshJwtTokens,
    'starguide': starguide,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'auth': modules.auth,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
  };
}
