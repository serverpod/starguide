import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';

import 'package:starguide_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

/// Bootstraps and starts the Starguide Serverpod instance.
///
/// Sets up routes, configures the data fetcher, and then starts the
/// Serverpod service. This function is the main entrypoint of the server
/// application.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with the generated protocol and
  // endpoints from the `serverpod generate` command.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Prepare the data fetcher that downloads and caches external content.
  configureDataFetcher();
  DataFetcher.instance.register(pod);

  // Setup default routes for serving a simple landing page and the web app.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  // Serve all files in the /static directory such as Flutter web builds.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'app', basePath: '/'),
    '/*',
  );

  // Start the Serverpod backend.
  await pod.start();

  // Begin periodic data fetching jobs.
  await DataFetcher.instance.startFetching(pod);
}
