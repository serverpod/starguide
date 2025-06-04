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
import '../endpoints/starguide_endpoint.dart' as _i2;
import 'package:starguide_server/src/generated/chat_session.dart' as _i3;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'starguide': _i2.StarguideEndpoint()
        ..initialize(
          server,
          'starguide',
          null,
        )
    };
    connectors['starguide'] = _i1.EndpointConnector(
      name: 'starguide',
      endpoint: endpoints['starguide']!,
      methodConnectors: {
        'createChatSession': _i1.MethodConnector(
          name: 'createChatSession',
          params: {
            'reCaptchaToken': _i1.ParameterDescription(
              name: 'reCaptchaToken',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['starguide'] as _i2.StarguideEndpoint)
                  .createChatSession(
            session,
            params['reCaptchaToken'],
          ),
        ),
        'vote': _i1.MethodConnector(
          name: 'vote',
          params: {
            'chatSession': _i1.ParameterDescription(
              name: 'chatSession',
              type: _i1.getType<_i3.ChatSession>(),
              nullable: false,
            ),
            'goodAnswer': _i1.ParameterDescription(
              name: 'goodAnswer',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['starguide'] as _i2.StarguideEndpoint).vote(
            session,
            params['chatSession'],
            params['goodAnswer'],
          ),
        ),
        'ask': _i1.MethodStreamConnector(
          name: 'ask',
          params: {
            'chatSession': _i1.ParameterDescription(
              name: 'chatSession',
              type: _i1.getType<_i3.ChatSession>(),
              nullable: false,
            ),
            'question': _i1.ParameterDescription(
              name: 'question',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
            Map<String, Stream> streamParams,
          ) =>
              (endpoints['starguide'] as _i2.StarguideEndpoint).ask(
            session,
            params['chatSession'],
            params['question'],
          ),
        ),
      },
    );
  }
}
