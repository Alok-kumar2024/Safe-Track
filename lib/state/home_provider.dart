import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

class HomeProvider extends ChangeNotifier {

  late Box _settingsBox;

  bool _isShakeTrue = true;

  bool getShakeValue() => _isShakeTrue;

  void updateShake(bool value) {
    print('updateShake called with: $value');
    _isShakeTrue = value;
    _settingsBox.put('shake_enabled', value);
    notifyListeners();
  }


  bool _isSosSoundEnabled = true;

  bool get isSosSoundEnabled => _isSosSoundEnabled;

  Future<void> init() async{
    _settingsBox = await Hive.openBox('settingsBox');

    _isShakeTrue = _settingsBox.get('shake_enabled',defaultValue: true);

    _isSosSoundEnabled = _settingsBox.get('sos_sound_enabled',defaultValue: true);

    notifyListeners();
  }

  void updateSosSound(bool value)
  {
    _isSosSoundEnabled = value;
    _settingsBox.put('sos_sound_enabled',value);
    notifyListeners();
  }

  void reset() {
    _isShakeTrue = false;
    _isSosSoundEnabled = true;
    notifyListeners();
  }

}
