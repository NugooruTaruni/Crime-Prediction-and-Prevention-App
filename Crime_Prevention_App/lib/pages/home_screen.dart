// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'selected_contacts_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  late SharedPreferences _prefs;
  final user = FirebaseAuth.instance.currentUser;
  final List<String> _selectedContacts = [
    '+916301934045',
  ];

  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initPrefs();
  }
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<int> getReportCount() async {
    QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('email', isEqualTo: user?.email)
        .get();

    return reportsSnapshot.docs.length;
  }

  Future<void> _sendNotificationAndMessage() async {
    int reportCount = await getReportCount();
    if (reportCount >= 2) {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Attention!'),
            content: const Text('You have reached the limit of 2 reports. Please wait until your reports are resolved.'),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
          ),
        );
      },
    );

    try {
      // await _fetchContactsAndAddToSelected(); // Fetch contacts and add them to selected contacts list

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Access the SelectedContactsProvider to get selected contacts
      final selectedContactsProvider = Provider.of<SelectedContactsProvider>(
        context,
        listen: false,
      );
      List<Contact> selectedContacts = selectedContactsProvider.selectedContacts;
      for (final contact in selectedContacts) {
        for (final Item phone in contact.phones ?? []) {
          final String phoneNumber = phone.value!;
          if (!_selectedContacts.contains(phoneNumber)) {
            _selectedContacts.add(phoneNumber);
          }
        }
      }

      // Remove duplicates if any
      _selectedContacts.toSet().toList();


      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email!)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();

        await FirebaseFirestore.instance.collection('reports').add({
          'name': (userData as Map<String, dynamic>)['first name'],
          'email': (userData)['email'],
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now(),
          'status': 'active'
        });

        String latitude = position.latitude.toString();
        String longitude = position.longitude.toString();
        String mapsLink = 'https://www.google.com/maps?q=$latitude,$longitude';
        String message = 'Emergency at $mapsLink';

        final String smsUri =
            'sms:${_selectedContacts.join(",")}?body=${Uri.encodeFull(message)}';

        if (await canLaunchUrl(Uri.parse(smsUri))) {
          await launchUrl(Uri.parse(smsUri));
        } else {
          throw 'Could not launch SMS';
        }

        Navigator.of(context).pop();

        await showDialog(
          context: context,
          builder: (context) {
            return const CupertinoAlertDialog(
              title: Text(
                  'Your location has been sent to the police and the selected contacts.'),
            );
          },
        );
      } else {
        throw 'User not found';
      }
    } catch (error) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Click the button below to send a report!',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: _sendNotificationAndMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50),
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(
                    Icons.report,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '1. Make sure to give necessary permissions.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '2. Please select your contacts in the settings.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '3. Make sure to press on send while sending SMS.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '4. Your location will be sent to users of the App to aid you.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '5. Please make sure to deactivate the report in the settings.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          options: MapOptions(
                            initialCenter: _currentPosition!,
                            initialZoom: 14,
                          ),
                          children: [
                            openStreetMapTileLater,
                            MarkerLayer(markers: [
                              Marker(
                                point: _currentPosition!,
                                width: 80.0,
                                height: 80.0,
                                child: const Icon(
                                  Icons.location_pin,
                                  size: 60,
                                  color: Colors.red,
                                ),
                              )
                            ])
                          ],
                        ))
            ],
          ),
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLater => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
