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

abstract class RecaptchaException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  RecaptchaException._();

  factory RecaptchaException() = _RecaptchaExceptionImpl;

  factory RecaptchaException.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecaptchaException();
  }

  /// Returns a shallow copy of this [RecaptchaException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecaptchaException copyWith();
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'RecaptchaException'};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'RecaptchaException'};
  }

  @override
  String toString() {
    return 'RecaptchaException';
  }
}

class _RecaptchaExceptionImpl extends RecaptchaException {
  _RecaptchaExceptionImpl() : super._();

  /// Returns a shallow copy of this [RecaptchaException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecaptchaException copyWith() {
    return RecaptchaException();
  }
}
