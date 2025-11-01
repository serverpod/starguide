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
import 'markdown_resource_info.dart' as _i2;

abstract class MarkdownResourceList
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MarkdownResourceList._({required this.resources});

  factory MarkdownResourceList(
          {required List<_i2.MarkdownResourceInfo> resources}) =
      _MarkdownResourceListImpl;

  factory MarkdownResourceList.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return MarkdownResourceList(
        resources: (jsonSerialization['resources'] as List)
            .map((e) =>
                _i2.MarkdownResourceInfo.fromJson((e as Map<String, dynamic>)))
            .toList());
  }

  List<_i2.MarkdownResourceInfo> resources;

  /// Returns a shallow copy of this [MarkdownResourceList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkdownResourceList copyWith({List<_i2.MarkdownResourceInfo>? resources});
  @override
  Map<String, dynamic> toJson() {
    return {'resources': resources.toJson(valueToJson: (v) => v.toJson())};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'resources': resources.toJson(valueToJson: (v) => v.toJsonForProtocol())
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarkdownResourceListImpl extends MarkdownResourceList {
  _MarkdownResourceListImpl({required List<_i2.MarkdownResourceInfo> resources})
      : super._(resources: resources);

  /// Returns a shallow copy of this [MarkdownResourceList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkdownResourceList copyWith({List<_i2.MarkdownResourceInfo>? resources}) {
    return MarkdownResourceList(
        resources:
            resources ?? this.resources.map((e0) => e0.copyWith()).toList());
  }
}
