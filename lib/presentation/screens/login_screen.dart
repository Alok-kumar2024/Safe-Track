import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/login_otp_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/login_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      persistentFooterButtons: [BottomPrivacyButton()],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: LoginWidget(),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final loginW = context.watch<LoginProvider>();
    final authW = context.watch<AuthServices>();

    final loginR = context.read<LoginProvider>();
    final authR = context.read<AuthServices>();

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
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),

        SizedBox(height: 20),
        Text(
          "Enter Your Phone Number",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "We'll send you a verification code.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),

          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              loginR.updateUserNumber(number);

              authR.updateLoading(false);
            },
            onInputValidated: (bool valid) {
              loginR.updateIsValid(valid);
            },
            selectorTextStyle: TextStyle(color: Colors.black),

            initialValue: loginR.getDefault(),

            //The Country selector thing
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.DROPDOWN,
              showFlags: true,
              leadingPadding: 10,
              setSelectorButtonAsPrefixIcon: true,
              trailingSpace: false,
            ),

            //Cursor Color
            cursorColor: Colors.grey.shade500,

            //Input Text Color
            textStyle: TextStyle(color: Colors.white),

            //Enabling TextField
            isEnabled: true,

            //Decorating Field
            inputDecoration: InputDecoration(
              //Decoration when field is Enabled
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              //Filling the inside
              filled: false,

              //Decoration when typing or selected
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),

              //Hint
              hintText: "Phone Number",
              //Hint color and styles
              hintStyle: TextStyle(color: Colors.white),

              //Field border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
        ElevatedButton(
          onPressed: authW.isLoading ? null : () {
            final phone =
                loginR.getUserNumber().phoneNumber ?? "";
            final valid = loginR.getIsValid();
            final checked =
                loginR.getIsChecked() ?? false;

            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Phone Number is Empty!!"),
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (!valid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Phone Number Format is incorrect!!"),
                  duration: Duration(seconds: 2),
                ),
              );
              Provider.of<LoginProvider>(
                context,
                listen: false,
              ).updateCheckedFailed(valid);
            } else if (!checked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Accept Terms and Policy !!"),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              //Send OTP to phone
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => LoginOtpScreen()),
              // );

              PhoneNumber userNum = loginW.getUserNumber();
              debugPrint("phone number -> ${userNum.phoneNumber}");
              authR.verifyPhoneNumber(
                phoneNumber: "${userNum.phoneNumber}",
                onCodeSent: (verification, resend) {
                  debugPrint("Inside  login screen code send");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginOtpScreen()),
                  );
                },
                onVerificationCompleted: (complete) {},
                onVerificationFailed: (error) {},
                onTimeOut: (verifyId) {},
              );
            }
          },

          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: Size(250, 50),
            disabledBackgroundColor: Colors.purple.shade200,
            disabledForegroundColor: Colors.white70,
            backgroundColor: Colors.purple.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "Send OTP",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),

        Spacer(),
        Visibility(
          visible: authW.isLoading,
          child: SpinKitFadingCircle(color: Colors.grey.shade400, size: 50),
        ),
        Spacer(),
      ],
    );
  }
}

class BottomPrivacyButton extends StatelessWidget {
  const BottomPrivacyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Consumer<LoginProvider>(
            builder: (_, provider, __) {
              return Checkbox(
                value: provider.getIsChecked(),
                onChanged: (bool? val) {
                  provider.updateIsChecked(val);

                  bool value = val ?? false;
                  provider.updateCheckedFailed(value);
                },
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (!provider.getCheckFailed()) {
                    return Colors.red;
                  }
                  return Colors.blue;
                }),
              );
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "By continuing, you agree to our",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  //Upon Pressed show privacy policy
                },
                child: Text(
                  "Terms of Service & Privacy Policy",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
