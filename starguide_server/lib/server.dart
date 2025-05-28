import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/future_calls/fetch_data_future_call.dart';

import 'package:starguide_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  pod.registerFutureCall(FetchDataFutureCall(), 'fetchDataFutureCall');

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  // Start the server.
  await pod.start();

  // Start fetching data.
  pod.futureCallWithDelay(
    'fetchDataFutureCall',
    null,
    const Duration(),
  );
}
