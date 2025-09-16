import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';

import 'package:starguide_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  configureDataFetcher();
  DataFetcher.instance.register(pod);

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');

  // Setup a Google sign in route.
  pod.webServer.addRoute(auth.RouteGoogleSignIn(), '/googlesignin');
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'app', basePath: '/'),
    '/*',
  );

  // Start the server.
  await pod.start();

  // Start fetching data.
  await DataFetcher.instance.startFetching(pod);
}
