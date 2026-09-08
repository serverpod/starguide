import 'package:starguide_server/src/business/admin_scope.dart';
import 'package:test/test.dart';

void main() {
  group('Given isAdminEmail', () {
    test('when called with an address on serverpod.dev then returns true', () {
      expect(isAdminEmail('alice@serverpod.dev'), isTrue);
    });

    test('when the domain uses different casing then returns true', () {
      expect(isAdminEmail('alice@Serverpod.DEV'), isTrue);
    });

    test(
      'when called with an address on another domain then returns false',
      () {
        expect(isAdminEmail('alice@example.com'), isFalse);
      },
    );

    test('when the domain only ends with serverpod.dev then returns false', () {
      expect(isAdminEmail('alice@notserverpod.dev'), isFalse);
      expect(isAdminEmail('alice@serverpod.dev.example.com'), isFalse);
    });

    test('when the local part contains serverpod.dev then returns false', () {
      expect(isAdminEmail('serverpod.dev@example.com'), isFalse);
    });

    test('when called with a string without @ then returns false', () {
      expect(isAdminEmail('serverpod.dev'), isFalse);
      expect(isAdminEmail(''), isFalse);
    });
  });
}
