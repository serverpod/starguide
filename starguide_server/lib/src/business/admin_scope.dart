import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Domain of the Google accounts that are granted admin access.
const adminEmailDomain = 'serverpod.dev';

/// Whether [email] belongs to an account on the [adminEmailDomain].
bool isAdminEmail(String email) {
  final atIndex = email.lastIndexOf('@');
  if (atIndex < 0) return false;
  return email.substring(atIndex + 1).toLowerCase() == adminEmailDomain;
}

/// Grants [Scope.admin] to users who create their account by signing in with
/// a Google account on the [adminEmailDomain].
///
/// This is invoked by the Google identity provider once a new Google account
/// has been linked to an auth user. Google reports whether the email address
/// is verified, and the identity provider's default account validation
/// rejects accounts with unverified addresses, so the domain of the email can
/// be trusted here.
///
/// Note that the token issued for the sign-in that created the account is
/// built from the scopes of the user before this callback runs. The admin
/// scope is included in tokens issued on subsequent sign-ins.
Future<void> grantAdminScopeToServerpodAccounts(
  Session session,
  AuthUserModel authUser,
  GoogleAccount googleAccount, {
  required Transaction? transaction,
}) async {
  if (!isAdminEmail(googleAccount.email)) return;

  await AuthServices.instance.authUsers.update(
    session,
    authUserId: authUser.id,
    scopes: {...authUser.scopes, Scope.admin},
    transaction: transaction,
  );
  session.log(
    'Granted the admin scope to new user ${authUser.id} '
    '(${googleAccount.email}).',
  );
}
