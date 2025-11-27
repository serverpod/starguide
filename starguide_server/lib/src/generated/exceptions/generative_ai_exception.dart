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

abstract class GenerativeAiException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  GenerativeAiException._({required this.message});

  factory GenerativeAiException({required String message}) =
      _GenerativeAiExceptionImpl;

  factory GenerativeAiException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GenerativeAiException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [GenerativeAiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GenerativeAiException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GenerativeAiException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GenerativeAiException',
      'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _GenerativeAiExceptionImpl extends GenerativeAiException {
  _GenerativeAiExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [GenerativeAiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GenerativeAiException copyWith({String? message}) {
    return GenerativeAiException(message: message ?? this.message);
  }
}
