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

abstract class ChatSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatSession._({
    this.id,
    this.userId,
    required this.keyToken,
    this.goodAnswer,
  });

  factory ChatSession({
    int? id,
    int? userId,
    required String keyToken,
    bool? goodAnswer,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int?,
      keyToken: jsonSerialization['keyToken'] as String,
      goodAnswer: jsonSerialization['goodAnswer'] as bool?,
    );
  }

  static final t = ChatSessionTable();

  static const db = ChatSessionRepository._();

  @override
  int? id;

  int? userId;

  String keyToken;

  bool? goodAnswer;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSession copyWith({
    int? id,
    int? userId,
    String? keyToken,
    bool? goodAnswer,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'keyToken': keyToken,
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
    };
  }

  static ChatSessionInclude include() {
    return ChatSessionInclude._();
  }

  static ChatSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    ChatSessionInclude? include,
  }) {
    return ChatSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    int? userId,
    required String keyToken,
    bool? goodAnswer,
  }) : super._(
          id: id,
          userId: userId,
          keyToken: keyToken,
          goodAnswer: goodAnswer,
        );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    Object? userId = _Undefined,
    String? keyToken,
    Object? goodAnswer = _Undefined,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      userId: userId is int? ? userId : this.userId,
      keyToken: keyToken ?? this.keyToken,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
    );
  }
}

class ChatSessionTable extends _i1.Table<int?> {
  ChatSessionTable({super.tableRelation}) : super(tableName: 'chat_session') {
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    keyToken = _i1.ColumnString(
      'keyToken',
      this,
    );
    goodAnswer = _i1.ColumnBool(
      'goodAnswer',
      this,
    );
  }

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString keyToken;

  late final _i1.ColumnBool goodAnswer;

  @override
  List<_i1.Column> get columns => [
        id,
        userId,
        keyToken,
        goodAnswer,
      ];
}

class ChatSessionInclude extends _i1.IncludeObject {
  ChatSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatSession.t;
}

class ChatSessionIncludeList extends _i1.IncludeList {
  ChatSessionIncludeList._({
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatSession.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ChatSession] by its [id] or null if no such row exists.
  Future<ChatSession?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ChatSession>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ChatSession]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ChatSession>> insert(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ChatSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ChatSession] and returns the inserted row.
  ///
  /// The returned [ChatSession] will have its `id` field set.
  Future<ChatSession> insertRow(
    _i1.Session session,
    ChatSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatSession>> update(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.ColumnSelections<ChatSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatSession>(
      rows,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatSession> updateRow(
    _i1.Session session,
    ChatSession row, {
    _i1.ColumnSelections<ChatSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatSession>(
      row,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ChatSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatSession>> delete(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatSession].
  Future<ChatSession> deleteRow(
    _i1.Session session,
    ChatSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatSession>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ChatSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatSession>(
      where: where(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatSession>(
      where: where?.call(ChatSession.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
