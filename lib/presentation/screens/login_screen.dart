import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/login_otp_screen.dart';
import 'package:safe_track/presentation/screens/privacy_policy_screen.dart';
import 'package:safe_track/presentation/screens/terms_condition_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/login_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC), // Soft white
              Color(0xFFF1F5F9), // Light gray
              Color(0xFFE0E7FF), // Light indigo tint
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
            const SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: LoginWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Changed to StatefulWidget to handle state resets properly
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;


  @override
  void initState() {
    super.initState();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
      };

    // FIX 1: Ensure loading is FALSE when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthServices>().updateLoading(false);
      }
    });
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // Logic Providers
    final loginW = context.watch<LoginProvider>();
    final authW = context.watch<AuthServices>();
    final loginR = context.read<LoginProvider>();
    final authR = context.read<AuthServices>();

    // Premium Color Palette - Light Mode
    const primaryColor = Color(0xFF6366F1); // Indigo
    const accentColor = Color(0xFF8B5CF6); // Purple
    const textPrimaryColor = Color(0xFF1E293B); // Dark slate
    const textSecondaryColor = Color(0xFF64748B); // Slate gray

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        // --- 1. LOGO & BRANDING ---
        Row(
          children: [
            Container(
              height: 70,
              width: 70,
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
              child: const Center(
                child: Icon(
                  Icons.shield_rounded,
                  size: 36,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SAFETRACK",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textPrimaryColor,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "Security Platform",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondaryColor.withOpacity(0.6),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 70),

        // --- 2. HEADERS ---
        const Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: textPrimaryColor,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Sign in with your phone number to continue\nyour secure journey",
          style: TextStyle(
            fontSize: 15,
            color: textSecondaryColor,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 60),

        // --- 3. PHONE INPUT ---
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 18, right: 20),
                child: Text(
                  "PHONE NUMBER",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textSecondaryColor.withOpacity(0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    loginR.updateUserNumber(number);
                    // Ensure we reset loading if user starts typing again
                    if (authW.isLoading) authR.updateLoading(false);
                  },
                  onInputValidated: (bool valid) {
                    loginR.updateIsValid(valid);
                  },
                  initialValue: loginR.getDefault(),
                  selectorTextStyle: const TextStyle(
                    color: textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textStyle: const TextStyle(
                    color: textPrimaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  cursorColor: primaryColor,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    showFlags: true,
                    leadingPadding: 0,
                    trailingSpace: false,
                    setSelectorButtonAsPrefixIcon: false,
                  ),
                  inputDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 16, top: 8),
                    hintText: 'Enter your number',
                    hintStyle: TextStyle(
                      color: textSecondaryColor.withOpacity(0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),

        const SizedBox(height: 50),

        // --- 4. CTA BUTTON ---
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton(
            onPressed: authW.isLoading
                ? null
                : () {
              final phone = loginR.getUserNumber().phoneNumber ?? "";
              final valid = loginR.getIsValid();
              final checked = loginR.getIsChecked() ?? false;

              if (phone.isEmpty) {
                _showErrorSnackBar(context, "Phone number is required");
              } else if (!valid) {
                _showErrorSnackBar(context, "Invalid phone number format");
                loginR.updateCheckedFailed(valid);
              } else if (!checked) {
                _showErrorSnackBar(
                    context, "Please accept Terms and Privacy Policy");
                loginR.updateCheckedFailed(false);
              } else {

                // --- FIX 2: START VERIFICATION ---
                authR.verifyPhoneNumber(
                  phoneNumber: "${loginW.getUserNumber().phoneNumber}",

                  onCodeSent: (verification, resend) {
                    // FIX 3: Add .then() to reset loading when returning
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginOtpScreen()),
                    ).then((_) {
                      // This runs when you come BACK from OTP screen
                      if(mounted) {
                        context.read<AuthServices>().updateLoading(false);
                      }
                    });
                  },

                  onVerificationCompleted: (complete) {
                    // If auto-verified, stop loading
                    authR.updateLoading(false);
                  },

                  onVerificationFailed: (error) {
                    // FIX 4: Explicitly stop loading on error
                    authR.updateLoading(false);
                    _showErrorSnackBar(context, error ?? "Verification Failed");
                  },

                  onTimeOut: (verifyId) {
                    authR.updateLoading(false);
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: EdgeInsets.zero,
              elevation: 0,
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
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: authW.isLoading
                    ? const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 22,
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 35),

        // --- 5. TERMS & PRIVACY ---
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<LoginProvider>(
                builder: (_, provider, __) {
                  return SizedBox(
                    height: 22,
                    width: 22,
                    child: Checkbox(
                      value: provider.getIsChecked(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: primaryColor,
                      checkColor: Colors.white,
                      onChanged: (bool? val) {
                        provider.updateIsChecked(val);
                        bool value = val ?? false;
                        provider.updateCheckedFailed(value);
                      },
                      side: MaterialStateBorderSide.resolveWith(
                            (states) {
                          if (!provider.getCheckFailed()) {
                            return const BorderSide(
                                color: Color(0xFFEF4444), width: 2);
                          }
                          return BorderSide(
                            color: textSecondaryColor.withOpacity(0.3),
                            width: 1.5,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondaryColor.withOpacity(0.8),
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                    children: [
                      const TextSpan(text: "I agree to the "),
                      TextSpan(
                        text: "Terms of Service",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor.withOpacity(0.9),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor.withOpacity(0.9),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}