import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shad/shad.dart'
    show
        GlobalShadLocalizations,
        LucideIcons,
        ShadApp,
        ShadAppBuilder,
        ShadThemeData;
import 'package:starguide_flutter/admin/admin_page.dart';
import 'package:starguide_flutter/chat/starguide_chat_input.dart';
import 'package:starguide_flutter/chat/starguide_disconnected.dart';
import 'package:starguide_flutter/chat/starguide_empty_chat.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';
import 'package:starguide_flutter/config/app_config.dart';
import 'package:starguide_flutter/config/chat_theme.dart';
import 'package:starguide_flutter/config/constants.dart';
import 'package:starguide_flutter/config/theme.dart';
import 'package:starguide_flutter/config/tree_shaken_fonts.dart';
import 'package:starguide_flutter/widgets/animated_gradient_border.dart';
import 'package:starguide_flutter/widgets/starguide_markdown.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

/// Client used to talk to the server from anywhere in the app. It is created
/// in [main] once the server URL is known.
late final Client client;

late FlutterAuthSessionManager sessionManager;

/// Client id of the web application OAuth client used by the server.
const _googleClientId =
    '228196660760-93k92hcfke8ettcokvm7hdtm2uq19je0.apps.googleusercontent.com';

/// Redirect URI for the Google sign-in flow on web. The callback page must be
/// served on the same origin as this app, as it posts the result back to the
/// app window.
///
/// Release builds are served by the Serverpod web server, which serves the
/// callback page at `/googlesignin`. Debug builds are typically run with
/// `flutter run -d chrome`, where the Flutter dev server is the app's origin
/// and serves the callback page from `web/auth.html`. Run on a fixed port and
/// register `http://localhost:8888/auth.html` (with the port you use) as an
/// authorized redirect URI on the OAuth client in the Google Cloud console:
///
/// flutter run -d chrome --web-port 8888
///
/// The URI can also be overridden with the `GOOGLE_WEB_REDIRECT_URI` dart
/// define.
String get _googleWebRedirectUri {
  const override = String.fromEnvironment('GOOGLE_WEB_REDIRECT_URI');
  if (override.isNotEmpty) return override;

  final callbackPage = kDebugMode ? 'auth.html' : 'googlesignin';
  return '${Uri.base.origin}/$callbackPage';
}

late final Highlighter highlighterDart;
late final Highlighter highlighterYaml;
late final Highlighter highlighterSql;

late final String starguideVersion;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  starguideVersion = packageInfo.version;

  // The API server URL comes from the `assets/config.json` asset. When the app
  // is served by the Serverpod web server, the server provides that file with
  // the URL of its own API server. When running the app with `flutter run`,
  // the bundled file points at a local server. Both can be overridden with a
  // dart define, e.g. to run against production:
  //
  // flutter run --dart-define=SERVER_URL=https://starguide.api.serverpod.space/
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final config = await AppConfig.loadConfig();
  final serverUrl = serverUrlFromEnv.isEmpty
      ? config.apiUrl ?? 'http://$localhost:8080/'
      : serverUrlFromEnv;

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = FlutterAuthSessionManager();
  client.authSessionManager = sessionManager;
  await sessionManager.initialize();
  await _initializeGoogleSignIn();

  // Initialize the highlighter.
  await Highlighter.initialize(['dart', 'yaml', 'sql']);
  var theme = await HighlighterTheme.loadDarkTheme();
  highlighterDart = Highlighter(language: 'dart', theme: theme);
  highlighterYaml = Highlighter(language: 'yaml', theme: theme);
  highlighterSql = Highlighter(language: 'sql', theme: theme);

  if (kIsWeb) {
    await GRecaptchaV3.hideBadge();
    await GRecaptchaV3.ready('6LcWhFMrAAAAAHvRY6kr9oc9B_KPeOT0T2SxFGJE');
  }
  // Only referenced so the constants reach the compiler; see the list.
  assert(kTreeShakenFonts.isNotEmpty);
  runApp(const StarguideApp());
}

Future<void> _initializeGoogleSignIn() async {
  try {
    if (kIsWeb) {
      await client.auth.initializeGoogleSignIn(
        clientId: _googleClientId,
        redirectUri: _googleWebRedirectUri,
      );
    } else {
      await client.auth.initializeGoogleSignIn(serverClientId: _googleClientId);
    }
  } catch (e) {
    // Sign-in is only a fallback for failed reCAPTCHA checks, so a missing
    // platform configuration must not prevent the app from starting.
    debugPrint('Google sign-in is unavailable: $e');
  }
}

class StarguideApp extends StatelessWidget {
  const StarguideApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The chat is built with Material widgets and the admin interface with
    // shad, so the shad theme is installed around the Material app.
    return ShadApp.custom(
      theme: ShadThemeData(),
      appBuilder: (context) => MaterialApp(
        title: 'Serverpod Starguide',
        theme: createTheme(),
        localizationsDelegates: const [GlobalShadLocalizations.delegate],
        builder: (context, child) => ShadAppBuilder(child: child!),
        home: const StarguideChatPage(),
      ),
    );
  }
}

class StarguideChatPage extends StatefulWidget {
  const StarguideChatPage({super.key});

  @override
  StarguideChatPageState createState() => StarguideChatPageState();
}

class StarguideChatPageState extends State<StarguideChatPage> {
  final _uuid = Uuid();
  final ChatController _chatController = InMemoryChatController();

  static const _userId = 'user';
  static const _modelId = 'model';

  final _user = const User(id: _userId);
  final _model = const User(id: _modelId);

  ChatSession? _chatSession;

  /// The chat session being created, started as soon as the user focuses the
  /// input so that it is ready when the first question is sent.
  Future<ChatSession>? _chatSessionFuture;

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

  /// Whether the admin interface is shown instead of the chat.
  bool _showAdmin = false;

  /// Whether the signed in user has the admin scope. The scope is granted by
  /// the server to serverpod.dev accounts.
  bool get _isAdmin =>
      sessionManager.authInfo?.scopeNames.contains(kAdminScopeName) ?? false;

  late final GoogleAuthController _googleAuthController;

  @override
  void initState() {
    super.initState();

    _googleAuthController = GoogleAuthController(
      client: client,
      onError: (error) {
        debugPrint('Google sign-in failed: $error');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed. Please try again.')),
        );
      },
    );

    _inputTextController.addListener(() {
      setState(() {
        _hasInputText = _inputTextController.text.isNotEmpty;
      });
    });

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
      if (_inputFocusNode.hasFocus) _prepareChatSession();
    });

    // Check if there is an initial query in the URL.
    final uri = Uri.base;
    final query = uri.queryParameters;
    if (query.containsKey('q')) {
      _inputTextController.text = query['q']!;
      _handleMessageSend(_inputTextController.text);
      _inputTextController.clear();
    }

    sessionManager.authInfoListenable.addListener(() {
      setState(() {
        if (sessionManager.isAuthenticated) {
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
    _googleAuthController.dispose();
    _inputTextController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    try {
      await _googleAuthController.signIn();
    } catch (e) {
      // Errors during the sign-in flow itself are reported through the
      // controller's onError callback. This catches platforms where Google
      // sign-in is not supported at all.
      debugPrint('Google sign-in is unavailable: $e');
    }
  }

  void _sendMessage(String text) async {
    setState(() {
      _isGeneratingResponse = true;
      _numChatRequests += 1;
    });

    // Set up a new chat session, if we haven't started one already.
    try {
      _chatSession ??= await _getChatSession();

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
        if (_currentResponse == null) {
          return;
        }
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
      _chatSessionFuture = null;
      setState(() {
        _recaptchaError = true;
        _connectionError = true;
      });
      return;
    } catch (e) {
      _chatSessionFuture = null;
      setState(() {
        _connectionError = true;
        _connectionErrorMessage = 'Error: $e';
      });
      return;
    }
  }

  /// The chat session, created on the first call. The reCAPTCHA check and
  /// the request to the server are only made once, even if this is called
  /// again while they are in progress.
  Future<ChatSession> _getChatSession() {
    return _chatSessionFuture ??= () async {
      final token = kIsWeb
          ? (await GRecaptchaV3.execute('create_chat_session'))!
          : '';
      return client.starguide.createChatSession(token);
    }();
  }

  /// Starts creating the chat session ahead of the first question. A failure
  /// is dropped here and reported when the question is sent, which tries
  /// again.
  Future<void> _prepareChatSession() async {
    if (_chatSession != null || _chatSessionFuture != null) return;
    try {
      _chatSession ??= await _getChatSession();
    } catch (_) {
      _chatSessionFuture = null;
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
      _chatSessionFuture = null;
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
    final isNarrow = MediaQuery.sizeOf(context).width < kNarrowScreenWidth;

    // The admin interface replaces the chat. Signing out drops the scope,
    // which brings the chat back.
    if (_showAdmin && _isAdmin) {
      return AdminPage(onClose: () => setState(() => _showAdmin = false));
    }

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
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
                    textMessageBuilder:
                        (
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
                                label: Text(isNarrow ? 'Clear' : 'Clear Chat'),
                                icon: Icon(LucideIcons.refreshCw),
                              ),
                              Spacer(),
                              TextButton.icon(
                                onPressed: _chatSession != null
                                    ? _handleUpvote
                                    : null,
                                label: Text(isNarrow ? 'Good' : 'Got Help'),
                                icon: Icon(
                                  LucideIcons.thumbsUp,
                                  color: _vote == true
                                      ? Colors.blue.shade600
                                      : null,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _chatSession != null
                                    ? _handleDownvote
                                    : null,
                                label: Text(isNarrow ? 'Bad' : 'Poor Answer'),
                                icon: Icon(
                                  LucideIcons.thumbsDown,
                                  color: _vote == false
                                      ? Colors.blue.shade600
                                      : null,
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
                          enabled:
                              _hasInputText &&
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
                      isNarrow ? starguideVersion : 'Version $starguideVersion',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isNarrow)
                      TextButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse('https://github.com/serverpod/starguide'),
                          );
                        },
                        child: Text(
                          'View Source',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    if (_isAdmin)
                      TextButton(
                        onPressed: () => setState(() => _showAdmin = true),
                        child: Text(
                          'Admin',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    if (!sessionManager.isAuthenticated)
                      ListenableBuilder(
                        listenable: _googleAuthController,
                        builder: (context, _) => TextButton(
                          onPressed: _googleAuthController.isLoading
                              ? null
                              : _handleSignIn,
                          child: Text(
                            'Sign In',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                    Spacer(),
                    if (!sessionManager.isAuthenticated)
                      Text(
                        'Protected by ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    if (!sessionManager.isAuthenticated)
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
                              child: StarguideMarkdown(
                                'This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.',
                                style: theme.textTheme.bodySmall,
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
                    if (sessionManager.isAuthenticated)
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
        ),
      ),
    );
  }
}
