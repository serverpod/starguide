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
import 'chat_message_type.dart' as _itrf31vi;

abstract class ChatMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ChatMessage._({
    this.id,
    required this.chatSessionId,
    required this.message,
    required this.type,
  });

  factory ChatMessage({
    int? id,
    required int chatSessionId,
    required String message,
    required _itrf31vi.ChatMessageType type,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      chatSessionId: jsonSerialization['chatSessionId'] as int,
      message: jsonSerialization['message'] as String,
      type: _itrf31vi.ChatMessageType.fromJson(
        (jsonSerialization['type'] as String),
      ),
    );
  }

  static final t = ChatMessageTable();

  static const db = ChatMessageRepository._();

  @override
  int? id;

  int chatSessionId;

  String message;

  _itrf31vi.ChatMessageType type;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChatMessage copyWith({
    int? id,
    int? chatSessionId,
    String? message,
    _itrf31vi.ChatMessageType? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'chatSessionId': chatSessionId,
      'message': message,
      'type': type.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'chatSessionId': chatSessionId,
      'message': message,
      'type': type.toJson(),
    };
  }

  static ChatMessageInclude include() {
    return ChatMessageInclude._();
  }

  static ChatMessageIncludeList includeList({
    _is.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    ChatMessageInclude? include,
  }) {
    return ChatMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required int chatSessionId,
    required String message,
    required _itrf31vi.ChatMessageType type,
  }) : super._(
         id: id,
         chatSessionId: chatSessionId,
         message: message,
         type: type,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    int? chatSessionId,
    String? message,
    _itrf31vi.ChatMessageType? type,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}

class ChatMessageUpdateTable extends _is.UpdateTable<ChatMessageTable> {
  ChatMessageUpdateTable(super.table);

  _is.ColumnValue<int, int> chatSessionId(int value) =>
      _is.ColumnValue(table.chatSessionId, value);

  _is.ColumnValue<String, String> message(String value) =>
      _is.ColumnValue(table.message, value);

  _is.ColumnValue<_itrf31vi.ChatMessageType, _itrf31vi.ChatMessageType> type(
    _itrf31vi.ChatMessageType value,
  ) => _is.ColumnValue(table.type, value);
}

class ChatMessageTable extends _is.Table<int?> {
  ChatMessageTable({super.tableRelation}) : super(tableName: 'chat_message') {
    updateTable = ChatMessageUpdateTable(this);
    chatSessionId = _is.ColumnInt('chatSessionId', this);
    message = _is.ColumnString('message', this);
    type = _is.ColumnEnum('type', this, _is.EnumSerialization.byName);
  }

  late final ChatMessageUpdateTable updateTable;

  late final _is.ColumnInt chatSessionId;

  late final _is.ColumnString message;

  late final _is.ColumnEnum<_itrf31vi.ChatMessageType> type;

  @override
  List<_is.Column> get columns => [id, chatSessionId, message, type];
}

class ChatMessageInclude extends _is.IncludeObject {
  ChatMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ChatMessage.t;
}

class ChatMessageIncludeList extends _is.IncludeList {
  ChatMessageIncludeList._({
    _is.WhereExpressionBuilder<ChatMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ChatMessage.t;
}

class ChatMessageRepository {
  const ChatMessageRepository._();

  /// Returns a list of [ChatMessage]s matching the given query parameters.
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
  Future<List<ChatMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatMessage] matching the given query parameters.
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
  Future<ChatMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatMessage] by its [id] or null if no such row exists.
  Future<ChatMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatMessage]s will have their `id` fields set.
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
  Future<List<ChatMessage>> insert(
    _is.DatabaseSession session,
    List<ChatMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ChatMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ChatMessage] and returns the inserted row.
  ///
  /// The returned [ChatMessage] will have its `id` field set.
  Future<ChatMessage> insertRow(
    _is.DatabaseSession session,
    ChatMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatMessage>(row, transaction: transaction);
  }

  /// Upserts all [ChatMessage]s in the list and returns the resulting rows.
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
  /// The returned [ChatMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatMessage>> upsert(
    _is.DatabaseSession session,
    List<ChatMessage> rows, {
    required _is.ColumnSelections<ChatMessageTable> conflictColumns,
    _is.ColumnSelections<ChatMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ChatMessage>(
      rows,
      conflictColumns: conflictColumns(ChatMessage.t),
      updateColumns: updateColumns?.call(ChatMessage.t),
      updateWhere: updateWhere?.call(ChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ChatMessage] and returns the resulting row.
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
  /// The returned [ChatMessage] will have its `id` field set.
  Future<ChatMessage?> upsertRow(
    _is.DatabaseSession session,
    ChatMessage row, {
    required _is.ColumnSelections<ChatMessageTable> conflictColumns,
    _is.ColumnSelections<ChatMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ChatMessage>(
      row,
      conflictColumns: conflictColumns(ChatMessage.t),
      updateColumns: updateColumns?.call(ChatMessage.t),
      updateWhere: updateWhere?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatMessage>> update(
    _is.DatabaseSession session,
    List<ChatMessage> rows, {
    _is.ColumnSelections<ChatMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ChatMessage>(
      rows,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ChatMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatMessage> updateRow(
    _is.DatabaseSession session,
    ChatMessage row, {
    _is.ColumnSelections<ChatMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatMessage>(
      row,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatMessage>(
      id,
      columnValues: columnValues(ChatMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ChatMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ChatMessage>(
      columnValues: columnValues(ChatMessage.t.updateTable),
      where: where(ChatMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ChatMessage]s in the list and returns the deleted rows.
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
  Future<List<ChatMessage>> delete(
    _is.DatabaseSession session,
    List<ChatMessage> rows, {
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ChatMessage>(
      rows,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ChatMessage].
  Future<ChatMessage> deleteRow(
    _is.DatabaseSession session,
    ChatMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatMessage>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatMessageTable> where,
    _is.OrderByBuilder<ChatMessageTable>? orderBy,
    _is.OrderByListBuilder<ChatMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ChatMessage>(
      where: where(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ChatMessage>(
      where: where?.call(ChatMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatMessage>(
      where: where(ChatMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
