import 'package:flash_math/services/auth.dart';

class AuthResult{
  final bool isSuccess;
  final String? errorMsg;
  AuthResult._(this.isSuccess, this.errorMsg);

  factory AuthResult.success()=>AuthResult._(true, null);
  factory AuthResult.failure(String message)=>AuthResult._(false, message);

}