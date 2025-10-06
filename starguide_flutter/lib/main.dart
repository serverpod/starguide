import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:starguide_flutter/chat/starguide_chat_input.dart';
import 'package:starguide_flutter/chat/starguide_disconnected.dart';
import 'package:starguide_flutter/chat/starguide_empty_chat.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';
import 'package:starguide_flutter/config/chat_theme.dart';
import 'package:starguide_flutter/config/constants.dart';
import 'package:starguide_flutter/config/theme.dart';
import 'package:starguide_flutter/widgets/animated_gradient_border.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

// final client = Client(
//   'http://$localhost:8080/',
//   authenticationKeyManager: FlutterAuthenticationKeyManager(),
// )
var client = Client(
  'https://starguide.api.serverpod.space/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
)
//
  ..connectivityMonitor = FlutterConnectivityMonitor();

late SessionManager sessionManager;

late final Highlighter highlighterDart;
late final Highlighter highlighterYaml;
late final Highlighter highlighterSql;

late final String starguideVersion;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  starguideVersion = packageInfo.version;

  sessionManager = SessionManager(caller: client.modules.auth);
  await sessionManager.initialize();

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
  bool? _vote;

  final _inputTextController = TextEditingController();
  final _inputFocusNode = FocusNode();

  bool _isInputFocused = false;

  bool _connectionError = false;
  String? _connectionErrorMessage;
  bool _recaptchaError = false;

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

    // Check if there is an initial query in the URL.
    final uri = Uri.base;
    final query = uri.queryParameters;
    if (query.containsKey('q')) {
      _inputTextController.text = query['q']!;
      _handleMessageSend(_inputTextController.text);
      _inputTextController.clear();
    }

    sessionManager.addListener(() {
      setState(() {
        if (sessionManager.isSignedIn) {
          _recaptchaError = false;
          _connectionError = false;
          _connectionErrorMessage = null;
          _isGeneratingResponse = false;
        }
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
    try {
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
    } on RecaptchaException catch (_) {
      setState(() {
        _recaptchaError = true;
        _connectionError = true;
      });
      return;
    } catch (e) {
      setState(() {
        _connectionError = true;
        _connectionErrorMessage = 'Error: $e';
      });
      return;
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

  void _handleClearChat() {
    setState(() {
      _chatController.setMessages([]);
      _chatSession = null;
      _currentResponse = null;
      _numChatRequests = 0;
      _vote = null;
      _isGeneratingResponse = false;
    });
  }

  void _handleUpvote() {
    _handleVote(true);
  }

  void _handleDownvote() {
    _handleVote(false);
  }

  void _handleVote(bool vote) async {
    try {
      setState(() {
        _vote = vote;
      });
      await client.starguide.vote(_chatSession!, vote);
    } catch (e) {
      setState(() {
        _connectionError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_connectionError) {
      return StarguideDisconnected(
        recaptchaError: _recaptchaError,
        errorMessage: _connectionErrorMessage,
        onReconnect: () {
          _handleClearChat();
          setState(() {
            _connectionError = false;
            _recaptchaError = false;
            _connectionErrorMessage = null;
          });
        },
      );
    }

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
                textMessageBuilder: (
                  context,
                  message,
                  index, {
                  isSentByMe = true,
                  groupStatus,
                }) {
                  return StarguideTextMessage(
                    message: message,
                    index: index,
                    onLinkTap: (url, title) {
                      launchUrl(Uri.parse(url));
                    },
                  );
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
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: AnimatedGradientBorder(
              enabled: _isInputFocused,
              borderWidth: 2,
              glowSize: 8,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradientColors: [
                Colors.blue.withAlpha(192),
                Colors.purple.withAlpha(192),
                Colors.red.withAlpha(192),
              ],
              child: Container(
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
                            icon: Icon(LucideIcons.refreshCw400),
                          ),
                          Spacer(),
                          TextButton.icon(
                            onPressed:
                                _chatSession != null ? _handleUpvote : null,
                            label: Text('Got Help'),
                            icon: Icon(
                              LucideIcons.thumbsUp400,
                              color:
                                  _vote == true ? Colors.blue.shade600 : null,
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _chatSession != null ? _handleDownvote : null,
                            label: Text('Poor Answer'),
                            icon: Icon(
                              LucideIcons.thumbsDown400,
                              color:
                                  _vote == false ? Colors.blue.shade600 : null,
                            ),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  'Version $starguideVersion',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    launchUrl(
                        Uri.parse('https://github.com/serverpod/starguide'));
                  },
                  child: Text(
                    'View Source',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
                Spacer(),
                if (!sessionManager.isSignedIn)
                  Text(
                    'Protected by ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                if (!sessionManager.isSignedIn)
                  PopupMenuButton<String>(
                    tooltip: '',
                    color: Colors.white,
                    offset: const Offset(0, -8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: MarkdownBlock(
                            config: MarkdownConfig(configs: [
                              PConfig(textStyle: theme.textTheme.bodySmall!),
                            ]),
                            data:
                                'This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.',
                          ),
                        ),
                      ),
                    ],
                    child: Text(
                      'reCAPTCHA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                if (sessionManager.isSignedIn)
                  TextButton(
                    onPressed: () {
                      sessionManager.signOutDevice();
                    },
                    child: Text(
                      'Sign out',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
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
