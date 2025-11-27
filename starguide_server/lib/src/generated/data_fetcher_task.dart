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
import 'package:serverpod/serverpod.dart' as _i1;
import 'data_fetcher_task_type.dart' as _i2;

abstract class DataFetcherTask
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DataFetcherTask._({
    required this.type,
    this.name,
  });

  factory DataFetcherTask({
    required _i2.DataFetcherTaskType type,
    String? name,
  }) = _DataFetcherTaskImpl;

  factory DataFetcherTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return DataFetcherTask(
      type: _i2.DataFetcherTaskType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      name: jsonSerialization['name'] as String?,
    );
  }

  _i2.DataFetcherTaskType type;

  String? name;

  /// Returns a shallow copy of this [DataFetcherTask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DataFetcherTask copyWith({
    _i2.DataFetcherTaskType? type,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DataFetcherTask',
      'type': type.toJson(),
      if (name != null) 'name': name,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DataFetcherTask',
      'type': type.toJson(),
      if (name != null) 'name': name,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DataFetcherTaskImpl extends DataFetcherTask {
  _DataFetcherTaskImpl({
    required _i2.DataFetcherTaskType type,
    String? name,
  }) : super._(
         type: type,
         name: name,
       );

  /// Returns a shallow copy of this [DataFetcherTask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DataFetcherTask copyWith({
    _i2.DataFetcherTaskType? type,
    Object? name = _Undefined,
  }) {
    return DataFetcherTask(
      type: type ?? this.type,
      name: name is String? ? name : this.name,
    );
  }
}
