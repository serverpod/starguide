import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// Verifies a reCAPTCHA token with Google's verification service.
/// Throws [RecaptchaException] if verification fails.
/// [token] is the response token from the client.
Future<double> verifyRecaptchaToken(
  Session session, {
  required String token,
  required String expectedAction,
}) async {
  final uri = Uri.parse('https://www.google.com/recaptcha/api/siteverify');
  final secret = Serverpod.instance.getPassword('recaptchaSecretKey')!;

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'secret': secret,
      'response': token,
    },
  );

  if (response.statusCode != 200) {
    session.log(
      'Failed to verify reCAPTCHA: HTTP ${response.statusCode}',
      level: LogLevel.debug,
    );
    throw RecaptchaException();
  }

  final Map<String, dynamic> result = json.decode(response.body);
  final bool success = result['success'] ?? false;
  final double score = (result['score'] ?? 0.0).toDouble();
  final String action = result['action'] ?? '';

  if (!success) {
    session.log(
      'reCAPTCHA verification failed: ${result['error-codes']}',
      level: LogLevel.debug,
    );
    throw RecaptchaException();
  }

  if (action != expectedAction) {
    session.log(
      'reCAPTCHA verification failed: action mismatch',
      level: LogLevel.debug,
    );
    throw RecaptchaException();
  }

  return score;
}
