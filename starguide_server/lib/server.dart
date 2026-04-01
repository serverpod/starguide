import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;
import 'package:starguide_server/src/web/routes/root.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';

void run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  await configureDataFetcher();

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  pod.webServer.addRoute(RouteRoot(), '/app/index.html');

  // Setup a Google sign in route.
  pod.webServer.addRoute(auth.RouteGoogleSignIn(), '/googlesignin');
  // Serve all files in the /static directory.

  pod.webServer.addRoute(
    StaticRoute.directory(
      Directory('web/app'),
      cacheControlFactory: (ctx, fileInfo) {
        if (fileInfo.file.path.endsWith('flutter_service_worker.js') ||
            fileInfo.file.path.endsWith('flutter_bootstrap.js') ||
            fileInfo.file.path.endsWith('manifest.json') ||
            fileInfo.file.path.endsWith('version.json')) {
          return CacheControlHeader(
            maxAge: 0,
            noCache: true,
            mustRevalidate: true,
          );
        }
        return CacheControlHeader(
          maxAge: 31536000, // 1 year - safe with cache busting
          publicCache: true,
          immutable: true,
        );
      },
    ),
    '/',
  );

  // Start the server.
  await pod.start();

  // Start fetching data.
  await pod.futureCalls
      .callWithDelay(const Duration())
      .dataFetcher
      .startFetching();
}
