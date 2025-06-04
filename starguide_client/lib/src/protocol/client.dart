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
import 'package:starguide_client/src/protocol/chat_session.dart' as _i3;
import 'protocol.dart' as _i4;

/// {@category Endpoint}
class EndpointStarguide extends _i1.EndpointRef {
  EndpointStarguide(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'starguide';

  _i2.Future<_i3.ChatSession> createChatSession(String reCaptchaToken) =>
      caller.callServerEndpoint<_i3.ChatSession>(
        'starguide',
        'createChatSession',
        {'reCaptchaToken': reCaptchaToken},
      );

  _i2.Stream<String> ask(
    _i3.ChatSession chatSession,
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
    _i3.ChatSession chatSession,
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
          _i4.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    starguide = EndpointStarguide(this);
  }

  late final EndpointStarguide starguide;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup =>
      {'starguide': starguide};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
