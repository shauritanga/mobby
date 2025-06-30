import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../states/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;

  AuthNotifier({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SendPasswordResetUseCase sendPasswordResetUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _sendPasswordResetUseCase = sendPasswordResetUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    _checkAuthStatus();
  }

  // Check current authentication status
  Future<void> _checkAuthStatus() async {
    state = const AuthLoading();
    
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => state = const AuthUnauthenticated(),
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
    );
  }

  // Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthSigningIn();

    final result = await _signInWithEmailUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AuthSignInError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    String? phoneNumber,
  }) async {
    state = const AuthSigningUp();

    final result = await _signUpWithEmailUseCase(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      displayName: displayName,
      phoneNumber: phoneNumber,
    );

    result.fold(
      (failure) => state = AuthSignUpError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AuthSendingPasswordReset();

    final result = await _sendPasswordResetUseCase(email: email);

    result.fold(
      (failure) => state = AuthPasswordResetError(failure.message),
      (_) => state = AuthPasswordResetSent(email),
    );
  }

  // Send phone verification
  Future<void> sendPhoneVerification({required String phoneNumber}) async {
    state = const AuthSendingVerification();

    final result = await _authRepository.sendPhoneVerification(
      phoneNumber: phoneNumber,
    );

    result.fold(
      (failure) => state = AuthVerificationError(failure.message),
      (_) => state = const AuthVerificationSent('Verification code sent to your phone'),
    );
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    state = const AuthSendingVerification();

    final result = await _authRepository.sendEmailVerification();

    result.fold(
      (failure) => state = AuthVerificationError(failure.message),
      (_) => state = const AuthVerificationSent('Verification email sent'),
    );
  }

  // Verify OTP
  Future<void> verifyOtp({
    required String verificationCode,
    required OtpType type,
  }) async {
    state = const AuthVerifyingOtp();

    final result = await _verifyOtpUseCase(
      verificationCode: verificationCode,
      type: type,
    );

    result.fold(
      (failure) => state = AuthOtpError(failure.message),
      (user) => state = AuthOtpVerified(user),
    );
  }

  // Sign out
  Future<void> signOut() async {
    state = const AuthSigningOut();

    final result = await _signOutUseCase();

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  // Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    state = const AuthLoading();

    final result = await _authRepository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // Clear error state
  void clearError() {
    if (state is AuthError ||
        state is AuthSignInError ||
        state is AuthSignUpError ||
        state is AuthPasswordResetError ||
        state is AuthVerificationError ||
        state is AuthOtpError) {
      state = const AuthUnauthenticated();
    }
  }

  // Reset to initial state
  void reset() {
    state = const AuthInitial();
  }
}
