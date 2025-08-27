# Working with endpoints
This document provides detailed information and best practices about how to create endpoints, add methods, and query the database.

## Endpoints

Endpoints are the server connection points for clients. Add methods to an endpoint and Serverpod generates client code automatically. Place endpoint files under `lib` and extend `Endpoint`. Methods must return a typed `Future` and take a `Session` as the first parameter.

```dart
import 'package:serverpod/serverpod.dart';

class ExampleEndpoint extends Endpoint {
  Future<String> hello(Session session, String name) async {
    return 'Hello $name';
  }
}
```

This creates an `example` endpoint with a `hello` method. Generate client code with:

```bash
serverpod generate
```

### Client usage

```dart
var result = await client.example.hello('World');

var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();
```

The `client` is typically defined in the `main` file. Import and reference that.

## Parameters & Return Types

Methods support `bool`, `int`, `double`, `String`, `UuidValue`, `Duration`, `DateTime` (UTC), `ByteData`, `Uri`, `BigInt`, and generated serializable objects. Collections (`List`, `Map`, `Set`, `Record`) must be strictly typed. Return types must be typed `Future`s.

## Overview and best practices

* Endpoints in Serverpod is public to everyone unless you set the `requireLogin` property to `true` or set the `requiredScopes` property.
* When creating an endpoint, always consider which scopes should be required.
* Always use best practices for software engineering and avoid taking shortcuts.

## Restricting access to Endpoint

### Require login

```dart
class ExampleEndpoint extends Endpoint {
  // Endpoint cannot be accessed without being signed in.
  @override
  bool requireLogin = true;

  Future<String> hello(Session session, String name) async {
    return 'Hello $name';
  }
}
```

### Require login & a specified scope
```dart
class ExampleEndpoint extends Endpoint {
  // Endpoint cannot be accessed without being signed in and have the `admin` scope.
  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<String> hello(Session session, String name) async {
    return 'Hello $name';
  }
}
```

- The `Scope.admin` is provided by default.

## Ignoring Endpoints

Annotate classes or methods with `@doNotGenerate` to skip code generation.

```dart
@doNotGenerate
class ExampleEndpoint extends Endpoint {
  Future<String> hello(Session session, String name) async => 'Hello $name';
}
```

```dart
class ExampleEndpoint extends Endpoint {
  Future<String> hello(Session session, String name) async => 'Hello $name';

  @doNotGenerate
  Future<String> goodbye(Session session, String name) async => 'Bye $name';
}
```

## Inheritance

Subclass endpoints to extend or override behavior.

```dart
class CalculatorEndpoint extends Endpoint {
  Future<int> add(Session session, int a, int b) async => a + b;
}

class MyCalculatorEndpoint extends CalculatorEndpoint {
  Future<int> subtract(Session session, int a, int b) async => a - b;
}
```

### Abstract endpoints

Abstract endpoints are not exposed directly, but subclasses are.

```dart
abstract class CalculatorEndpoint extends Endpoint {
  Future<int> add(Session session, int a, int b) async => a + b;
}

class MyCalculatorEndpoint extends CalculatorEndpoint {}
```

### Overriding methods

```dart
abstract class GreeterBaseEndpoint extends Endpoint {
  Future<String> greet(Session session, String name) async => 'Hello $name';
}

class ExcitedGreeterEndpoint extends GreeterBaseEndpoint {
  @override
  Future<String> greet(Session session, String name) async {
    return '${super.greet(session, name)}!!!';
  }
}
```

### Hiding & Unhiding Methods

Hide methods in subclasses with `@doNotGenerate` or override ignored methods to expose them.

```dart
class AdderEndpoint extends CalculatorEndpoint {
  @doNotGenerate
  Future<int> subtract(Session session, int a, int b) async => throw UnimplementedError();
}
```

```dart
class MyCalculatorEndpoint extends CalculatorEndpoint {
  @override
  Future<BigInt> addBig(Session session, BigInt a, BigInt b) async => super.addBig(session, a, b);
}
```

## Base Endpoints for Behavior

Configure shared behavior via base classes.

```dart
abstract class LoggedInEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
}

abstract class AdminEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {Scope.admin};
}
```


# Streams

Serverpod supports real-time data streaming for use cases like chat apps or games. Any serializable object can be streamed to/from endpoints.

## Streaming Methods

Define methods with `Stream` as return type or parameter to create streaming methods. They use a shared web socket managed by Serverpod.

```dart
class ExampleEndpoint extends Endpoint {
  Stream echoStream(Session session, Stream stream) async* {
    await for (var message in stream) {
      yield message;
    }
  }
}
```

### Client usage

```dart
var inStream = StreamController();
var outStream = client.example.echoStream(inStream.stream);
outStream.listen((message) {
  print('Received: $message');
});

inStream.add('Hello');
inStream.add(42);
```

Supports generics like `Stream<String>`. Dynamic streams can mix serializable types.

### Lifecycle

* Each call creates a `Session`.
* Streams close when subscription ends or stream closes.
* Lost web socket connection closes all streams.

### Authentication

Authentication is automatic. Revoked auth closes streams and throws an exception.

### Error Handling

Exceptions are serialized and passed through the stream in both directions.

```dart
class ExampleEndpoint extends Endpoint {
  Stream echoStream(Session session, Stream stream) async* {
    stream.listen((_) {}, onError: (error) {
      throw SerializableException('Error from server');
    });
  }
}

var inStream = StreamController();
var outStream = client.example.echoStream(inStream.stream);
outStream.listen((_) {}, onError: (error) {
  print('Client error: $error');
});

inStream.addError(SerializableException('Error from client'));
```

## Streaming Endpoints (Legacy)

Manual WebSocket management.

### Server-side

Override:

* `streamOpened`
* `streamClosed`
* `handleStreamMessage`

Send messages with `sendStreamMessage(session, message)`.

```dart
Future<void> streamOpened(StreamingSession session) async {
  setUserObject(session, MyUserObject());
}
```

### Client-side

```dart
await client.openStreamingConnection();

await for (var message in client.myEndpoint.stream) {
  _handleMessage(message);
}

client.myEndpoint.sendStreamMessage(MyMessage(text: 'Hello'));
```

Authentication is automatic for WebSocket connections.

# The Session object
The session provides access to:
- The database
- Logging
- Caching
- Internal messaging

## Log messages

```dart
session.log(
  'Oops, something went wrong',
  level: LogLevel.warning, // optional (default: info, available: debug, info, warning, error)
  exception: e, // optional
  stackTrace: stackTrace, // optional
);
```

## Caching example

Typical usage:

```dart
Future<UserData> getUserData(Session session, int userId) async {
  // Define a unique key for the UserData object
  var cacheKey = 'UserData-$userId';

  // Try to retrieve the object from the cache
  var userData = await session.caches.local.get(
    cacheKey,
    // If the object wasn't found in the cache, load it from the database and
    // save it in the cache. Make it valid for 5 minutes.
    CacheMissHandler(
      () async => UserData.db.findById(session, userId),
      lifetime: Duration(minutes: 5),
    ),
    );

  // Return the user data to the client
  return userData;
}
```

Alternative way:

```dart
Future<UserData> getUserData(Session session, int userId) async {
  // Define a unique key for the UserData object
  var cacheKey = 'UserData-$userId';

  // Try to retrieve the object from the cache
  var userData = await session.caches.local.get<UserData>(cacheKey);

  // If the object wasn't found in the cache, load it from the database and
  // save it in the cache. Make it valid for 5 minutes.
  if (userData == null) {
    userData = UserData.db.findById(session, userId);
    await session.caches.local.put(cacheKey, userData!, lifetime: Duration(minutes: 5));
  }

  // Return the user data to the client
  return userData;
}
```

# Database queries

## CRUD

All database operations require a `Session` object. Generated models expose CRUD via their static `db` field.

```yaml
class: Company
table: company
fields:
  name: String
```

### Create

#### Insert single row

```dart
var row = Company(name: 'Serverpod');
var company = await Company.db.insertRow(session, row);
```

#### Insert multiple rows

```dart
var rows = [Company(name: 'Serverpod'), Company(name: 'Google')];
var companies = await Company.db.insert(session, rows);
```

### Read

#### Find by id

```dart
var company = await Company.db.findById(session, companyId);
```

#### Find first row

```dart
var company = await Company.db.findFirstRow(
  session,
  where: (t) => t.name.equals('Serverpod'),
);
```

#### Find multiple rows

```dart
var companies = await Company.db.find(
  session,
  where: (t) => t.id < 100,
  limit: 50,
);
```

### Update

#### Update single row

```dart
var company = await Company.db.findById(session, companyId);
company.name = 'New name';
var updatedCompany = await Company.db.updateRow(session, company);
```

#### Update multiple rows

```dart
var companies = await Company.db.find(session);
companies = companies.map((c) => c.copyWith(name: 'New name')).toList();
var updatedCompanies = await Company.db.update(session, companies);
```

#### Update specific columns

```dart
var company = await Company.db.findById(session, companyId);
company.name = 'New name';
company.address = 'Baker street';
var updatedCompany = await Company.db.updateRow(session, company, columns: (t) => [t.name]);
```

```dart
var companies = await Company.db.find(session);
companies = companies.map((c) => c.copyWith(name: 'New name', address: 'Baker Street')).toList();
var updatedCompanies = await Company.db.update(session, companies, columns: (t) => [t.name]);
```

### Delete

#### Delete single row

```dart
var company = await Company.db.findById(session, companyId);
var companyDeleted = await Company.db.deleteRow(session, company);
```

#### Delete multiple rows

```dart
var companiesDeleted = await Company.db.delete(session, companies);
```

#### Delete with filter

```dart
var companiesDeleted = await Company.db.deleteWhere(
  session,
  where: (t) => t.name.like('%Ltd'),
);
```

### Count

```dart
var count = await Company.db.count(
  session,
  where: (t) => t.name.like('s%'),
);
```


## Filter (creating queries)

Serverpod provides statically type-checked expressions using table descriptors (`t`). Use these with callbacks for the `where` parameter in queries.

### Column Operations

#### Equals / Not Equals

```dart
await User.db.find(
  session,
  where: (t) => t.name.equals('Alice')
);

await User.db.find(
  session,
  where: (t) => t.name.notEquals('Bob')
);
```

#### Comparisons

```dart
where: (t) => t.age > 25;
where: (t) => t.age >= 25;
where: (t) => t.age < 25;
where: (t) => t.age <= 25;
```

#### Between / Not Between

```dart
where: (t) => t.age.between(18, 65);
where: (t) => t.age.notBetween(18, 65);
```

#### In Set / Not In Set

```dart
where: (t) => t.name.inSet({'Alice', 'Bob'});
where: (t) => t.name.notInSet({'Alice', 'Bob'});
```

#### Like / Not Like

```dart
where: (t) => t.name.like('A%');
where: (t) => t.name.notLike('B%');
```

#### ILike / Not ILike (case-insensitive)

```dart
where: (t) => t.name.ilike('a%');
where: (t) => t.name.notIlike('b%');
```

#### Logical Operators

```dart
where: (t) => (t.name.equals('Alice') & (t.age > 25));
where: (t) => (t.name.like('A%') | t.name.like('B%'));
```

#### Vector Distance

```dart
var queryVector = Vector([...]);
var docs = await Document.db.find(
  session,
  where: (t) => t.embedding.distanceCosine(queryVector) < 0.5,
  orderBy: (t) => t.embedding.distanceCosine(queryVector),
  limit: 10,
);
```

Supports `distanceL2`, `distanceInnerProduct`, `distanceCosine`, `distanceL1` for vectors and `distanceHamming`, `distanceJaccard` for bit vectors.

### Relation Operations

#### One-to-One

```dart
where: (t) => t.address.street.like('%road%');
```

#### One-to-Many

##### Count

```dart
where: (t) => t.orders.count() > 3;
where: (t) => t.orders.count((o) => o.itemType.equals('book')) > 3;
```

##### None

```dart
where: (t) => t.orders.none();
where: (t) => t.orders.none((o) => o.itemType.equals('book'));
```

##### Any

```dart
where: (t) => t.orders.any();
where: (t) => t.orders.any((o) => o.itemType.equals('book'));
```

##### Every

```dart
where: (t) => t.orders.every((o) => o.itemType.equals('book'));
```

## Relation Queries

Serverpod supports filtering, sorting, and including related objects via joins for [1:1](relations/one-to-one) and [1\:n](relations/one-to-many) relations.

### Include Relational Data

```dart
var employee = await Employee.db.findById(
  session,
  employeeId,
  include: Employee.include(
    address: Address.include(),
  ),
);
```

#### Nested Includes

```dart
var employee = await Employee.db.findById(
  session,
  employeeId,
  include: Employee.include(
    company: Company.include(
      address: Address.include(),
    ),
  ),
);
```

You can include multiple related objects with named parameters.

### Include Relational Lists (1\:n)

```dart
var company = await Company.db.findById(
  session,
  companyId,
  include: Company.include(
    employees: Employee.includeList(),
  ),
);
```

#### Nested Lists

```dart
var company = await Company.db.findById(
  session,
  companyId,
  include: Company.include(
    employees: Employee.includeList(
      includes: Employee.include(
        address: Address.include(),
      ),
    ),
  ),
);
```

Lists can include other lists:

```dart
var company = await Company.db.findById(
  session,
  companyId,
  include: Company.include(
    employees: Employee.includeList(
      includes: Employee.include(
        tools: Tool.includeList(),
      ),
    ),
  ),
);
```

#### Filter & Sort

```dart
var company = await Company.db.findById(
  session,
  companyId,
  include: Company.include(
    employees: Employee.includeList(
      where: (t) => t.name.ilike('a%'),
      orderBy: (t) => t.name,
    ),
  ),
);
```

#### Pagination

```dart
var company = await Company.db.findById(
  session,
  companyId,
  include: Company.include(
    employees: Employee.includeList(
      limit: 10,
      offset: 10,
    ),
  ),
);
```

### Update Relationships

#### Attach Row

```dart
var company = await Company.db.findById(session, companyId);
var employee = await Employee.db.findById(session, employeeId);
await Company.db.attachRow.employees(session, company!, employee!);
```

#### Bulk Attach

```dart
await Company.db.attach.employees(session, company!, [employee!]);
```

#### Detach Row

```dart
await Company.db.detachRow.employees(session, employee!);
```

#### Bulk Detach

```dart
await Company.db.detach.employees(session, [employee!]);
```

## Sort

Use the `orderBy` parameter in `find` to sort query results.

```dart
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.name,
);
```

### Descending Order

```dart
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.name,
  orderDescending: true,
);
```

### Multiple Columns

Use `orderByList` for sorting on multiple fields:

```dart
var companies = await Company.db.find(
  session,
  orderByList: (t) => [
    Order(column: t.name, orderDescending: true),
    Order(column: t.id),
  ],
);
```

## Sort on Relations

### Related Field

```dart
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.ceo.name,
);
```

### Count of Related List

```dart
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.employees.count(),
);
```

### Filtered Count

```dart
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.employees.count(
    (employee) => employee.role.equals('developer'),
  ),
);
```

## Transactions

Transactions bundle multiple DB operations into one atomic action. Use `session.db.transaction` with a callback; commit happens on success, rollback on exception.

```dart
var result = await session.db.transaction((transaction) async {
  await Company.db.insertRow(session, company, transaction: transaction);
  await Employee.db.insertRow(session, employee, transaction: transaction);
  return true;
});
```

### Isolation Levels

Set isolation with `TransactionSettings`:

```dart
await session.db.transaction(
  (transaction) async {
    await Company.db.insertRow(session, company, transaction: transaction);
    await Employee.db.insertRow(session, employee, transaction: transaction);
  },
  settings: TransactionSettings(isolationLevel: IsolationLevel.serializable),
);
```

Available levels:

* `readUncommitted`
* `readCommitted`
* `repeatableRead`
* `serializable`

### Savepoints

Mark points inside transactions to roll back to later.

#### Create Savepoint

```dart
await session.db.transaction((transaction) async {
  await Company.db.insertRow(session, company, transaction: transaction);
  var savepoint = await transaction.createSavepoint();
  await Employee.db.insertRow(session, employee, transaction: transaction);
});
```

#### Rollback to Savepoint

```dart
await session.db.transaction((transaction) async {
  await Company.db.insertRow(session, company, transaction: transaction);
  var savepoint = await transaction.createSavepoint();
  await Employee.db.insertRow(session, employee, transaction: transaction);
  await savepoint.rollback();
});
```

#### Release Savepoint

```dart
await session.db.transaction((transaction) async {
  var savepoint = await transaction.createSavepoint();
  var secondSavepoint = await transaction.createSavepoint();
  await Company.db.insertRow(session, company, transaction: transaction);
  await savepoint.release();
});
```

## Pagination

Serverpod supports pagination with `limit` and `offset`.

### Limit

```dart
var companies = await Company.db.find(
  session,
  limit: 10,
);
```

### Offset

```dart
var companies = await Company.db.find(
  session,
  limit: 10,
  offset: 30,
);
```

### Combined Pagination

```dart
int page = 3;
int perPage = 10;
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.id,
  limit: perPage,
  offset: (page - 1) * perPage,
);
```

#### Tips

* Use `orderBy` for consistent pages.
* `offset` can be inefficient on very large datasets; indexed filters can help.

### Cursor-Based Pagination

Use a unique cursor (e.g., `id`) instead of offset for dynamic datasets.

#### Initial Request

```dart
int recordsPerPage = 10;
var companies = await Company.db.find(
  session,
  orderBy: (t) => t.id,
  limit: recordsPerPage,
);
```

#### Subsequent Requests

```dart
int cursor = lastCompanyId;
var companies = await Company.db.find(
  session,
  where: Company.t.id > cursor,
  orderBy: (t) => t.id,
  limit: recordsPerPage,
);
```

#### Return Cursor

```dart
return {
  'data': companies,
  'lastCursor': companies.last.id,
};
```

#### Tips

* IDs or timestamps make good cursors.
* Match cursor with sort order.
* Fewer items than limit = end of dataset.

## Raw database access

Serverpod provides direct SQL execution methods for advanced cases. It's using Postgres SQL.

### unsafeQuery

Executes SQL with parameter binding. Returns `DatabaseResult`.

```dart
DatabaseResult result = await session.db.unsafeQuery(
  r'SELECT * FROM mytable WHERE id = @id',
  parameters: QueryParameters.named({'id': 1}),
);
```

### unsafeExecute

Executes SQL without returning rows. Returns number of affected rows.

```dart
int result = await session.db.unsafeExecute(
  r'DELETE FROM mytable WHERE id = @id',
  parameters: QueryParameters.named({'id': 1}),
);
```

### unsafeSimpleQuery

Uses simple query protocol (no parameter binding). **Use with caution.** Supports multiple statements.

```dart
DatabaseResult result = await session.db.unsafeSimpleQuery(
  r'SELECT * FROM mytable WHERE id = 1; SELECT * FROM othertable;'
);
```

### unsafeSimpleExecute

Simple query protocol for non-returning statements. **Use with caution.**

```dart
int result = await session.db.unsafeSimpleExecute(
  r'DELETE FROM mytable WHERE id = 1; DELETE FROM othertable;'
);
```

### Query Parameters

Use parameters to avoid SQL injection.

#### Named

```dart
var result = await db.unsafeQuery(
  r'SELECT id FROM apparel WHERE color = @color AND size = @size',
  QueryParameters.named({
    'color': 'green',
    'size': 'XL',
  }),
);
```

#### Positional

```dart
var result = await db.unsafeQuery(
  r'SELECT id FROM apparel WHERE color = $1 AND size = $2',
  QueryParameters.positional(['green', 'XL']),
);
```

**Tip:** Always use parameter binding. Avoid simple query methods unless required.
