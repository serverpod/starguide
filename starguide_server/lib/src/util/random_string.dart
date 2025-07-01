import 'dart:math';

String generateRandomString(int length) {
  final Random secureRandom = Random.secure();
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(chars[secureRandom.nextInt(chars.length)]);
  }

  return buffer.toString();
}
