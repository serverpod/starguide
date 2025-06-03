import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:made_with_serverpod/made_with_serverpod.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:starguide_flutter/chat/starguide_chat_input.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GRecaptchaV3.hideBadge();
  if (kIsWeb) {
    bool ready = await GRecaptchaV3.ready(
      '6LcWhFMrAAAAAHvRY6kr9oc9B_KPeOT0T2SxFGJE',
    );
    print("Is Recaptcha ready? $ready");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _uuid = Uuid();
  final ChatController _chatController = InMemoryChatController();
  final _scrollController = ScrollController();

  static const _userId = 'user';
  static const _modelId = 'model';

  final _user = const User(
    id: _userId,
  );
  final _model = const User(
    id: _modelId,
  );

  ChatSession? _chatSession;

  TextMessage? _currentResponse;

  void _sendMessage(String text) async {
    // Set up a new chat session, if we haven't started one already.
    _chatSession ??= await client.starguide.createChatSession(
      (await GRecaptchaV3.execute('create_chat_session'))!,
    );

    final responseStream = client.starguide.ask(_chatSession!, text);

    var accumulatedText = '';
    final initialMaxScrollExtent = _scrollController.position.maxScrollExtent;
    var hasReachedTargetScroll = false;

    _currentResponse = TextMessage(
      id: _uuid.v4(),
      authorId: _model.id,
      createdAt: DateTime.now().toUtc(),
      text: '...',
    );
    await _chatController.insertMessage(_currentResponse!);

    await for (final chunk in responseStream) {
      accumulatedText += chunk;
      final newMessage = _currentResponse!.copyWith(text: accumulatedText);
      await _chatController.updateMessage(_currentResponse!, newMessage);
      _currentResponse = newMessage;

      if (!hasReachedTargetScroll && initialMaxScrollExtent > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients || !mounted) return;

          // Calculate target scroll position:
          // Start with the initial scroll position
          // Add viewport height to get to top of visible area
          // Subtract bottom safe area
          // Subtract input height since it is absolute positioned (104)
          // Subtract some padding for visual buffer (20)
          final targetScroll = (initialMaxScrollExtent) +
              _scrollController.position.viewportDimension -
              MediaQuery.of(context).padding.bottom -
              104 -
              20;

          if (_scrollController.position.maxScrollExtent > targetScroll) {
            _scrollController.animateTo(
              targetScroll,
              duration: const Duration(milliseconds: 250),
              curve: Curves.linearToEaseOut,
            );
            // Once we've scrolled to target position, don't try to scroll again
            hasReachedTargetScroll = true;
          } else {
            // If we haven't reached target position yet, scroll to bottom
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.linearToEaseOut,
            );
          }
        });
      }
    }
  }

  void _handleMessageSend(String text) async {
    await _chatController.insertMessage(
      TextMessage(
        id: _uuid.v4(),
        authorId: _user.id,
        createdAt: DateTime.now().toUtc(),
        text: text,
      ),
    );

    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Chat(
              currentUserId: _userId,
              chatController: _chatController,
              builders: Builders(
                chatAnimatedListBuilder: (context, itemBuilder) {
                  return ChatAnimatedList(
                    scrollController: _scrollController,
                    itemBuilder: itemBuilder,
                    shouldScrollToEndWhenAtBottom: false,
                  );
                },
                composerBuilder: (context) => Positioned(
                  width: 0,
                  height: 0,
                  top: 0,
                  left: 0,
                  child: SizedBox(),
                ),
                textMessageBuilder: (context, message, index) {
                  return FlyerChatTextMessage(message: message, index: index);
                },
              ),
              resolveUser: (id) => Future.value(switch (id) {
                _userId => _user,
                _modelId => _model,
                _ => null,
              }),
            ),
          ),
          StarguideChatInput(
            onSend: _handleMessageSend,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Row(
              children: [
                Text(
                  'Hosted on Serverpod Cloud',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                Spacer(),
                Text(
                  'Protected by reCAPTCHA',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
