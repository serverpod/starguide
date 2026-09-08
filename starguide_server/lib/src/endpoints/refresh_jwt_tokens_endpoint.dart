import 'package:serverpod_auth_idp_server/core.dart' as core;

/// Exposes the JWT refresh endpoint so clients can renew expired access
/// tokens without signing in again.
class RefreshJwtTokensEndpoint extends core.RefreshJwtTokensEndpoint {}
