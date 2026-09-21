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

/// Chat session and vote counts for one day, cached in the database so that
/// the admin overview does not have to aggregate the full session history on
/// every request. Computed by `AdminStats`.
abstract class DailyStats
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      day: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['day']),
      sessionCount: jsonSerialization['sessionCount'] as int,
      goodAnswerCount: jsonSerialization['goodAnswerCount'] as int,
      poorAnswerCount: jsonSerialization['poorAnswerCount'] as int,
      answeredCount: jsonSerialization['answeredCount'] as int?,
      notAnsweredCount: jsonSerialization['notAnsweredCount'] as int?,
      unsureCount: jsonSerialization['unsureCount'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [DailyStats]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
