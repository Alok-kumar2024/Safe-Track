import 'package:flutter/cupertino.dart';

class HomeProvider extends ChangeNotifier {

  bool _isShakeTrue = true;

  bool getShakeValue() => _isShakeTrue;

  void updateShake(bool value) {
    print('updateShake called with: $value');
    _isShakeTrue = value;
    notifyListeners();
  }



}
