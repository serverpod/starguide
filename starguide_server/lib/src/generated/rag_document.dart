/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class RAGDocument
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RAGDocument._({
    this.id,
    required this.embedding,
    required this.fetchTime,
    required this.sourceUrl,
    required this.content,
    required this.summary,
  });

  factory RAGDocument({
    int? id,
    required _i1.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String summary,
  }) = _RAGDocumentImpl;

  factory RAGDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return RAGDocument(
      id: jsonSerialization['id'] as int?,
      embedding:
          _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      fetchTime:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchTime']),
      sourceUrl: _i1.UriJsonExtension.fromJson(jsonSerialization['sourceUrl']),
      content: jsonSerialization['content'] as String,
      summary: jsonSerialization['summary'] as String,
    );
  }

  static final t = RAGDocumentTable();

  static const db = RAGDocumentRepository._();

  @override
  int? id;

  _i1.Vector embedding;

  DateTime fetchTime;

  Uri sourceUrl;

  String content;

  String summary;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RAGDocument copyWith({
    int? id,
    _i1.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'embedding': embedding.toJson(),
      'fetchTime': fetchTime.toJson(),
      'sourceUrl': sourceUrl.toJson(),
      'content': content,
      'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'embedding': embedding.toJson(),
      'fetchTime': fetchTime.toJson(),
      'sourceUrl': sourceUrl.toJson(),
      'content': content,
      'summary': summary,
    };
  }

  static RAGDocumentInclude include() {
    return RAGDocumentInclude._();
  }

  static RAGDocumentIncludeList includeList({
    _i1.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RAGDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RAGDocumentTable>? orderByList,
    RAGDocumentInclude? include,
  }) {
    return RAGDocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RAGDocument.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RAGDocument.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RAGDocumentImpl extends RAGDocument {
  _RAGDocumentImpl({
    int? id,
    required _i1.Vector embedding,
    required DateTime fetchTime,
    required Uri sourceUrl,
    required String content,
    required String summary,
  }) : super._(
          id: id,
          embedding: embedding,
          fetchTime: fetchTime,
          sourceUrl: sourceUrl,
          content: content,
          summary: summary,
        );

  /// Returns a shallow copy of this [RAGDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RAGDocument copyWith({
    Object? id = _Undefined,
    _i1.Vector? embedding,
    DateTime? fetchTime,
    Uri? sourceUrl,
    String? content,
    String? summary,
  }) {
    return RAGDocument(
      id: id is int? ? id : this.id,
      embedding: embedding ?? this.embedding.clone(),
      fetchTime: fetchTime ?? this.fetchTime,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      content: content ?? this.content,
      summary: summary ?? this.summary,
    );
  }
}

class RAGDocumentTable extends _i1.Table<int?> {
  RAGDocumentTable({super.tableRelation}) : super(tableName: 'rag_document') {
    embedding = _i1.ColumnVector(
      'embedding',
      this,
      dimension: 1536,
    );
    fetchTime = _i1.ColumnDateTime(
      'fetchTime',
      this,
    );
    sourceUrl = _i1.ColumnUri(
      'sourceUrl',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
  }

  late final _i1.ColumnVector embedding;

  late final _i1.ColumnDateTime fetchTime;

  late final _i1.ColumnUri sourceUrl;

  late final _i1.ColumnString content;

  late final _i1.ColumnString summary;

  @override
  List<_i1.Column> get columns => [
        id,
        embedding,
        fetchTime,
        sourceUrl,
        content,
        summary,
      ];
}

class RAGDocumentInclude extends _i1.IncludeObject {
  RAGDocumentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RAGDocument.t;
}

class RAGDocumentIncludeList extends _i1.IncludeList {
  RAGDocumentIncludeList._({
    _i1.WhereExpressionBuilder<RAGDocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RAGDocument.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RAGDocument.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RAGDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<RAGDocument>(
      where: where?.call(RAGDocument.t),
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? offset,
    _i1.OrderByBuilder<RAGDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RAGDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<RAGDocument>(
      where: where?.call(RAGDocument.t),
      orderBy: orderBy?.call(RAGDocument.t),
      orderByList: orderByList?.call(RAGDocument.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [RAGDocument] by its [id] or null if no such row exists.
  Future<RAGDocument?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<RAGDocument>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [RAGDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [RAGDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<RAGDocument>> insert(
    _i1.Session session,
    List<RAGDocument> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<RAGDocument>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [RAGDocument] and returns the inserted row.
  ///
  /// The returned [RAGDocument] will have its `id` field set.
  Future<RAGDocument> insertRow(
    _i1.Session session,
    RAGDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RAGDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RAGDocument]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RAGDocument>> update(
    _i1.Session session,
    List<RAGDocument> rows, {
    _i1.ColumnSelections<RAGDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RAGDocument>(
      rows,
      columns: columns?.call(RAGDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RAGDocument]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RAGDocument> updateRow(
    _i1.Session session,
    RAGDocument row, {
    _i1.ColumnSelections<RAGDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RAGDocument>(
      row,
      columns: columns?.call(RAGDocument.t),
      transaction: transaction,
    );
  }

  /// Deletes all [RAGDocument]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RAGDocument>> delete(
    _i1.Session session,
    List<RAGDocument> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RAGDocument>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RAGDocument].
  Future<RAGDocument> deleteRow(
    _i1.Session session,
    RAGDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RAGDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RAGDocument>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RAGDocumentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RAGDocument>(
      where: where(RAGDocument.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RAGDocumentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RAGDocument>(
      where: where?.call(RAGDocument.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
