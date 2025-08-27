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
import 'dart:async' as _i2;
import 'package:starguide_client/src/protocol/markdown_resource_info.dart'
    as _i3;
import 'package:starguide_client/src/protocol/chat_session.dart' as _i4;
import 'protocol.dart' as _i5;

/// Endpoint for handling Model Context Protocol (MCP) related operations.
///
/// This endpoint provides functionality for:
/// - Retrieving markdown resources describing the Serverpod framework.
/// - Processing questions using RAG (Retrieval-Augmented Generation) with
///   documentation and discussion search.
/// - Loading and parsing markdown resources with metadata extraction.
/// {@category Endpoint}
class EndpointMcp extends _i1.EndpointRef {
  EndpointMcp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mcp';

  /// Returns the MCP instructions.
  _i2.Future<String> mcpInstructions() => caller.callServerEndpoint<String>(
        'mcp',
        'mcpInstructions',
        {},
      );

  /// Retrieves all markdown resources.
  ///
  /// Returns a list of [MarkdownResourceInfo] objects containing:
  /// - Resource name (extracted from first heading).
  /// - URI (serverpod:// prefixed path).
  /// - Description (first paragraph after title).
  /// - Full text content.
  ///
  /// Throws [FileSystemException] if the resources cannot be accessed.
  _i2.Future<List<_i3.MarkdownResourceInfo>> getAllResources() =>
      caller.callServerEndpoint<List<_i3.MarkdownResourceInfo>>(
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
  _i2.Future<String> ask(
    String question,
    String geminiAPIKey,
  ) =>
      caller.callServerEndpoint<String>(
        'mcp',
        'ask',
        {
          'question': question,
          'geminiAPIKey': geminiAPIKey,
        },
      );
}

/// {@category Endpoint}
class EndpointStarguide extends _i1.EndpointRef {
  EndpointStarguide(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'starguide';

  _i2.Future<_i4.ChatSession> createChatSession(String reCaptchaToken) =>
      caller.callServerEndpoint<_i4.ChatSession>(
        'starguide',
        'createChatSession',
        {'reCaptchaToken': reCaptchaToken},
      );

  _i2.Stream<String> ask(
    _i4.ChatSession chatSession,
    String question,
  ) =>
      caller.callStreamingServerEndpoint<_i2.Stream<String>, String>(
        'starguide',
        'ask',
        {
          'chatSession': chatSession,
          'question': question,
        },
        {},
      );

  _i2.Future<void> vote(
    _i4.ChatSession chatSession,
    bool goodAnswer,
  ) =>
      caller.callServerEndpoint<void>(
        'starguide',
        'vote',
        {
          'chatSession': chatSession,
          'goodAnswer': goodAnswer,
        },
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i5.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    mcp = EndpointMcp(this);
    starguide = EndpointStarguide(this);
  }

  late final EndpointMcp mcp;

  late final EndpointStarguide starguide;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'mcp': mcp,
        'starguide': starguide,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
