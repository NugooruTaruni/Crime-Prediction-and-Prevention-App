import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedContactsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final List<Contact> _selectedContacts = [];

  List<Contact> get selectedContacts => _selectedContacts;

  SelectedContactsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    // Retrieve the selected contacts list from SharedPreferences
    final contactsString = _prefs.getString('selectedContacts');
    if (contactsString != null) {
      final List<dynamic> contactsJson = jsonDecode(contactsString);
      _selectedContacts.addAll(contactsJson.map((contactJson) => Contact.fromMap(contactJson)));
    }
  }

  void addContact(Contact contact) {
    _selectedContacts.add(contact);
    notifyListeners();
  }

  void removeContact(Contact contact) {
    _selectedContacts.remove(contact);
    notifyListeners();
  }

  // ignore: unused_element
  Future<void> _updatePrefs() async {
    // Store the selected contacts list in SharedPreferences
    final List<dynamic> contactsJson = _selectedContacts.map((contact) => contact.toMap()).toList();
    await _prefs.setString('selectedContacts', jsonEncode(contactsJson));
  }
}
