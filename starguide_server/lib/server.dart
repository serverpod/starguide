import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:starguide_server/src/business/admin_scope.dart';
import 'package:starguide_server/src/business/data_fetcher_scheduling.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';
import 'package:starguide_server/src/web/routes/app_config_route.dart';

import 'src/generated/serverpod.dart';

void run(List<String> args) async {
  final pod = Serverpod(args);

  // Set up authentication. Users sign in with Google and are issued JWT
  // tokens. Without Google OAuth client credentials, the server still runs
  // but Google sign-in is unavailable.
  final googleClientSecret = _loadGoogleClientSecret(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      if (googleClientSecret != null)
        GoogleIdpConfig(
          clientSecret: googleClientSecret,
          // Users signing up with a serverpod.dev account are made admins.
          onAfterGoogleAccountCreated: grantAdminScopeToServerpodAccounts,
        ),
    ],
  );

  await configureDataFetcher();

  // Callback page for the Google sign-in flow on web. It is served on the
  // same origin as the Flutter web app, and its URL is registered as an
  // authorized redirect URI on the Google OAuth client.
  pod.webServer.addRoute(FlutterWebAuth2CallbackRoute(), '/googlesignin');

  // Serve the app configuration to the Flutter web app. It is built from the
  // server's API configuration, so the app connects to the API server of the
  // environment it is served from.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Google Sign-In uses a popup flow that requires this less restrictive COOP
  // value than the default set by FlutterRoute's WASM headers middleware.
  pod.webServer.addMiddleware(_googleSignInCoopMiddleware, '/');

  // Serve the Flutter web app if it has been built, otherwise a page with
  // build instructions.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(FlutterRoute(appDir), '/');
  } else {
    pod.webServer.addRoute(
      StaticRoute.file(
        File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath()),
      ),
      '/**',
    );
  }

  // Start the server.
  await pod.start();

  // Keep the data sources up to date with recurring future calls.
  await scheduleDataFetching(pod);
}

/// Loads the Google OAuth client credentials, or returns null if they are not
/// configured.
///
/// The credentials are read from the JSON file downloaded from the Google
/// Cloud console when it is present, which is the case in local development.
/// The file is not deployed to Serverpod Cloud, where the same JSON is instead
/// provided as the `serverpod_auth_googleClientSecret` password.
GoogleClientSecret? _loadGoogleClientSecret(Serverpod pod) {
  final file = File(
    pod.serverDirectory.uri
        .resolve('config/google_client_secret.json')
        .toFilePath(),
  );
  if (file.existsSync()) {
    return GoogleClientSecret.fromJsonFile(file);
  }

  final json = pod.getPassword('serverpod_auth_googleClientSecret');
  if (json != null) {
    return GoogleClientSecret.fromJsonString(json);
  }

  stderr.writeln(
    'WARNING: Neither ${file.path} nor the serverpod_auth_googleClientSecret '
    'password is available. Google sign-in is disabled.',
  );
  return null;
}

Handler _googleSignInCoopMiddleware(Handler next) {
  return (Request request) async {
    final result = await next(request);

    if (result is Response) {
      return result.copyWith(
        headers: result.headers.transform((headers) {
          headers.crossOriginOpenerPolicy =
              CrossOriginOpenerPolicyHeader.sameOriginAllowPopups;
        }),
      );
    }

    return result;
  };
}
