import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class SosFeedBackService {
  final AudioPlayer _player = AudioPlayer();

  //Vibrates for SOS confirmation...
  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 800);
    }
  }

  //Plays Alert sound...
  Future<void> playAlertSound() async {
    await _player.play(
        AssetSource('sounds/police_siren.wav'),
        volume: 1.0);
  }

}