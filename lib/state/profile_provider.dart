import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../presentation/model/emergency_contact.dart';

class ProfileProvider extends ChangeNotifier {
  // ===============================
  // BASIC PROFILE DATA
  // ===============================
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();

  TextEditingController get nameController => _name;

  TextEditingController get emailController => _email;

  // ===============================
  // EMERGENCY CONTACTS (DATA ONLY)
  // ===============================
  List<EmergencyContact> _contacts = [];

  List<EmergencyContact> get contacts => _contacts;

  // ===============================
  // HIVE
  // ===============================
  late Box _userBox;
  bool _isHiveReady = false;
  bool _profileLoaded = false;

  // ===============================
  // PROFILE STATE
  // ===============================
  bool get isProfileSet {
    if (!_isHiveReady) return false;
    return _userBox.get('profileSet', defaultValue: false);
  }

  // ===============================
  // INIT
  // ===============================
  Future<void> init() async {
    if (_isHiveReady) return;

    _userBox = await Hive.openBox('userBox');
    _isHiveReady = true;

    await _loadProfile();
  }

  // ===============================
  // LOAD PROFILE (Hive → Firestore)
  // ===============================
  Future<void> _loadProfile() async {
    if (_profileLoaded) return;
    _profileLoaded = true;

    // 1️⃣ Try Hive
    final bool profileSet = _userBox.get('profileSet', defaultValue: false);

    if (profileSet) {
      _loadFromHive();
      return;
    }

    // 2️⃣ Fallback to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    await _loadFromFirestore(doc.data()!);
  }

  // ===============================
  // LOAD FROM HIVE
  // ===============================
  void _loadFromHive() {
    _name.text = _userBox.get('fullName', defaultValue: '');
    _email.text = _userBox.get('email', defaultValue: '');

    final List raw = _userBox.get('emergency_contacts', defaultValue: []);

    _contacts = raw
        .map((e) => EmergencyContact.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  // ===============================
  // LOAD FROM FIRESTORE
  // ===============================
  Future<void> _loadFromFirestore(Map<String, dynamic> data) async {
    _name.text = data['fullName'] ?? '';
    _email.text = data['email'] ?? '';

    final List raw = data['contact_list'] ?? [];

    _contacts = raw
        .map((e) => EmergencyContact.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    await _persistToHive();
    notifyListeners();
  }

  // ===============================
  // SAVE PROFILE (SETUP SCREEN)
  // ===============================
  Future<String?> saveProfileData() async {
    final name = _name.text.trim();

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (_contacts.length < 2) {
      return 'At least 2 emergency contacts required';
    }

    await _persistToHive();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'User not logged in';

    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'fullName': _name.text,
        'email': _email.text,
        'contact_list': _contacts.map((e) => e.toMap()).toList(),
        'profileSet': true,
      });

      return null;
    } catch (e) {
      return 'Failed to save profile';
    }
  }

  // ===============================
  // CONTACT CRUD
  // ===============================
  Future<void> addContact(EmergencyContact contact) async {
    _contacts.add(contact);
    await _persistContacts();
  }

  Future<void> updateContact(int index, EmergencyContact contact) async {
    _contacts[index] = contact;
    await _persistContacts();
  }

  Future<void> deleteContact(int index) async {
    _contacts.removeAt(index);
    await _persistContacts();
  }

  // ===============================
  // CONTACT HELPERS
  // ===============================
  List<String> getEmergencyNumbers() {
    return _contacts.map((e) => e.phone).toList();
  }

  // ===============================
  // PERSISTENCE
  // ===============================
  Future<void> _persistContacts() async {
    await _userBox.put(
      'emergency_contacts',
      _contacts.map((e) => e.toMap()).toList(),
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'contact_list': _contacts.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true));
    }

    notifyListeners();
  }

  Future<void> _persistToHive() async {
    await _userBox.put('fullName', _name.text);
    await _userBox.put('email', _email.text);
    await _userBox.put(
      'emergency_contacts',
      _contacts.map((e) => e.toMap()).toList(),
    );
    await _userBox.put('profileSet', true);
  }

  // ===============================
  // LOGOUT / RESET
  // ===============================
  Future<void> reset() async {
    _contacts.clear();
    _name.clear();
    _email.clear();

    if (_isHiveReady) {
      await _userBox.clear();
    }

    notifyListeners();
  }

  // ===============================
  // DISPOSE
  // ===============================
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }
}
