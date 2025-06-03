import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:starguide_flutter/chat/starguide_chat_input.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

late final Highlighter highlighterDart;
late final Highlighter highlighterYaml;
late final Highlighter highlighterSql;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the highlighter.
  await Highlighter.initialize(['dart', 'yaml', 'sql']);
  var theme = await HighlighterTheme.loadDarkTheme();
  highlighterDart = Highlighter(
    language: 'dart',
    theme: theme,
  );
  highlighterYaml = Highlighter(
    language: 'yaml',
    theme: theme,
  );
  highlighterSql = Highlighter(
    language: 'sql',
    theme: theme,
  );

  if (kIsWeb) {
    await GRecaptchaV3.hideBadge();
    await GRecaptchaV3.ready(
      '6LcWhFMrAAAAAHvRY6kr9oc9B_KPeOT0T2SxFGJE',
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
      surface: Colors.white,
      primary: Colors.blueAccent,
    );

    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.grey.shade400,
      ).copyWith(
        colorScheme: colorScheme,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
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
      kIsWeb ? (await GRecaptchaV3.execute('create_chat_session'))! : '',
    );

    final responseStream = client.starguide.ask(_chatSession!, text);

    var accumulatedText = '';
    final initialMaxScrollExtent = _scrollController.position.maxScrollExtent;
    var hasReachedTargetScroll = false;

    _currentResponse = TextMessage(
      id: _uuid.v4(),
      authorId: _model.id,
      createdAt: DateTime.now().toUtc(),
      text: '',
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

    final ChatTheme chatTheme = ChatTheme.light().copyWith(
      colors: ChatColors(
        primary: theme.colorScheme.primary,
        onPrimary: theme.colorScheme.onPrimary,
        surface: theme.colorScheme.surface,
        onSurface: theme.colorScheme.onSurface,
        surfaceContainer: theme.colorScheme.surfaceContainer,
        surfaceContainerHigh: theme.colorScheme.surfaceContainerHigh,
        surfaceContainerLow: theme.colorScheme.surfaceContainerLow,
      ),
      typography: ChatTypography(
        bodySmall: theme.textTheme.bodyLarge!,
        bodyMedium: theme.textTheme.bodyLarge!,
        bodyLarge: theme.textTheme.bodyLarge!,
        labelSmall: theme.textTheme.labelSmall!,
        labelMedium: theme.textTheme.labelMedium!,
        labelLarge: theme.textTheme.labelLarge!,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Chat(
              theme: chatTheme,
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
                  return StarguideTextMessage(message: message, index: index);
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
                  'Built with Serverpod',
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
