import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/home_screen.dart';
import 'package:safe_track/presentation/screens/profile_setup_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/login_provider.dart';
import 'package:safe_track/state/otp_provider.dart';
import '../../state/profile_provider.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8FAFC), // Soft white
              const Color(0xFFF1F5F9), // Light gray
              const Color(0xFFE0E7FF), // Light indigo tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Ambient background effects
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA78BFA).withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF1E293B),
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: const OtpWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpWidget extends StatelessWidget {
  const OtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Logic Providers ---
    final loginW = context.watch<LoginProvider>();
    final authW = context.watch<AuthServices>();
    final otpW = context.watch<OtpProvider>();

    final authR = context.read<AuthServices>();
    final otpR = context.read<OtpProvider>();
    final loginR = context.read<LoginProvider>();

    final userNum = loginW.getUserNumber();

    // Premium Color Palette
    const primaryColor = Color(0xFF6366F1); // Indigo
    const accentColor = Color(0xFF8B5CF6); // Purple
    const textPrimaryColor = Color(0xFF1E293B); // Dark slate
    const textSecondaryColor = Color(0xFF64748B); // Slate gray

    // --- Pinput Theme Styling ---
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // --- 1. ICON & HEADERS ---
        Center(
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  accentColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: primaryColor,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        const Center(
          child: Text(
            "Verification Code",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textPrimaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Center(
          child: Text(
            "We've sent a 6-digit code to",
            style: TextStyle(
              fontSize: 15,
              color: textSecondaryColor,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Phone number with change button
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  "${userNum.phoneNumber}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 16,
                  color: const Color(0xFFE2E8F0),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Change",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 50),

        // --- 2. PIN INPUT ---
        Center(
          child: Pinput(
            key: ValueKey(otpW.otpstatus),
            length: 6,
            keyboardType: TextInputType.number,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: otpW.otpstatus == otpStatus.correct
                ? submittedPinTheme
                : (otpW.otpstatus == otpStatus.incorrect
                ? errorPinTheme
                : defaultPinTheme),
            errorPinTheme: errorPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onChanged: (pin) {
              if (pin.length < 6) {
                otpR.updateComplete(false);
              }
              if (otpW.otpstatus == otpStatus.incorrect) {
                otpR.updateOtpStatus(otpStatus.none);
              }
            },
            onCompleted: (pin) {
              otpR.updateComplete(true);
              otpR.updateOtp(pin);
            },
          ),
        ),

        const SizedBox(height: 50),

        // --- 3. VERIFY BUTTON ---
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton(
            onPressed: authW.isOtpLoading
                ? null
                : () async {
              if (otpW.complete) {
                final success = await authR.signInWithOtp(
                  otp: otpW.getOtp(),
                  onFailed: (error) {
                    otpR.updateOtpStatus(otpStatus.incorrect);
                    _showErrorSnackBar(context, "Invalid verification code");
                  },
                );

                if (success) {
                  otpR.updateOtpStatus(otpStatus.correct);
                  final profileProvider = context.read<ProfileProvider>();
                  await profileProvider.init();

                  if (!context.mounted) return;

                  if (profileProvider.isProfileSet) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                          (route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileSetUpScreen()),
                          (route) => false,
                    );
                  }
                } else {
                  otpR.updateOtpStatus(otpStatus.incorrect);
                  _showErrorSnackBar(context, "Invalid verification code");
                }
              } else {
                _showErrorSnackBar(
                    context, "Please enter the complete 6-digit code");
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1), // Indigo
                    Color(0xFF8B5CF6), // Purple
                    Color(0xFF7C3AED), // Violet
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: authW.isOtpLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 22)
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Verify & Continue",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // --- 4. RESEND CODE ---
        Center(
          child: authW.secondRemaining == 0
              ? Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                authR.resendOtp(
                  phoneNumber:
                  "${userNum.dialCode}${userNum.phoneNumber}",
                  onCodeSent: (verifyID, otp) {
                    _showSuccessSnackBar(
                        context, "Verification code resent");
                  },
                  onVerificationCompleted: (complete) {},
                  onVerificationFailed: (error) {
                    _showErrorSnackBar(context, "Failed to resend code");
                  },
                  onTimeOut: (verifyID) {},
                );
              },
              icon: Icon(Icons.refresh_rounded, size: 20, color: primaryColor),
              label: Text(
                "Resend Code",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.3,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
          )
              : Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: textSecondaryColor,
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    text: "Resend code in ",
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text:
                        "00:${authW.secondRemaining.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 35),

        // --- 5. HELP TEXT ---
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFCD34D).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Didn't receive the code? Check your messages or try resending.",
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}