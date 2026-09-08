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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A chat session with the first question asked, for listing.
abstract class AdminChatSessionSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminChatSessionSummary._({
    required this.id,
    required this.createdAt,
    this.goodAnswer,
    this.authUserId,
    required this.messageCount,
    required this.firstQuestion,
  });

  factory AdminChatSessionSummary({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    required int messageCount,
    required String firstQuestion,
  }) = _AdminChatSessionSummaryImpl;

  factory AdminChatSessionSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminChatSessionSummary(
      id: jsonSerialization['id'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      goodAnswer: jsonSerialization['goodAnswer'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['goodAnswer']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      messageCount: jsonSerialization['messageCount'] as int,
      firstQuestion: jsonSerialization['firstQuestion'] as String,
    );
  }

  int id;

  DateTime createdAt;

  bool? goodAnswer;

  _isc.UuidValue? authUserId;

  int messageCount;

  /// The first question of the conversation, truncated.
  String firstQuestion;

  /// Returns a shallow copy of this [AdminChatSessionSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminChatSessionSummary copyWith({
    int? id,
    DateTime? createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    int? messageCount,
    String? firstQuestion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminChatSessionSummary',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'messageCount': messageCount,
      'firstQuestion': firstQuestion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminChatSessionSummary',
      'id': id,
      'createdAt': createdAt.toJson(),
      if (goodAnswer != null) 'goodAnswer': goodAnswer,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'messageCount': messageCount,
      'firstQuestion': firstQuestion,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminChatSessionSummaryImpl extends AdminChatSessionSummary {
  _AdminChatSessionSummaryImpl({
    required int id,
    required DateTime createdAt,
    bool? goodAnswer,
    _isc.UuidValue? authUserId,
    required int messageCount,
    required String firstQuestion,
  }) : super._(
         id: id,
         createdAt: createdAt,
         goodAnswer: goodAnswer,
         authUserId: authUserId,
         messageCount: messageCount,
         firstQuestion: firstQuestion,
       );

  /// Returns a shallow copy of this [AdminChatSessionSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminChatSessionSummary copyWith({
    int? id,
    DateTime? createdAt,
    Object? goodAnswer = _Undefined,
    Object? authUserId = _Undefined,
    int? messageCount,
    String? firstQuestion,
  }) {
    return AdminChatSessionSummary(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      goodAnswer: goodAnswer is bool? ? goodAnswer : this.goodAnswer,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      messageCount: messageCount ?? this.messageCount,
      firstQuestion: firstQuestion ?? this.firstQuestion,
    );
  }
}
