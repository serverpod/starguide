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
  });

  factory DailyStats({
    int? id,
    required DateTime day,
    required int sessionCount,
    required int goodAnswerCount,
    required int poorAnswerCount,
  }) = _DailyStatsImpl;

  factory DailyStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyStats(
      id: jsonSerialization['id'] as int?,
      day: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['day']),
      sessionCount: jsonSerialization['sessionCount'] as int,
      goodAnswerCount: jsonSerialization['goodAnswerCount'] as int,
      poorAnswerCount: jsonSerialization['poorAnswerCount'] as int,
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

  /// Returns a shallow copy of this [DailyStats]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DailyStats copyWith({
    int? id,
    DateTime? day,
    int? sessionCount,
    int? goodAnswerCount,
    int? poorAnswerCount,
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
  }) : super._(
         id: id,
         day: day,
         sessionCount: sessionCount,
         goodAnswerCount: goodAnswerCount,
         poorAnswerCount: poorAnswerCount,
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
  }) {
    return DailyStats(
      id: id is int? ? id : this.id,
      day: day ?? this.day,
      sessionCount: sessionCount ?? this.sessionCount,
      goodAnswerCount: goodAnswerCount ?? this.goodAnswerCount,
      poorAnswerCount: poorAnswerCount ?? this.poorAnswerCount,
    );
  }
}
