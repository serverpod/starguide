import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
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
  final _chatController = InMemoryChatController();
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
    _chatSession ??= await client.starguide.createChatSession();

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
    await _chatController.insert(_currentResponse!);

    await for (final chunk in responseStream) {
      accumulatedText += chunk;
      final newMessage = _currentResponse!.copyWith(text: accumulatedText);
      await _chatController.update(_currentResponse!, newMessage);
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
    await _chatController.insert(
      TextMessage(
        id: _uuid.v4(),
        authorId: _user.id,
        createdAt: DateTime.now().toUtc(),
        text: text,
        isOnlyEmoji: isOnlyEmoji(text),
      ),
    );

    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
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
          textMessageBuilder: (context, message, index) {
            return FlyerChatTextMessage(message: message, index: index);
          },
        ),
        resolveUser: (id) => Future.value(switch (id) {
          _userId => _user,
          _modelId => _model,
          _ => null,
        }),
        onMessageSend: _handleMessageSend,
      ),
    );
  }
}
