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
import 'rag_document_type.dart' as _i19rymhs;

abstract class RAGDocument
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RAGDocument._({
    this.id,
    required this.embedding,
    required this.fetchTime,
    required this.sourceUrl,
    required this.content,
    required this.title,
    required this.embeddingSummary,
    required this.shortDescription,
    required this.type,
    required this.domain,
  });

  factory RAGDocument({
    int? id,
    required _is.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String title,
    required String embeddingSummary,
    required String shortDescription,
    required _i19rymhs.RAGDocumentType type,
    required String domain,
  }) = _RAGDocumentImpl;

  factory RAGDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return RAGDocument(
      id: jsonSerialization['id'] as int?,
      embedding: _is.VectorJsonExtension.fromJson(
        jsonSerialization['embedding'],
      ),
      fetchTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchTime'],
      ),
      sourceUrl: _is.UriJsonExtension.fromJson(jsonSerialization['sourceUrl']),
      content: jsonSerialization['content'] as String,
      title: jsonSerialization['title'] as String,
      embeddingSummary: jsonSerialization['embeddingSummary'] as String,
      shortDescription: jsonSerialization['shortDescription'] as String,
      type: _i19rymhs.RAGDocumentType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      domain: jsonSerialization['domain'] as String,
    );
  }

  static final t = RAGDocumentTable();

  static const db = RAGDocumentRepository._();

  @override
  int? id;

  _is.Vector embedding;

  DateTime fetchTime;

  Uri sourceUrl;

  String content;

  String title;

  String embeddingSummary;

  String shortDescription;

  _i19rymhs.RAGDocumentType type;

  String domain;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RAGDocument copyWith({
    int? id,
    _is.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? title,
    String? embeddingSummary,
    String? shortDescription,
    _i19rymhs.RAGDocumentType? type,
    String? domain,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RAGDocument',
      if (id != null) 'id': id,
      'embedding': embedding.toJson(),
      'fetchTime': fetchTime.toJson(),
      'sourceUrl': sourceUrl.toJson(),
      'content': content,
      'title': title,
      'embeddingSummary': embeddingSummary,
      'shortDescription': shortDescription,
      'type': type.toJson(),
      'domain': domain,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RAGDocument',
      if (id != null) 'id': id,
      'embedding': embedding.toJson(),
      'fetchTime': fetchTime.toJson(),
      'sourceUrl': sourceUrl.toJson(),
      'content': content,
      'title': title,
      'embeddingSummary': embeddingSummary,
      'shortDescription': shortDescription,
      'type': type.toJson(),
      'domain': domain,
    };
  }

  static RAGDocumentInclude include() {
    return RAGDocumentInclude._();
  }

  static RAGDocumentIncludeList includeList({
    _is.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    RAGDocumentInclude? include,
  }) {
    return RAGDocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RAGDocumentImpl extends RAGDocument {
  _RAGDocumentImpl({
    int? id,
    required _is.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String title,
    required String embeddingSummary,
    required String shortDescription,
    required _i19rymhs.RAGDocumentType type,
    required String domain,
  }) : super._(
         id: id,
         embedding: embedding,
         fetchTime: fetchTime,
         sourceUrl: sourceUrl,
         content: content,
         title: title,
         embeddingSummary: embeddingSummary,
         shortDescription: shortDescription,
         type: type,
         domain: domain,
       );

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RAGDocument copyWith({
    Object? id = _Undefined,
    _is.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? title,
    String? embeddingSummary,
    String? shortDescription,
    _i19rymhs.RAGDocumentType? type,
    String? domain,
  }) {
    return RAGDocument(
      id: id is int? ? id : this.id,
      embedding: embedding ?? this.embedding.clone(),
      fetchTime: fetchTime ?? this.fetchTime,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      content: content ?? this.content,
      title: title ?? this.title,
      embeddingSummary: embeddingSummary ?? this.embeddingSummary,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
      domain: domain ?? this.domain,
    );
  }
}

class RAGDocumentUpdateTable extends _is.UpdateTable<RAGDocumentTable> {
  RAGDocumentUpdateTable(super.table);

  _is.ColumnValue<_is.Vector, _is.Vector> embedding(_is.Vector value) =>
      _is.ColumnValue(table.embedding, value);

  _is.ColumnValue<DateTime, DateTime> fetchTime(DateTime value) =>
      _is.ColumnValue(table.fetchTime, value);

  _is.ColumnValue<Uri, Uri> sourceUrl(Uri value) =>
      _is.ColumnValue(table.sourceUrl, value);

  _is.ColumnValue<String, String> content(String value) =>
      _is.ColumnValue(table.content, value);

  _is.ColumnValue<String, String> title(String value) =>
      _is.ColumnValue(table.title, value);

  _is.ColumnValue<String, String> embeddingSummary(String value) =>
      _is.ColumnValue(table.embeddingSummary, value);

  _is.ColumnValue<String, String> shortDescription(String value) =>
      _is.ColumnValue(table.shortDescription, value);

  _is.ColumnValue<_i19rymhs.RAGDocumentType, _i19rymhs.RAGDocumentType> type(
    _i19rymhs.RAGDocumentType value,
  ) => _is.ColumnValue(table.type, value);

  _is.ColumnValue<String, String> domain(String value) =>
      _is.ColumnValue(table.domain, value);
}

class RAGDocumentTable extends _is.Table<int?> {
  RAGDocumentTable({super.tableRelation}) : super(tableName: 'rag_document') {
    updateTable = RAGDocumentUpdateTable(this);
    embedding = _is.ColumnVector('embedding', this, dimension: 768);
    fetchTime = _is.ColumnDateTime('fetchTime', this);
    sourceUrl = _is.ColumnUri('sourceUrl', this);
    content = _is.ColumnString('content', this);
    title = _is.ColumnString('title', this);
    embeddingSummary = _is.ColumnString('embeddingSummary', this);
    shortDescription = _is.ColumnString('shortDescription', this);
    type = _is.ColumnEnum('type', this, _is.EnumSerialization.byName);
    domain = _is.ColumnString('domain', this);
  }

  late final RAGDocumentUpdateTable updateTable;

  late final _is.ColumnVector embedding;

  late final _is.ColumnDateTime fetchTime;

  late final _is.ColumnUri sourceUrl;

  late final _is.ColumnString content;

  late final _is.ColumnString title;

  late final _is.ColumnString embeddingSummary;

  late final _is.ColumnString shortDescription;

  late final _is.ColumnEnum<_i19rymhs.RAGDocumentType> type;

  late final _is.ColumnString domain;

  @override
  List<_is.Column> get columns => [
    id,
    embedding,
    fetchTime,
    sourceUrl,
    content,
    title,
    embeddingSummary,
    shortDescription,
    type,
    domain,
  ];
}

class RAGDocumentInclude extends _is.IncludeObject {
  RAGDocumentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RAGDocument.t;
}

class RAGDocumentIncludeList extends _is.IncludeList {
  RAGDocumentIncludeList._({
    _is.WhereExpressionBuilder<RAGDocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RAGDocument.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RAGDocument.t;
}

class RAGDocumentRepository {
  const RAGDocumentRepository._();

  /// Returns a list of [RAGDocument]s matching the given query parameters.
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
  Future<List<RAGDocument>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RAGDocument>(
      where: where?.call(RAGDocument.t),
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RAGDocument] matching the given query parameters.
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
  Future<RAGDocument?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? offset,
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RAGDocument>(
      where: where?.call(RAGDocument.t),
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RAGDocument] by its [id] or null if no such row exists.
  Future<RAGDocument?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RAGDocument>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RAGDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [RAGDocument]s will have their `id` fields set.
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
  Future<List<RAGDocument>> insert(
    _is.DatabaseSession session,
    List<RAGDocument> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RAGDocument>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RAGDocument] and returns the inserted row.
  ///
  /// The returned [RAGDocument] will have its `id` field set.
  Future<RAGDocument> insertRow(
    _is.DatabaseSession session,
    RAGDocument row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RAGDocument>(row, transaction: transaction);
  }

  /// Upserts all [RAGDocument]s in the list and returns the resulting rows.
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
  /// The returned [RAGDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RAGDocument>> upsert(
    _is.DatabaseSession session,
    List<RAGDocument> rows, {
    required _is.ColumnSelections<RAGDocumentTable> conflictColumns,
    _is.ColumnSelections<RAGDocumentTable>? updateColumns,
    _is.WhereExpressionBuilder<RAGDocumentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RAGDocument>(
      rows,
      conflictColumns: conflictColumns(RAGDocument.t),
      updateColumns: updateColumns?.call(RAGDocument.t),
      updateWhere: updateWhere?.call(RAGDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RAGDocument] and returns the resulting row.
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
  /// The returned [RAGDocument] will have its `id` field set.
  Future<RAGDocument?> upsertRow(
    _is.DatabaseSession session,
    RAGDocument row, {
    required _is.ColumnSelections<RAGDocumentTable> conflictColumns,
    _is.ColumnSelections<RAGDocumentTable>? updateColumns,
    _is.WhereExpressionBuilder<RAGDocumentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RAGDocument>(
      row,
      conflictColumns: conflictColumns(RAGDocument.t),
      updateColumns: updateColumns?.call(RAGDocument.t),
      updateWhere: updateWhere?.call(RAGDocument.t),
      transaction: transaction,
    );
  }

  /// Updates all [RAGDocument]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RAGDocument>> update(
    _is.DatabaseSession session,
    List<RAGDocument> rows, {
    _is.ColumnSelections<RAGDocumentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RAGDocument>(
      rows,
      columns: columns?.call(RAGDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RAGDocument]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RAGDocument> updateRow(
    _is.DatabaseSession session,
    RAGDocument row, {
    _is.ColumnSelections<RAGDocumentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RAGDocument>(
      row,
      columns: columns?.call(RAGDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RAGDocument] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RAGDocument?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RAGDocumentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RAGDocument>(
      id,
      columnValues: columnValues(RAGDocument.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RAGDocument]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RAGDocument>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RAGDocumentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RAGDocumentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RAGDocument>(
      columnValues: columnValues(RAGDocument.t.updateTable),
      where: where(RAGDocument.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RAGDocument]s in the list and returns the deleted rows.
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
  Future<List<RAGDocument>> delete(
    _is.DatabaseSession session,
    List<RAGDocument> rows, {
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RAGDocument>(
      rows,
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RAGDocument].
  Future<RAGDocument> deleteRow(
    _is.DatabaseSession session,
    RAGDocument row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RAGDocument>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RAGDocument>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RAGDocumentTable> where,
    _is.OrderByBuilder<RAGDocumentTable>? orderBy,
    _is.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RAGDocument>(
      where: where(RAGDocument.t),
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RAGDocument>(
      where: where?.call(RAGDocument.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RAGDocument] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RAGDocumentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RAGDocument>(
      where: where(RAGDocument.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
