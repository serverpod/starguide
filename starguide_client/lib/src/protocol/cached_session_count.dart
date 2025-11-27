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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CachedSessionCount implements _i1.SerializableModel {
  CachedSessionCount._({required this.count});

  factory CachedSessionCount({required int count}) = _CachedSessionCountImpl;

  factory CachedSessionCount.fromJson(Map<String, dynamic> jsonSerialization) {
    return CachedSessionCount(count: jsonSerialization['count'] as int);
  }

  int count;

  /// Returns a shallow copy of this [CachedSessionCount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CachedSessionCount copyWith({int? count});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CachedSessionCount',
      'count': count,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CachedSessionCountImpl extends CachedSessionCount {
  _CachedSessionCountImpl({required int count}) : super._(count: count);

  /// Returns a shallow copy of this [CachedSessionCount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CachedSessionCount copyWith({int? count}) {
    return CachedSessionCount(count: count ?? this.count);
  }
}
