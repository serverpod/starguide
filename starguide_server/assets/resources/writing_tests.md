# Writing tests
This document provides detailed information about how to write integration tests for Serverpod.

## Overview

Serverpod provides **feature-rich test tools** to easily test backends.

* Place integration tests in the server's `test/integration` directory.
* After updating any endpoints or models run `serverpod generate` to update generated code for the tests.

## Core API

### `withServerpod`

Basic example:

```dart
import 'package:test/test.dart';

// Import the generated file, it contains everything you need.
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
    test('when calling `hello` then should return greeting', () async {
      final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
      expect(greeting, 'Hello Michael');
    });
  });
}
```

Provides:

* `sessionBuilder`: Builds `Session` with `copyWith`:

  * `authentication` (default unauthenticated)
  * `enableLogging` (default `false`)
* `endpoints`: Call endpoints like production.

Build session:

```dart
Session session = sessionBuilder.build();
```

### Authentication Override

```dart
AuthenticationOverride.unauthenticated(); // Default
AuthenticationOverride.authenticationInfo(userId, {Scope('user')});
```

Example:

```dart
var authSession = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.authenticationInfo(1234, {Scope('user')}),
);
```

More advanced example:

```dart
withServerpod('Given AuthenticatedExample endpoint', (sessionBuilder, endpoints) {
  // Corresponds to an actual user id
  const int userId = 1234;

  group('when authenticated', () {
    var authenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication:
          AuthenticationOverride.authenticationInfo(userId, {Scope('user')}),
    );

    test('then calling `hello` should return greeting', () async {
      final greeting = await endpoints.authenticatedExample
          .hello(authenticatedSessionBuilder, 'Michael');
      expect(greeting, 'Hello, Michael!');
    });
  });

  group('when unauthenticated', () {
    var unauthenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.unauthenticated(),
    );

    test(
        'then calling `hello` should throw `ServerpodUnauthenticatedException`',
        () async {
      final future = endpoints.authenticatedExample
          .hello(unauthenticatedSessionBuilder, 'Michael');
      await expectLater(
          future, throwsA(isA<ServerpodUnauthenticatedException>()));
    });
  });
});
```

### Database Seeding

```dart
withServerpod('Given Products endpoint', (sessionBuilder, endpoints) {
  var session = sessionBuilder.build();

  setUp(() async {
    await Product.db.insert(session, [
    Product(name: 'Apple', price: 10),
    Product(name: 'Banana', price: 10)
    ]);
  });

  test('then calling `all` should return all products', () async {
    final products = await endpoints.products.all(sessionBuilder);
    expect(products, hasLength(2));
    expect(products.map((p) => p.name), contains(['Apple', 'Banana']));
  });
});
```

Default: all DB ops rolled back after each test.

## Configuration

`withServerpod(..., config)` options:

| Option                  | Default                       |
| ----------------------- | ----------------------------- |
| `applyMigrations`       | `true`                        |
| `enableSessionLogging`  | `false`                       |
| `rollbackDatabase`      | `RollbackDatabase.afterEach`  |
| `runMode`               | `ServerpodRunMode.test`       |
| `serverpodLoggingMode`  | `ServerpodLoggingMode.normal` |
| `serverpodStartTimeout` | `Duration(seconds: 30)`       |

Rollback modes:

```dart
enum RollbackDatabase { afterEach, afterAll, disabled }
```

* `afterAll`: Scenario tests
* `disabled`: Concurrent transactions (requires cleanup)

Example (endpoint method):

```dart
Future<void> concurrentTransactionCalls(
  Session session,
) async {
  await Future.wait([
    session.db.transaction((tx) => /*...*/),
    // Will throw `InvalidConfigurationException` if `rollbackDatabase` 
    // is not set to `RollbackDatabase.disabled` in `withServerpod`
    session.db.transaction((tx) => /*...*/),
  ]);
}
```

Example (test of endpoint):

```dart
withServerpod(
  'Given ProductsEndpoint when calling concurrentTransactionCalls',
  (sessionBuilder, endpoints) {
    tearDownAll(() async {
      var session = sessionBuilder.build();
      // If something was saved to the database in the endpoint,
      // for example a `Product`, then it has to be cleaned up!
      await Product.db.deleteWhere(
        session,
        where: (_) => Constant.bool(true),
      );
    });

    test('then should execute and commit all transactions', () async {
      var result =
          await endpoints.products.concurrentTransactionCalls(sessionBuilder);
      // ...
    });
  },
  rollbackDatabase: RollbackDatabase.disabled,
);
```

When setting `rollbackDatabase.disabled`, it may also be needed to pass the `--concurrency=1` flag to the dart test runner. Otherwise multiple tests might pollute each others database state:

```bash
dart test -t integration --concurrency=1
```

## Helpers & Exceptions

**Exceptions**:

* `ServerpodUnauthenticatedException`
* `ServerpodInsufficientAccessException`
* `ConnectionClosedException`
* `InvalidConfigurationException`

**Helper**:

```dart
/// Ensures async events complete before continuing..
Future<void> flushEventQueue();
```

Example:

```dart
var stream = endpoints.someEndoint.generatorFunction(session);
await flushEventQueue();
```

## Advanced Usage

### Separate Unit & Integration

```bash
dart test              # all
dart test -t integration   # integration only
dart test -x integration   # unit only
```

### Business Logic Without Endpoints

```dart
withServerpod('Given decreasing product quantity when quantity is zero', (
  sessionBuilder,
  _,
) {
  var session = sessionBuilder.build();

  setUp(() async {
    await Product.db.insertRow(session, [
      Product(
        id: 123,
        name: 'Apple',
        quantity: 0,
      ),
    ]);
  });

  test('then should throw `InvalidOperationException`',
      () async {
    var future = ProductsBusinessLogic.updateQuantity(
      session,
      id: 123,
      decrease: 1,
    );

    await expectLater(future, throwsA(isA<InvalidOperationException>()));
  });
});
```

### Multiple Users in Streams

Endpoint code:

```dart
class CommunicationExampleEndpoint {
  static const sharedStreamName = 'shared-stream';
  Future<void> postNumberToSharedStream(Session session, int number) async {
    await session.messages
        .postMessage(sharedStreamName, SimpleData(num: number));
  }

  Stream<int> listenForNumbersOnSharedStream(Session session) async* {
    var sharedStream =
        session.messages.createStream<SimpleData>(sharedStreamName);

    await for (var message in sharedStream) {
      yield message.num;
    }
  }
}
```

Test:

```dart
withServerpod('Given CommunicationExampleEndpoint', (sessionBuilder, endpoints) {
  const int userId1 = 1;
  const int userId2 = 2;

  test(
      'when calling postNumberToSharedStream and listenForNumbersOnSharedStream '
      'with different sessions then number should be echoed',
      () async {
    var userSession1 = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userId1,
        {},
      ),
    );
    var userSession2 = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userId2,
        {},
      ),
    );

    var stream =
        endpoints.testTools.listenForNumbersOnSharedStream(userSession1);
    // Wait for `listenForNumbersOnSharedStream` to execute up to its 
    // `yield` statement before continuing
    await flushEventQueue(); 

    await endpoints.testTools.postNumberToSharedStream(userSession2, 111);
    await endpoints.testTools.postNumberToSharedStream(userSession2, 222);

    await expectLater(stream.take(2), emitsInOrder([111, 222]));
  });
});
```

## Best Practices

* **Imports**:

```dart
import 'serverpod_test_tools.dart'; // Do
// Don't import `serverpod_test` directly.
import 'package:serverpod_test/serverpod_test.dart'; // Don't
```

* **DB Cleanup**: Skip unless rollback disabled.
* **Calling Endpoints**:

```dart
final greeting = await endpoints.example.hello(session, 'Michael');
```

* **Folder Structure**:

```
test/unit
test/integration
```
