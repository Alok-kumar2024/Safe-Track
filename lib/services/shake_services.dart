import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeServices {
  static const double shakeThreshold = 30.0;

  DateTime _lastTimeShake = DateTime.now();

  StreamSubscription? _subscription;

  void startShakeListening(VoidCallback onShake) {


    _subscription = accelerometerEventStream().listen((event) {
      double gForce = sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );

      if (gForce > shakeThreshold) {
        final now = DateTime.now();

        if (now.difference(_lastTimeShake).inSeconds >= 5) {
          _lastTimeShake = now;
          onShake();
        }
      }
    });
  }

  void stopShakeListening() {
    _subscription?.cancel();
  }
}
