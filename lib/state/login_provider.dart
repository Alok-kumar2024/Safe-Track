import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginProvider extends ChangeNotifier{

  bool? _isChecked = false;

  final PhoneNumber _number = PhoneNumber(isoCode: "IN",dialCode: "+91");

  PhoneNumber _userNum = PhoneNumber();

  bool _isValid = false;

  bool _isCheckedFailed = false;

  bool? getIsChecked() => _isChecked;

  PhoneNumber getDefault() => _number;

  PhoneNumber getUserNumber() => _userNum;

  bool getIsValid() => _isValid;

  bool getCheckFailed() => _isCheckedFailed;

  void updateCheckedFailed(bool check)
  {
    _isCheckedFailed = check;
    notifyListeners();
  }

  void updateIsChecked(bool? checked)
  {
    _isChecked = checked;
    notifyListeners();
  }

  void updateIsValid(bool valid)
  {
    _isValid = valid;
    notifyListeners();
  }

  void updateUserNumber(PhoneNumber newNum)
  {
    _userNum = newNum;
    notifyListeners();
  }

}