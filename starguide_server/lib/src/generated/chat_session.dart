/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class ChatSession
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ChatSession._({
    this.id,
    this.authUserId,
    required this.keyToken,
    this.goodAnswer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatSession({
    int? id,
    _is.UuidValue? authUserId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      keyToken: jsonSerialization['keyToken'] as String,
      goodAnswer: jsonSerialization['goodAnswer'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['goodAnswer']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ChatSessionTable();

  static const db = ChatSessionRepository._();

  @override
  int? id;

  _is.UuidValue? authUserId;

  String keyToken;

  bool? goodAnswer;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChatSession copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      'createdAt': createdAt.toJson(),
    };
  }

  static ChatSessionInclude include() {
    return ChatSessionInclude._();
  }

  static ChatSessionIncludeList includeList({
    _is.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    ChatSessionInclude? include,
  }) {
    return ChatSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    _is.UuidValue? authUserId,
    required String keyToken,
    bool? goodAnswer,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         keyToken: keyToken,
         goodAnswer: goodAnswer,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    String? keyToken,
    Object? goodAnswer = _Undefined,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      keyToken: keyToken ?? this.keyToken,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatSessionUpdateTable extends _is.UpdateTable<ChatSessionTable> {
  ChatSessionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(table.authUserId, value);

  _is.ColumnValue<String, String> keyToken(String value) =>
      _is.ColumnValue(table.keyToken, value);

  _is.ColumnValue<bool, bool> goodAnswer(bool? value) =>
      _is.ColumnValue(table.goodAnswer, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class ChatSessionTable extends _is.Table<int?> {
  ChatSessionTable({super.tableRelation}) : super(tableName: 'chat_session') {
    updateTable = ChatSessionUpdateTable(this);
    authUserId = _is.ColumnUuid('authUserId', this);
    keyToken = _is.ColumnString('keyToken', this);
    goodAnswer = _is.ColumnBool('goodAnswer', this);
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
  }

  late final ChatSessionUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString keyToken;

  late final _is.ColumnBool goodAnswer;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    keyToken,
    goodAnswer,
    createdAt,
  ];
}

class ChatSessionInclude extends _is.IncludeObject {
  ChatSessionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ChatSession.t;
}

class ChatSessionIncludeList extends _is.IncludeList {
  ChatSessionIncludeList._({
    _is.WhereExpressionBuilder<ChatSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatSession.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ChatSession.t;
}

class ChatSessionRepository {
  const ChatSessionRepository._();

  /// Returns a list of [ChatSession]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ChatSession>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatSession] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ChatSession?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatSessionTable>? where,
    int? offset,
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatSession] by its [id] or null if no such row exists.
  Future<ChatSession?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatSession>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatSession]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> insert(
    _is.DatabaseSession session,
    List<ChatSession> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ChatSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ChatSession] and returns the inserted row.
  ///
  /// The returned [ChatSession] will have its `id` field set.
  Future<ChatSession> insertRow(
    _is.DatabaseSession session,
    ChatSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatSession>(row, transaction: transaction);
  }

  /// Upserts all [ChatSession]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [ChatSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> upsert(
    _is.DatabaseSession session,
    List<ChatSession> rows, {
    required _is.ColumnSelections<ChatSessionTable> conflictColumns,
    _is.ColumnSelections<ChatSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatSessionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ChatSession>(
      rows,
      conflictColumns: conflictColumns(ChatSession.t),
      updateColumns: updateColumns?.call(ChatSession.t),
      updateWhere: updateWhere?.call(ChatSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ChatSession] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [ChatSession] will have its `id` field set.
  Future<ChatSession?> upsertRow(
    _is.DatabaseSession session,
    ChatSession row, {
    required _is.ColumnSelections<ChatSessionTable> conflictColumns,
    _is.ColumnSelections<ChatSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatSessionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ChatSession>(
      row,
      conflictColumns: conflictColumns(ChatSession.t),
      updateColumns: updateColumns?.call(ChatSession.t),
      updateWhere: updateWhere?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Updates all [ChatSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> update(
    _is.DatabaseSession session,
    List<ChatSession> rows, {
    _is.ColumnSelections<ChatSessionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ChatSession>(
      rows,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ChatSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatSession> updateRow(
    _is.DatabaseSession session,
    ChatSession row, {
    _is.ColumnSelections<ChatSessionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatSession>(
      row,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatSession?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChatSessionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatSession>(
      id,
      columnValues: columnValues(ChatSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChatSessionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ChatSessionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ChatSession>(
      columnValues: columnValues(ChatSession.t.updateTable),
      where: where(ChatSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ChatSession]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> delete(
    _is.DatabaseSession session,
    List<ChatSession> rows, {
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ChatSession>(
      rows,
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ChatSession].
  Future<ChatSession> deleteRow(
    _is.DatabaseSession session,
    ChatSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatSession>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatSession>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatSessionTable> where,
    _is.OrderByBuilder<ChatSessionTable>? orderBy,
    _is.OrderByListBuilder<ChatSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ChatSession>(
      where: where(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ChatSession>(
      where: where?.call(ChatSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatSession] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatSessionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatSession>(
      where: where(ChatSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
