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

  void modifyErrorList(int idx, bool error)
  {
    final old = _errorList[idx];
    _errorList[idx] = (isError: error,node: old.node);

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

  Future<void> saveProfileData() async {
    //Will write function for what will happen upon clicking this buttton
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
