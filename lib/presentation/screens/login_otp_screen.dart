import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/home_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/login_provider.dart';
import 'package:safe_track/state/otp_provider.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: OtpWidget(),
      ),
    );
  }
}

class OtpWidget extends StatelessWidget {
  OtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final onFocused = PinTheme(
      width: 45,
      height: 45,
      textStyle: TextStyle(fontSize: 20),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.grey.shade200),
      ),
    );

    final correctTheme = onFocused.copyWith(
      decoration: BoxDecoration(
        color: Colors.green.shade300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade500),
      ),
    );

    final inCorrectTheme = onFocused.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade700),
      ),
    );
    // final errorAnimation = StreamController<ErrorAnimationType>();

    final loginW = context.watch<LoginProvider>();
    final authW = context.watch<AuthServices>();

    final loginR = context.read<LoginProvider>();
    final authR = context.read<AuthServices>();

    final otpW = context.watch<OtpProvider>();
    final otpR = context.read<OtpProvider>();

    PhoneNumber userNum = loginW.getUserNumber();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(flex: 1),
        Expanded(
          flex: 1,
          child: Image.asset(
            "assets/images/logo_login.png",
            width: 100,
            height: 100,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "SAFETRACK",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "Your Guardian, Always",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),

        Spacer(),
        Text(
          "Enter Verification Code",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Please Enter 6 digit code send to \n"
          "Phone Number ${loginW.getUserNumber().phoneNumber}",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        Expanded(
          flex: 3,
          child: Consumer<OtpProvider>(
            builder: (_, provider, __) {
              debugPrint("Called otp consumer");
              return Pinput(
                key: ValueKey(provider.otpstatus),
                length: 6,
                keyboardType: TextInputType.number,
                focusedPinTheme: onFocused,
                submittedPinTheme: provider.otpstatus == otpStatus.correct
                    ? correctTheme
                    : null,
                errorPinTheme: provider.otpstatus == otpStatus.incorrect
                    ? inCorrectTheme
                    : null,
                onChanged: (pin) {
                  if (pin.length < 6) {
                    otpR.updateComplete(false);
                  }
                },
                onCompleted: (pin) {
                  // Will work OTP Matching Logic here from Firebase...

                  otpR.updateComplete(true);
                  otpR.updateOtp(pin);
                },
              );
            },
          ),
        ),

        Spacer(),

        ElevatedButton(
          onPressed: authW.isOtpLoading
              ? null
              : () async {
                  if (otpW.complete) {
                    final success = await authR.signInWithOtp(
                      otp: otpW.getOtp(),
                      onFailed: (error) {
                        otpR.updateOtpStatus(otpStatus.incorrect);
                      },
                    );

                    if (success) {
                      otpR.updateOtpStatus(otpStatus.correct);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      otpR.updateOtpStatus(otpStatus.incorrect);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid OTP")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Incomplete Otp")));
                  }
                },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: EdgeInsets.only(left: 50,right: 50,top: 10,bottom: 10),
            backgroundColor: Colors.purple.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "Verify OTP",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),

        Spacer(),
        Visibility(
          visible: authW.isOtpLoading,
          child: SpinKitFadingCircle(color: Colors.grey.shade400, size: 50),
        ),
        Spacer(),

        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              authW.secondRemaining == 0
                  ? TextButton(
                      onPressed: () {
                        authR.resendOtp(
                          phoneNumber:
                              "${userNum.dialCode}${userNum.phoneNumber}",
                          onCodeSent: (verifyID, otp) {},
                          onVerificationCompleted: (complete) {},
                          onVerificationFailed: (error) {},
                          onTimeOut: (verifyID) {},
                        );
                      },
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                          decorationThickness: 2,
                        ),
                      ),
                    )
                  : Text(
                      "Resend in ${authW.secondRemaining}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Change Number",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white54,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
