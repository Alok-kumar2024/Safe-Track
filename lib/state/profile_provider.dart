import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:safe_track/presentation/screens/profile_setup_screen.dart';

class ProfileProvider extends ChangeNotifier {
  final List<TextEditingController> _contactNames = [];
  final List<TextEditingController> _contactNumbers = [];
  final List<({bool isError, FocusNode node})> _errorList = [];

  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();

  TextEditingController getName() => _name;

  TextEditingController getEmail() => _email;

  List<({bool isError, FocusNode node})> get getErrorList => _errorList;

  void updateErrorList(bool error, FocusNode node) {
    _errorList.add((isError: error, node: node));
    notifyListeners();
  }

  void modifyErrorList(int idx, bool error) {
    final old = _errorList[idx];
    _errorList[idx] = (isError: error, node: old.node);

    notifyListeners();
  }

  void updateRemoveErrorList(int idx) {
    _errorList[idx].node.dispose();

    _errorList.removeAt(idx);

    notifyListeners();
  }

  void updateName(TextEditingController t) {
    _name = t;
    notifyListeners();
  }

  void updateEmail(TextEditingController t) {
    _email = t;
    notifyListeners();
  }

  //Contact names
  List<TextEditingController> getTECNames() => _contactNames;

  List<TextEditingController> getTECNumber() => _contactNumbers;

  void updateAddTEC(TextEditingController tec, TextEditingController tec2) {
    _contactNames.add(tec);
    _contactNumbers.add(tec2);

    notifyListeners();
  }

  void updateRemoveTEC(int value) {
    //Disposing the TextEditingControllers....
    _contactNames[value].dispose();
    _contactNumbers[value].dispose();

    //Removing them from List.....
    _contactNames.removeAt(value);
    _contactNumbers.removeAt(value);

    //Rebuilding the UI....
    notifyListeners();
  }

  //Contact number

  // void updateAddTECNumbers(TextEditingController tec) {
  //   _contactNumbers.add(tec);
  //
  //   notifyListeners();
  // }

  // void updateRemoveTECNumbers(int value) {
  //   _contactNumbers.removeAt(value);
  //   notifyListeners();
  // }

  String ordinal(int n) {
    if (n == 1) return "st";
    if (n == 2) return "nd";
    if (n == 3) return "rd";
    return "th";
  }

  Future<String?> saveProfileData() async {

    // try {
    //   print('saveProfileData called. Firebase apps: ${Firebase.apps}');
    // } catch (_) {}

    final name = _name.text.trim();
    // final email = _email.text.trim();

    FirebaseFirestore users = FirebaseFirestore.instance;

    CollectionReference ref = users.collection('Users');

    if (name.isEmpty) {
      return 'Name is Empty';
    }

    if (_contactNames.length < 2 || _contactNumbers.length <2) {
      return 'Need Atleast 2 Emergency Contacts.';
    }

    if (_contactNames.length != _contactNumbers.length) {
      return 'Internal error: contact name/number lists are inconsistent.';
    }

    for (var i = 0; i < _contactNames.length; i++) {
      if (_contactNames[i].text.trim().isEmpty) {
        return 'Name Field for ${i + 1}${ordinal(i + 1)} Contact is Empty.';
      }

      if (_contactNumbers[i].text.trim().isEmpty) {
        return 'Phone Number Field for ${i + 1}${ordinal(i + 1)} Contact is Empty.';
      }
    }

    // for (var i = 0; i < _contactNumbers.length; i++) {
    //   if (_contactNumbers[i].text.trim().isEmpty) {
    //     return 'Phone Number Field for ${i + 1}${ordinal(i + 1)} Contact is Empty.';
    //   }
    // }

    final List<Map<String, dynamic>> _contact = [];

    for(int i =0;i<_contactNames.length;i++)
      {
        _contact.add({'name': _contactNames[i].text.toString(), 'phone': _contactNumbers[i].text});
      }

    print("FINAL CONTACT LIST BEFORE FIRESTORE: $_contact");

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await ref.doc(uid).set({
        'fullName': _name.text,
        'email': _email.text,
        'contact_list': _contact,
        'profileSet' : true
      });

      return null;
    } catch (e,st) {
      print('Firestore error: $e');
      print(st);
      return 'Failed To upload.\nError : ${e}';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();

    for (var c in _contactNames) {
      c.dispose();
    }

    for (var c in _contactNumbers) {
      c.dispose();
    }
    super.dispose();
  }
}
