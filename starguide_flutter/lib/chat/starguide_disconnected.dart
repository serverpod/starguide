import 'package:flutter/material.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:starguide_flutter/main.dart';

class StarguideDisconnected extends StatelessWidget {
  const StarguideDisconnected({
    super.key,
    required this.onReconnect,
    required this.recaptchaError,
  });

  final VoidCallback onReconnect;
  final bool recaptchaError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 256,
              height: 256,
              child: Image.asset(
                recaptchaError
                    ? 'assets/robot.webp'
                    : 'assets/disconnected.webp',
              ),
            ),
            const SizedBox(height: 16),
            Text(recaptchaError
                ? 'Are you a robot? Please sign in to access Starguide.'
                : 'Oops. Something went wrong.'),
            const SizedBox(height: 32),
            if (!recaptchaError)
              OutlinedButton(
                onPressed: onReconnect,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Try Again'),
                ),
              ),
            if (recaptchaError)
              SignInWithGoogleButton(
                caller: client.modules.auth,
                redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
                serverClientId:
                    '228196660760-93k92hcfke8ettcokvm7hdtm2uq19je0.apps.googleusercontent.com',
              ),
          ],
        ),
      ),
    );
  }
}
