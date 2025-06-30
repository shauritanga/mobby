import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading states
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSigningIn extends AuthState {
  const AuthSigningIn();
}

class AuthSigningUp extends AuthState {
  const AuthSigningUp();
}

class AuthSendingPasswordReset extends AuthState {
  const AuthSendingPasswordReset();
}

class AuthSendingVerification extends AuthState {
  const AuthSendingVerification();
}

class AuthVerifyingOtp extends AuthState {
  const AuthVerifyingOtp();
}

class AuthSigningOut extends AuthState {
  const AuthSigningOut();
}

// Success states
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthVerificationSent extends AuthState {
  final String message;

  const AuthVerificationSent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthOtpVerified extends AuthState {
  final User user;

  const AuthOtpVerified(this.user);

  @override
  List<Object?> get props => [user];
}

// Error states
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSignInError extends AuthState {
  final String message;

  const AuthSignInError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSignUpError extends AuthState {
  final String message;

  const AuthSignUpError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetError extends AuthState {
  final String message;

  const AuthPasswordResetError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthVerificationError extends AuthState {
  final String message;

  const AuthVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthOtpError extends AuthState {
  final String message;

  const AuthOtpError(this.message);

  @override
  List<Object?> get props => [message];
}
