import 'package:serverpod/serverpod.dart';

/// Configuration served to the Flutter web app, so that the app connects to
/// the API server of the environment it is served from.
class AppConfigWidget extends JsonWidget {
  final String apiUrl;

  AppConfigWidget({required this.apiUrl}) : super(object: {'apiUrl': apiUrl});
}

/// Serves the app configuration in place of the `assets/config.json` asset
/// bundled with the Flutter web app.
class AppConfigRoute extends WidgetRoute {
  final AppConfigWidget widget;

  AppConfigRoute({required final ServerConfig apiConfig})
    : widget = AppConfigWidget(apiUrl: apiConfig.apiUrl.toString());

  @override
  Future<WebWidget> build(Session session, Request request) async {
    return widget;
  }
}

extension on ServerConfig {
  Uri get apiUrl =>
      Uri(scheme: publicScheme, host: publicHost, port: publicPort);
}
