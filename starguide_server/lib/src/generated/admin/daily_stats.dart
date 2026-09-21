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

/// Chat session and vote counts for one day, cached in the database so that
/// the admin overview does not have to aggregate the full session history on
/// every request. Computed by `AdminStats`.
abstract class DailyStats
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DailyStats._({
    this.id,
    required this.day,
    required this.sessionCount,
    required this.goodAnswerCount,
    required this.poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  }) : answeredCount = answeredCount ?? 0,
       notAnsweredCount = notAnsweredCount ?? 0,
       unsureCount = unsureCount ?? 0;

  factory DailyStats({
    int? id,
    required DateTime day,
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  }) = _DailyStatsImpl;

  factory DailyStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyStats(
      id: jsonSerialization['id'] as int?,
      day: _is.DateTimeJsonExtension.fromJson(jsonSerialization['day']),
      sessionCount: jsonSerialization['sessionCount'] as int,
      goodAnswerCount: jsonSerialization['goodAnswerCount'] as int,
      poorAnswerCount: jsonSerialization['poorAnswerCount'] as int,
      answeredCount: jsonSerialization['answeredCount'] as int?,
      notAnsweredCount: jsonSerialization['notAnsweredCount'] as int?,
      unsureCount: jsonSerialization['unsureCount'] as int?,
    );
  }

  static final t = DailyStatsTable();

  static const db = DailyStatsRepository._();

  @override
  int? id;

  /// Start of the day in UTC.
  DateTime day;

  int sessionCount;

  int goodAnswerCount;

  int poorAnswerCount;

  /// Sessions whose latest answer Jev judged to have answered the question.
  int answeredCount;

  int notAnsweredCount;

  int unsureCount;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DailyStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DailyStats copyWith({
    int? id,
    DateTime? day,
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyStats',
      if (id != null) 'id': id,
      'day': day.toJson(),
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
      'answeredCount': answeredCount,
      'notAnsweredCount': notAnsweredCount,
      'unsureCount': unsureCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyStats',
      if (id != null) 'id': id,
      'day': day.toJson(),
      'sessionCount': sessionCount,
      'goodAnswerCount': goodAnswerCount,
      'poorAnswerCount': poorAnswerCount,
      'answeredCount': answeredCount,
      'notAnsweredCount': notAnsweredCount,
      'unsureCount': unsureCount,
    };
  }

  static DailyStatsInclude include() {
    return DailyStatsInclude._();
  }

  static DailyStatsIncludeList includeList({
    _is.WhereExpressionBuilder<DailyStatsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    DailyStatsInclude? include,
  }) {
    return DailyStatsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyStatsImpl extends DailyStats {
  _DailyStatsImpl({
    int? id,
    required DateTime day,
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  }) : super._(
         id: id,
         day: day,
         sessionCount: sessionCount,
         goodAnswerCount: goodAnswerCount,
         poorAnswerCount: poorAnswerCount,
         answeredCount: answeredCount,
         notAnsweredCount: notAnsweredCount,
         unsureCount: unsureCount,
       );

  /// Returns a shallow copy of this [DailyStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DailyStats copyWith({
    Object? id = _Undefined,
    DateTime? day,
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
    int? answeredCount,
    int? notAnsweredCount,
    int? unsureCount,
  }) {
    return DailyStats(
      id: id is int? ? id : this.id,
      day: day ?? this.day,
      sessionCount: sessionCount ?? this.sessionCount,
      goodAnswerCount: goodAnswerCount ?? this.goodAnswerCount,
      poorAnswerCount: poorAnswerCount ?? this.poorAnswerCount,
      answeredCount: answeredCount ?? this.answeredCount,
      notAnsweredCount: notAnsweredCount ?? this.notAnsweredCount,
      unsureCount: unsureCount ?? this.unsureCount,
    );
  }
}

class DailyStatsUpdateTable extends _is.UpdateTable<DailyStatsTable> {
  DailyStatsUpdateTable(super.table);

  _is.ColumnValue<DateTime, DateTime> day(DateTime value) =>
      _is.ColumnValue(table.day, value);

  _is.ColumnValue<int, int> sessionCount(int value) =>
      _is.ColumnValue(table.sessionCount, value);

  _is.ColumnValue<int, int> goodAnswerCount(int value) =>
      _is.ColumnValue(table.goodAnswerCount, value);

  _is.ColumnValue<int, int> poorAnswerCount(int value) =>
      _is.ColumnValue(table.poorAnswerCount, value);

  _is.ColumnValue<int, int> answeredCount(int value) =>
      _is.ColumnValue(table.answeredCount, value);

  _is.ColumnValue<int, int> notAnsweredCount(int value) =>
      _is.ColumnValue(table.notAnsweredCount, value);

  _is.ColumnValue<int, int> unsureCount(int value) =>
      _is.ColumnValue(table.unsureCount, value);
}

class DailyStatsTable extends _is.Table<int?> {
  DailyStatsTable({super.tableRelation}) : super(tableName: 'daily_stats') {
    updateTable = DailyStatsUpdateTable(this);
    day = _is.ColumnDateTime('day', this);
    sessionCount = _is.ColumnInt('sessionCount', this);
    goodAnswerCount = _is.ColumnInt('goodAnswerCount', this);
    poorAnswerCount = _is.ColumnInt('poorAnswerCount', this);
    answeredCount = _is.ColumnInt('answeredCount', this, hasDefault: true);
    notAnsweredCount = _is.ColumnInt(
      'notAnsweredCount',
      this,
      hasDefault: true,
    );
    unsureCount = _is.ColumnInt('unsureCount', this, hasDefault: true);
  }

  late final DailyStatsUpdateTable updateTable;

  /// Start of the day in UTC.
  late final _is.ColumnDateTime day;

  late final _is.ColumnInt sessionCount;

  late final _is.ColumnInt goodAnswerCount;

  late final _is.ColumnInt poorAnswerCount;

  /// Sessions whose latest answer Jev judged to have answered the question.
  late final _is.ColumnInt answeredCount;

  late final _is.ColumnInt notAnsweredCount;

  late final _is.ColumnInt unsureCount;

  @override
  List<_is.Column> get columns => [
    id,
    day,
    sessionCount,
    goodAnswerCount,
    poorAnswerCount,
    answeredCount,
    notAnsweredCount,
    unsureCount,
  ];
}

class DailyStatsInclude extends _is.IncludeObject {
  DailyStatsInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DailyStats.t;
}

class DailyStatsIncludeList extends _is.IncludeList {
  DailyStatsIncludeList._({
    _is.WhereExpressionBuilder<DailyStatsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyStats.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DailyStats.t;
}

class DailyStatsRepository {
  const DailyStatsRepository._();

  /// Returns a list of [DailyStats]s matching the given query parameters.
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
  Future<List<DailyStats>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyStatsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DailyStats>(
      where: where?.call(DailyStats.t),
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DailyStats] matching the given query parameters.
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
  Future<DailyStats?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyStatsTable>? where,
    int? offset,
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DailyStats>(
      where: where?.call(DailyStats.t),
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DailyStats] by its [id] or null if no such row exists.
  Future<DailyStats?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DailyStats>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DailyStats]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyStats]s will have their `id` fields set.
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
  Future<List<DailyStats>> insert(
    _is.DatabaseSession session,
    List<DailyStats> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DailyStats>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DailyStats] and returns the inserted row.
  ///
  /// The returned [DailyStats] will have its `id` field set.
  Future<DailyStats> insertRow(
    _is.DatabaseSession session,
    DailyStats row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyStats>(row, transaction: transaction);
  }

  /// Upserts all [DailyStats]s in the list and returns the resulting rows.
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
  /// The returned [DailyStats]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyStats>> upsert(
    _is.DatabaseSession session,
    List<DailyStats> rows, {
    required _is.ColumnSelections<DailyStatsTable> conflictColumns,
    _is.ColumnSelections<DailyStatsTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyStatsTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DailyStats>(
      rows,
      conflictColumns: conflictColumns(DailyStats.t),
      updateColumns: updateColumns?.call(DailyStats.t),
      updateWhere: updateWhere?.call(DailyStats.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DailyStats] and returns the resulting row.
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
  /// The returned [DailyStats] will have its `id` field set.
  Future<DailyStats?> upsertRow(
    _is.DatabaseSession session,
    DailyStats row, {
    required _is.ColumnSelections<DailyStatsTable> conflictColumns,
    _is.ColumnSelections<DailyStatsTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyStatsTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DailyStats>(
      row,
      conflictColumns: conflictColumns(DailyStats.t),
      updateColumns: updateColumns?.call(DailyStats.t),
      updateWhere: updateWhere?.call(DailyStats.t),
      transaction: transaction,
    );
  }

  /// Updates all [DailyStats]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyStats>> update(
    _is.DatabaseSession session,
    List<DailyStats> rows, {
    _is.ColumnSelections<DailyStatsTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DailyStats>(
      rows,
      columns: columns?.call(DailyStats.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DailyStats]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyStats> updateRow(
    _is.DatabaseSession session,
    DailyStats row, {
    _is.ColumnSelections<DailyStatsTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyStats>(
      row,
      columns: columns?.call(DailyStats.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyStats] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyStats?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DailyStatsUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyStats>(
      id,
      columnValues: columnValues(DailyStats.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyStats]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyStats>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DailyStatsUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DailyStatsTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DailyStats>(
      columnValues: columnValues(DailyStats.t.updateTable),
      where: where(DailyStats.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DailyStats]s in the list and returns the deleted rows.
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
  Future<List<DailyStats>> delete(
    _is.DatabaseSession session,
    List<DailyStats> rows, {
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DailyStats>(
      rows,
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DailyStats].
  Future<DailyStats> deleteRow(
    _is.DatabaseSession session,
    DailyStats row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyStats>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyStats>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyStatsTable> where,
    _is.OrderByBuilder<DailyStatsTable>? orderBy,
    _is.OrderByListBuilder<DailyStatsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DailyStats>(
      where: where(DailyStats.t),
      orderBy: orderBy?.call(DailyStats.t),
      orderByList: orderByList?.call(DailyStats.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyStatsTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DailyStats>(
      where: where?.call(DailyStats.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DailyStats] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyStatsTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DailyStats>(
      where: where(DailyStats.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
