import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

  void debugPrintHiveData() {
    if (!_isHiveReady) {
      debugPrint('Hive not initialized');
      return;
    }

    debugPrint('----- HIVE DATA -----');
    for (var key in _userBox.keys) {
      debugPrint('$key : ${_userBox.get(key)}');
    }
    debugPrint('---------------------');
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

  List<String> getEmergencyNumbers() {
    return _contactNumbers.map((c) => c.text).toList();
  }

  late Box _userBox; // Hive storage box
  bool _isHiveReady = false; // Safety flag
  bool _profileLoaded = false;

  bool get isProfileSet {
    if (!_isHiveReady) return false;
    return _userBox.get('profileSet', defaultValue: false);
  }

  String ordinal(int n) {
    if (n == 1) return "st";
    if (n == 2) return "nd";
    if (n == 3) return "rd";
    return "th";
  }

  Future<void> init() async {

    if (_isHiveReady) return;

    _userBox = await Hive.openBox('userBox'); // Opens or creates box
    _isHiveReady = true;

    await _loadProfile(); // decides Hive or Firestore
  }

  Future<void> _loadProfile() async {
    if (_profileLoaded) return;
    _profileLoaded = true;

    // 1️⃣ Try loading from Hive
    final bool profileSet = _userBox.get('profileSet', defaultValue: false);

    if (profileSet) {
      _loadFromHive();
      return;
    }

    // 2️⃣ If Hive empty, try Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    _loadFromFirestore(doc.data()!);
  }

  void _loadFromHive() {
    _name.text = _userBox.get('fullName', defaultValue: '');
    _email.text = _userBox.get('email', defaultValue: '');

    final List<dynamic> contacts =
    _userBox.get('emergency_contacts', defaultValue: []);

    _contactNames.clear();
    _contactNumbers.clear();

    for (final c in contacts) {
      _contactNames.add(TextEditingController(text: c['name']));
      _contactNumbers.add(TextEditingController(text: c['phone']));
    }

    notifyListeners();
  }

  Future<void> _loadFromFirestore(Map<String, dynamic> data) async {
    _name.text = data['fullName'] ?? '';
    _email.text = data['email'] ?? '';

    final List contacts = data['contact_list'] ?? [];

    _contactNames.clear();
    _contactNumbers.clear();

    for (final c in contacts) {
      _contactNames.add(TextEditingController(text: c['name']));
      _contactNumbers.add(TextEditingController(text: c['phone']));
    }

    // 🔥 SAVE RESTORED DATA TO HIVE
    await _userBox.put('fullName', _name.text);
    await _userBox.put('email', _email.text);
    await _userBox.put('emergency_contacts', contacts);
    await _userBox.put('profileSet', true);

    notifyListeners();
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

    if (_contactNames.length < 2 || _contactNumbers.length < 2) {
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

    for (int i = 0; i < _contactNames.length; i++) {
      _contact.add({
        'name': _contactNames[i].text.toString(),
        'phone': _contactNumbers[i].text,
      });
    }
    // 🔒 SAVE TO HIVE FIRST (OFFLINE)
    if (_isHiveReady) {
      await _userBox.put('fullName', _name.text);
      await _userBox.put('email', _email.text);
      await _userBox.put('emergency_contacts', _contact);
      await _userBox.put('profileSet', true);
    }

    print("FINAL CONTACT LIST BEFORE FIRESTORE: $_contact");

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await ref.doc(uid).set({
        'fullName': _name.text,
        'email': _email.text,
        'contact_list': _contact,
        'profileSet': true,
      });

      return null;
    } catch (e, st) {
      print('Firestore error: $e');
      print(st);
      return 'Failed To upload.\nError : $e';
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
