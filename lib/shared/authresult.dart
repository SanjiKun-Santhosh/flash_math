import 'package:flash_math/services/auth.dart';

class AuthResult<T> {
  final bool isSuccess;
  final String? errorMsg;
  final T? data;

  const AuthResult._({required this.isSuccess, this.data, this.errorMsg});

  factory AuthResult.success(T data) =>
      AuthResult._(isSuccess: true, data: data);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMsg: message);

  bool get isFailure => !isSuccess;
}
