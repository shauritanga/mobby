import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../providers/auth_providers.dart';
import '../states/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? email;
  final OtpType type;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    required this.type,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).verifyOtp(
            verificationCode: _otpController.text,
            type: widget.type,
          );
    }
  }

  void _resendOtp() {
    if (widget.type == OtpType.phone && widget.phoneNumber != null) {
      ref.read(authNotifierProvider.notifier).sendPhoneVerification(
            phoneNumber: widget.phoneNumber!,
          );
    } else if (widget.type == OtpType.email) {
      ref.read(authNotifierProvider.notifier).sendEmailVerification();
    }
  }

  String get _contactInfo {
    if (widget.type == OtpType.phone && widget.phoneNumber != null) {
      return widget.phoneNumber!;
    } else if (widget.type == OtpType.email && widget.email != null) {
      return widget.email!;
    }
    return '';
  }

  String get _contactType {
    return widget.type == OtpType.phone ? 'phone number' : 'email';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthOtpVerified || next is AuthAuthenticated) {
        context.go(AppConstants.homeRoute);
      } else if (next is AuthOtpError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next is AuthVerificationSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.loginRoute),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Icon
                Icon(
                  widget.type == OtpType.phone ? Icons.phone : Icons.email,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'We\'ve sent a verification code to your $_contactType',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (_contactInfo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _contactInfo,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 48),
                
                // OTP field
                AuthTextField(
                  controller: _otpController,
                  label: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.security,
                  validator: Validators.validateOTP,
                ),
                
                const SizedBox(height: 32),
                
                // Verify button
                AuthButton(
                  text: 'Verify Code',
                  onPressed: _verifyOtp,
                  isLoading: authState is AuthVerifyingOtp,
                ),
                
                const SizedBox(height: 24),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: authState is AuthSendingVerification ? null : _resendOtp,
                      child: Text(
                        authState is AuthSendingVerification ? 'Sending...' : 'Resend',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
