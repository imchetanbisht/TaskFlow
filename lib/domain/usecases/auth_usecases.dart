import '../../core/errors/app_exception.dart';
import '../../core/utils/validators.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(
        emailError,
        fieldErrors: {'email': emailError},
      );
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(
        passwordError,
        fieldErrors: {'password': passwordError},
      );
    }

    return await _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<AuthSession> execute({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Name is required', fieldErrors: {'name': 'Name is required'});
    }
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(emailError, fieldErrors: {'email': emailError});
    }
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError, fieldErrors: {'password': passwordError});
    }
    final confirmError = Validators.validateConfirmPassword(confirmPassword, password);
    if (confirmError != null) {
      throw ValidationException(confirmError, fieldErrors: {'confirmPassword': confirmError});
    }

    return await _repository.register(name: name.trim(), email: email.trim(), password: password);
  }
}

class GetCurrentSessionUseCase {
  final AuthRepository _repository;
  GetCurrentSessionUseCase(this._repository);

  Future<AuthSession?> execute() async {
    return await _repository.getCurrentSession();
  }
}

class RefreshTokenUseCase {
  final AuthRepository _repository;
  RefreshTokenUseCase(this._repository);

  Future<AuthSession> execute(String refreshToken) async {
    return await _repository.refreshToken(refreshToken);
  }
}

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> execute() async {
    await _repository.logout();
  }
}
