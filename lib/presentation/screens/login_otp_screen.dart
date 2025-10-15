import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

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

  final onFocused = PinTheme(
    width: 45,
    height: 45,
    textStyle: TextStyle(fontSize: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 2, color: Colors.grey.shade200),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(flex: 1),
        Image.asset("assets/images/logo_login.png", width: 100, height: 100),
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
          "Phone Number",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        Expanded(
          flex: 4,
          child: Pinput(
            length: 6,
            keyboardType: TextInputType.number,
            focusedPinTheme: onFocused,
          ),
        ),

        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {},
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
              ),

              GestureDetector(
                onTap: () {},
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
