import 'package:flutter/material.dart';

enum otpStatus {idle , correct , incorrect, none}

class OtpProvider extends ChangeNotifier {

  otpStatus _otpStatus = otpStatus.idle;

  otpStatus get otpstatus => _otpStatus;

  String _otp = "";
  bool _complete = false;

  bool get complete => _complete;

  String getOtp() => _otp;

  void updateOtp(String newOtp) {
    _otp = newOtp;
    notifyListeners();
  }

  void updateComplete(bool change) {
    _complete = change;
    notifyListeners();
  }

  void updateOtpStatus(otpStatus status)
  {
    _otpStatus = status;
    notifyListeners();
  }

}
