import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _verificationID = "";
  bool _isCodeSend = false;
  bool _isLoading = false;
  int _secondRemaining = 0;
  Timer? _timer;

  bool _isOtpLoading = false;

  bool get isOtpLoading => _isOtpLoading;

  bool get isCodeSend => _isCodeSend;

  bool get isLoading => _isLoading;

  int get secondRemaining => _secondRemaining;

  void updateLoading(bool loading)
  {
    _isLoading = loading;
    notifyListeners();
  }

  //Function which will send otp
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onVerificationCompleted,
    required void Function(String error) onVerificationFailed,
    required void Function(String verificationId) onTimeOut,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cerdential) {
          onVerificationCompleted("Auto Verification Complete");
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          notifyListeners();
          onVerificationFailed(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationID = verificationId;
          _isLoading = false;
          _startTimer();
          notifyListeners();
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationID = verificationID;
          onTimeOut(verificationID);
        },
      );
    } catch (e) {
      debugPrint("Error in verify Phone number , inside catch -> $e");
    }
  }

  Future<bool> signInWithOtp({
    required String otp,
    required void Function(String) onFailed,
  }) async {
    _isOtpLoading = true;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationID,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      _isOtpLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint("Otp verification Failed ${e.code}");
        onFailed(e.code);
      } else {
        debugPrint("Unknown error: $e");
      }
      _isOtpLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> resendOtp({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onVerificationCompleted,
    required void Function(String error) onVerificationFailed,
    required void Function(String verificationId) onTimeOut,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onTimeOut: onTimeOut,
    );
  }

  void _startTimer() {
    _secondRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondRemaining > 0) {
        _secondRemaining--;
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }
}
