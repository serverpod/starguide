# Serverpod framework info
Provides foundational knowledge, best practices, and usage patterns for developing backends with the Serverpod framework. This is a great starting point and links to other relevant resources..

Serverpod is an open-source framework for building backends for Flutter apps in Dart. Serverpod connects to a Postgres database using its type-safe ORM. Typically, the project is set up in three different Dart packages in a monorepo:

- `<projectname>_server` contains all the server code.
- `<projectname>_client` contains generated client code used by the Flutter app.
- `<projectname>_flutter` contains a Flutter app that connects to the server through the client.

The resources include files for most common use cases and best practices. You can ask any question using the "ask-docs" tool, you will get a response based upon the full documentation and answered GitHub discussions.

## Data models
Serverpod has support for data models, which are using a custom YAML with the `.spy.yaml` extension. The models can be placed anywhere in the server package. Whenever a data model has been modified, we need to run the `serverpod generate` command to bring all Dart files up-to-date. Here is a very simple example of a model:

```spy.yaml
class: MyClass
fields:
  myInteger: int
  myNullableString: String?
```

Models can also provide bindings to the database (ORM). For more information on how to write and work with data models, please see the `Data models` resource.

## Endpoints and RPC
Create endpoint classes anywhere on the server.

- Must import `package:serverpod/serverpod.dart`.
- Extend `Endpoint`.
- Add methods returning a typed `Future`, first parameter must be of type `Session`.
- Supported return types (in a Future): and parameter types: `bool, int, double, String, Duration, DateTime, ByteData, UuidValue, Uri, BigInt, Vector`, plus other models, enums, serializable exceptions, typed `List`, `Map`, `Set`. Null safety supported. Can return Dart records.
- After adding/removing/modifying an endpoint, `serverpod generate` must be run.

### Basic method

```dart
import 'package:serverpod/serverpod.dart';

class ExampleEndpoint extends Endpoint {
  Future<String> hello(Session session, String name) async {
    return 'Hello $name';
  }
}
```

Method can now be called from Flutter app using:
```dart
final result = await client.example.hello('World');
```

The `client` object must be imported from the `main.dart` file in the Flutter app.

### Streaming data

- To stream data from the server, you can return a `Stream` instead of a `Future`.
- Streams can be typed (all types above supported, except `List`, `Map`, `Set`), or dynamic.

```dart
import 'package:serverpod/serverpod.dart';

class ExampleEndpoint extends Endpoint {
  Stream echoStream(Session session, Stream stream) async* {
    await for (var message in stream) {
      yield message;
    }
  }
}
```

## Adding or modifying a feature
Follow these steps:

1. Figure out which data models need to be created or modified (check the `Data Models` resource for reference).
2. Run `serverpod generate` or ask the user to run it.
3. If any changes has been made to database connected models, run `serverpod create-migration`
3. Add or modify endpoints and business logic (see the `Working with endpoints` resource for reference).

