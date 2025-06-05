import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:starguide_flutter/chat/starguide_chat_input.dart';
import 'package:starguide_flutter/chat/starguide_empty_chat.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';
import 'package:starguide_flutter/config/chat_theme.dart';
import 'package:starguide_flutter/config/constants.dart';
import 'package:starguide_flutter/config/theme.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

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
  runApp(const StarguideApp());
}

class StarguideApp extends StatelessWidget {
  const StarguideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Starguide',
      theme: createTheme(),
      home: const StarguideChatPage(),
    );
  }
}

class StarguideChatPage extends StatefulWidget {
  const StarguideChatPage({
    super.key,
  });

  @override
  StarguideChatPageState createState() => StarguideChatPageState();
}

class StarguideChatPageState extends State<StarguideChatPage> {
  final _uuid = Uuid();
  final ChatController _chatController = InMemoryChatController();

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
  bool _hasInputText = false;
  bool _isGeneratingResponse = false;
  int _numChatRequests = 0;

  final _inputTextController = TextEditingController();
  final _inputFocusNode = FocusNode();

  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();

    _inputTextController.addListener(() {
      setState(() {
        _hasInputText = _inputTextController.text.isNotEmpty;
      });
    });

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    setState(() {
      _isGeneratingResponse = true;
      _numChatRequests += 1;
    });

    // Set up a new chat session, if we haven't started one already.
    _chatSession ??= await client.starguide.createChatSession(
      kIsWeb ? (await GRecaptchaV3.execute('create_chat_session'))! : '',
    );

    final responseStream = client.starguide.ask(_chatSession!, text);

    var accumulatedText = '';

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
    }

    _currentResponse = null;
    setState(() {
      _isGeneratingResponse = false;
    });
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

  void _handleClearChat() {
    setState(() {
      _chatController.setMessages([]);
      _chatSession = null;
      _currentResponse = null;
      _numChatRequests = 0;
    });
  }

  void _handleUpvote() {
    client.starguide.vote(_chatSession!, true);
  }

  void _handleDownvote() {
    client.starguide.vote(_chatSession!, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Chat(
              theme: createChatTheme(context),
              currentUserId: _userId,
              chatController: _chatController,
              builders: Builders(
                chatAnimatedListBuilder: (context, itemBuilder) {
                  return ChatAnimatedList(
                    itemBuilder: itemBuilder,
                    shouldScrollToEndWhenAtBottom: true,
                    shouldScrollToEndWhenSendingMessage: true,
                    bottomPadding: 16,
                    topPadding: 16,
                    removeAnimationDuration: Duration.zero,
                    handleSafeArea: false,
                    reversed: true,
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
                emptyChatListBuilder: (context) => StarguideEmptyChat(),
              ),
              resolveUser: (id) => Future.value(switch (id) {
                _userId => _user,
                _modelId => _model,
                _ => null,
              }),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: _isInputFocused
                    ? theme.colorScheme.outline
                    : theme.dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: _handleClearChat,
                        label: Text('Clear Chat'),
                        icon: Icon(Icons.autorenew),
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: _chatSession != null ? _handleUpvote : null,
                        label: Text('Got Help'),
                        icon: Icon(Icons.thumb_up_outlined),
                      ),
                      TextButton.icon(
                        onPressed:
                            _chatSession != null ? _handleDownvote : null,
                        label: Text('Poor Answer'),
                        icon: Icon(Icons.thumb_down_outlined),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: _isInputFocused
                      ? theme.colorScheme.outline
                      : theme.dividerColor,
                ),
                StarguideChatInput(
                  textController: _inputTextController,
                  focusNode: _inputFocusNode,
                  onSend: _handleMessageSend,
                  enabled: _hasInputText &&
                      !_isGeneratingResponse &&
                      _numChatRequests < kMaxChatRequests,
                  isGeneratingResponse: _isGeneratingResponse,
                  numChatRequests: _numChatRequests,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
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
