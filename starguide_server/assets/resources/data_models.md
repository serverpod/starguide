# Data models
This document provides detailed information and best practices about how to create data models, and set up database tables and relations.

**Serverpod models** are YAML (`.spy.yaml`) files defining serializable data classes. These generate Dart code for both the client and server (and database support when mapped to tables).

Use `serverpod generate` to produce/update model code, and `serverpod create-migration` to generate database migrations based on changes. `serverpod create-migration` is only needed when data tables are added, removed, or modified.

## Overview and best practices

* All models can be serialized and deserialized.
* You can create models for basic classes, enums, and exceptions.
* If you create a model for an exception, it can be thrown server-side and caught in the Flutter app.
* Always use typed data where possible:
  * Use enums if there are multiple options.
  * Reference other models where appropriate.
  * Use database relations where appropriate.
  * Use Uri over String to reference URIs and URLs.
* When connecting a database table (using the `table` key), an `id` field is automatically created.
  * Never explicitly create an `id` field in a model.
* Always use best practices for software engineering and avoid taking shortcuts.

## Model Definitions

```spy.yaml
class: Example
fields:
  name: String
  createdAt: DateTime?
  tags: List<String>
```

Supported types: `bool, int, double, String, Duration, DateTime, ByteData, UuidValue, Uri, BigInt, Vector`, plus other models, enums, exceptions, typed `List`, `Map`, `Set`; null safety is supported.


## Server/Client Visibility

* Default: model and all fields are visible to both server and client.
* `serverOnly: true` → Model generated server-side only.
* Use `scope=serverOnly` per field.

```spy.yaml
class: Example
serverOnly: true
fields:
  name: String
  createdAt: DateTime?
  tags: List<String>
```

```spy.yaml
class: Example
fields:
  name: String
  secretTime: DateTime?, scope=serverOnly
  tags: List<String>
```


## Exceptions
* Models can be Dart exceptions.
* Throw on server → catch in Flutter app.
* Otherwise identical to other models.

```spy.yaml
exception: MyException
fields:
  message: String
  severity: LogLevel
```

### Enums

```spy.yaml
enum: Status
serialized: byName
# default value is optional
default: unknown
values:
  - unknown
  - active
  - archived
```

* `serialized`: `byIndex` (default) or `byName`.
* Using `byName` is recommended, always use for new models.
* If using `byIndex`, always add new values at the end and never remove values for backwards compatibility.
* Set `default:` to handle unknown values safely.


## Documentation in Models

Use `###` comments to include documentation for classes or fields:

```spy.yaml
### A user entity
class: User
fields:
  ### Username of the account
  username: String
```


## Generated Code Features

* `copyWith(...)`: deep copy with selective field updates.
* `toJson()` / `fromJson()`: auto-generated for serialization.
* **Extensions**: add custom methods via Dart extensions.


## Default Field Values

Configure default values when deserializing or persisting:

* `default`: fallback for both model and DB.
* `defaultModel`: only applies to code side.
* `defaultPersist`: only for DB side.

```spy.yaml
fields:
  date: DateTime, default=now
  oldDate: DateTime, default=2020-01-01T22:00:00.000Z
  duration: Duration, default=1d 2h 10min 30s 100ms
  count: int, defaultModel=1
  name: String, defaultPersist="My Name"
  doubleWithDefault: double, default=10.5

```

**Priority:**

* Model uses `defaultModel` > `default`
* DB uses `defaultPersist` > `default`

If `defaultModel` or `default` is set, that value is written at insert, ignoring `defaultPersist`.


## Mapping Models to Database Tables

Add `table:` to enable ORM support:

```spy.yaml
class: Company
table: company
fields:
  name: String
```

* Automatically adds an `id` field (`int?`).
* `serverpod generate` + `serverpod create-migration` generate code and migrations.

### Non‑persistent fields

Use `!persist` to exclude a field from database mapping:

```spy.yaml
fields:
  tempData: String, !persist
```

## One-to-one Relations

* Embed model-only data stored as JSON if no `relation` keyword.
* Use `relation` to create proper DB relation:

```spy.yaml
class: Company
table: company
fields:
  owner: User?, relation
```

### Relation with an id field
address.spy.yaml
```spy.yaml
class: Address
table: address
fields:
  street: String
```

user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  addressId: int, relation(parent=address) // Foreign key field
indexes:
  user_address_unique_idx:
    fields: addressId
    unique: true
```

### Relation an another model object
address.spy.yaml
```spy.yaml
class: Address
table: address
fields:
  street: String
```

user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  address: Address?, relation // Object relation field
indexes:
  user_address_unique_idx:
    fields: addressId
    unique: true
```

- The `addressId` field in the `User` class is automatically generated.

### Relation with optional
user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  address: Address?, relation(optional)
indexes:
  user_address_unique_idx:
    fields: addressId
    unique: true
```

- The automatically generated `addressId` field becomes nullable.

### Custom foreign key field

user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  customIdField: int
  address: Address?, relation(field=customIdField)
indexes:
  user_address_unique_idx:
    fields: customIdField
    unique: true
```

-  `customIdField` is used instead of default auto-generated name.
- Can be nullable (set `customIdField: int`)

### Independent relations defined on both sides
user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  friendsAddress: Address?, relation
indexes:
  user_address_unique_idx:
    fields: friendsAddressId
    unique: true
```

address.spy.yaml
```spy.yaml
class: Address
table: address
fields:
  street: String
  resident: User?, relation
indexes:
  address_user_unique_idx:
    fields: residentId
    unique: true
```

### Bidrectional relations
user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  addressId: int
  address: Address?, relation(name=user_address, field=addressId)
indexes:
  user_address_unique_idx:
    fields: addressId
    unique: true
```

address.spy.yaml
```spy.yaml
class: Address
table: address
fields:
  street: String
  user: User?, relation(name=user_address)
```

-  Illustrates a 1:1 relationship between User and Address, both sides of the relationship are explicitly specified.


## One-to-many relations

### Implicit definition

company.spy.yaml
```spy.yaml
class: Company
table: company
fields:
  name: String
  employees: List<Employee>?, relation
```

employee.spy.yaml
```spy.yaml
class: Employee
table: employee
fields:
  name: String
```

### Explicit definition (object relation)

company.spy.yaml
```spy.yaml
class: Company
table: company
fields:
  name: String
```

employee.spy.yaml
```spy.yaml
class: Employee
table: employee
fields:
  name: String
  company: Company?, relation
```

### Explicit definition (through foreign key field)

company.spy.yaml
```spy.yaml
class: Company
table: company
fields:
  name: String
```

employee.spy.yaml
```spy.yaml
class: Employee
table: employee
fields:
  name: String
  companyId: int, relation
```

### Bidirectional relation (object)

company.spy.yaml
```spy.yaml
class: Company
table: company
fields:
  name: String
  employees: List<Employee>?, relation(name=company_employees)
```

employee.spy.yaml
```spy.yaml
class: Employee
table: employee
fields:
  name: String
  company: Company?, relation(name=company_employees)
```

### Bidirectional relation (foreign key field)

company.spy.yaml
```spy.yaml
class: Company
table: company
fields:
  name: String
  employees: List<Employee>?, relation(name=company_employees)
```

employee.spy.yaml
```spy.yaml
class: Employee
table: employee
fields:
  name: String
  companyId: int, relation(name=company_employees, parent=company)
```

## Many-to-many relations

### Defining the relationship

course.spy.yaml
```spy.yaml
class: Course
table: course
fields:
  name: String
  enrollments: List<Enrollment>?, relation(name=course_enrollments)
```

student.spy.yaml
```spy.yaml
class: Student
table: student
fields:
  name: String
  enrollments: List<Enrollment>?, relation(name=student_enrollments)
```

enrollment.spy.yaml
```spy.yaml
class: Enrollment
table: enrollment
fields:
  student: Student?, relation(name=student_enrollments)
  course: Course?, relation(name=course_enrollments)
indexes:
  enrollment_index_idx:
    fields: studentId, courseId
    unique: true
```

## Self-relations

### One-to-one

post.spy.yaml
```spy.yaml
class: Post
table: post
fields:
  content: String
  previous: Post?, relation(name=next_previous_post)
  nextId: int?
  next: Post?, relation(name=next_previous_post, field=nextId, onDelete=SetNull)
indexes:
  next_unique_idx:
    fields: nextId
    unique: true
```

### One-to-many

cat.spy.yaml
```spy.yaml
class: Cat
table: cat
fields:
  name: String
  mother: Cat?, relation(name=cat_kittens, optional, onDelete=SetNull)
  kittens: List<Cat>?, relation(name=cat_kittens)
```

### Many-to-many

member.spy.yaml
```spy.yaml
class: Member
table: member
fields:
  name: String
  blocking: List<Blocking>?, relation(name=member_blocked_by_me)
  blockedBy: List<Blocking>?, relation(name=member_blocking_me)
```

blocking.spy.yaml
```spy.yaml
class: Blocking
table: blocking
fields:
  blocked: Member?, relation(name=member_blocking_me, onDelete=Cascade)
  blockedBy: Member?, relation(name=member_blocked_by_me, onDelete=Cascade)
indexes:
  blocking_blocked_unique_idx:
    fields: blockedId, blockedById
    unique: true
```


## Serverpod Referential Actions

Defines behavior when a parent record in a relation is **updated** or **deleted**, mapped directly to PostgreSQL relational actions.


### Keywords & Syntax

```spy.yaml
<ModelClass>.parent: Model?, relation(onUpdate=<ACTION>, onDelete=<ACTION>)
<ModelClass>.parentId: int?, relation(parent=<model_table>, onUpdate=<ACTION>, onDelete=<ACTION>)
```

Actions are positional — order doesn’t matter.


### Available Actions

| Action         | Effect                                                             |
| -------------- | ------------------------------------------------------------------ |
| **NoAction**   | Throw error if foreign key constraint violation occurs.            |
| **Restrict**   | Same as NoAction — disallows violating update/delete.              |
| **SetDefault** | Revert foreign key to default value (requires default configured). |
| **Cascade**    | Apply parent update/delete to child (delete or update cascade).    |
| **SetNull**    | Set child foreign key to `null` (only if field is nullable).       |


### Defaults Behavior

* **Object-relations** (e.g. `Model?`, `relation(...)`) default to:

  * `onUpdate=NoAction`
  * `onDelete=NoAction`

* **ID-relations** (e.g. `parentId: int?, relation(...)` with `parent=`) default to:

  * `onUpdate=NoAction`
  * `onDelete=Cascade`


### Full Example

```spy.yaml
class: Example
table: example
fields:
  parentId: int?, relation(parent=example, onUpdate=SetNull, onDelete=NoAction)
```

* On **update** of parent: `parentId` → `null`
* On **delete** of parent: *no change* (raises error if child exists)


## Relations with modules

Create a "bridge" table/model linking the module's model to your own. This can be done by setting up a one-to-one relation.

user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  userInfo: module:auth:UserInfo?, relation
  age: int
indexes:
  user_info_id_unique_idx:
    fields: userInfoId
    unique: true
```

Or reference table name by id.

user.spy.yaml
```spy.yaml
class: User
table: user
fields:
  userInfoId: int, relation(parent=serverpod_user_info)
  age: int
indexes:
  user_info_id_unique_idx:
    fields: userInfoId
    unique: true
```



## Custom ID Types (UuidValue supported)

Use custom ID types like `UuidValue`:

```spy.yaml
class: UuidModel
table: uuid_model
fields:
  id: UuidValue?, defaultPersist=random
```

* `defaultPersist=random` generates UUID v4 when saving.
* `defaultModel=random` generates ID on object creation.
* Non-nullable IDs get UUID before saving.

---

### How This Works in Practice

1. Author `.spy.yaml` for your models.
2. Run `serverpod generate` to create Dart code.
3. If you added/removed/changed `table:`, run `serverpod create-migration`.
4. Use generated code:

   * Call endpoints with typed models.
   * Database CRUD via `Model.db.insertRow()`, `.find()`, `.updateRow()`, `.deleteWhere()`.
