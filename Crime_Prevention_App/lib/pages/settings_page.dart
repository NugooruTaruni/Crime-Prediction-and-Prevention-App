// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:provider/provider.dart';
import 'deactivate_page.dart';
import 'selected_contacts_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Required Permissions'),
      ),
      body: ListView(
        children: [
          _buildPermissionTile(
            context,
            'Location',
            'Required for accessing device location to provide location-based services.',
            Permission.location,
          ),
          _buildPermissionTile(
            context,
            'Camera',
            'Required for capturing photos and videos.',
            Permission.camera,
          ),
          _buildPermissionTile(
            context,
            'Storage',
            'Required for accessing device storage to save and retrieve data.',
            Permission.storage,
          ),
          ListTile(
            title: const Text('Contacts'),
            subtitle:
                const Text('Required for accessing contacts to send SMSs.'),
            leading: const Icon(Icons.contacts),
            onTap: () => _addContactFromPhonebook(context),
          ),
          ListTile(
            title: const Text('Selected Contacts'),
            subtitle: const Text('Tap to view selected contacts'),
            leading: const Icon(Icons.list),
            onTap: () =>
                _showSelectedContacts(context), // Call the function here
          ),
          ListTile(
            title: const Text('View Reports'),
            subtitle:
                const Text('Tap to view all records from reports collection'),
            leading: const Icon(Icons.receipt),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeactivateReports()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Logged in as: ${user?.email ?? 'Unknown'}'),
              ElevatedButton(
                onPressed: () async => await FirebaseAuth.instance.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black background color
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    String title,
    String subtitle,
    Permission permission,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.security),
      onTap: () => _requestPermission(context, permission),
    );
  }

  Future<void> _requestPermission(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await permission.request();
    if (status.isDenied) {
      // Show dialog to open app settings
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Please grant the required permission in the settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Open app settings
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  // Future<void> _addContactFromPhonebook(BuildContext context) async {
  //   final PermissionStatus permissionStatus =
  //   await Permission.contacts.request();
  //   if (permissionStatus.isGranted) {
  //     try {
  //       final Contact? newContact =
  //       await ContactsService.openDeviceContactPicker();
  //       if (newContact != null) {
  //         Provider.of<SelectedContactsProvider>(context, listen: false)
  //             .addContact(newContact);
  //         final selectedContactsProvider = Provider.of<SelectedContactsProvider>(context, listen: false);
  //         Navigator.pop(context);
  //         Navigator.pop(context, selectedContactsProvider.selectedContacts);
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //               content:
  //               Text('Contact added: ${newContact.displayName ?? ""}')),
  //         );
  //       }
  //     } catch (e) {
  //       // ignore: avoid_print
  //       print('Error adding contact: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error adding contact: $e')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Permission denied for accessing contacts.')),
  //     );
  //   }
  // }

  Future<void> _addContactFromPhonebook(BuildContext context) async {
    final PermissionStatus permissionStatus =
        await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      try {
        final Contact? newContact =
            await ContactsService.openDeviceContactPicker();
        if (newContact != null) {
          Provider.of<SelectedContactsProvider>(context, listen: false)
              .addContact(newContact);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Contact added: ${newContact.displayName ?? ""}')),
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error adding contact: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contact: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permission denied for accessing contacts.')),
      );
    }
  }

  void _showSelectedContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SelectedContactsProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              itemCount: provider.selectedContacts.length,
              itemBuilder: (context, index) {
                final contact = provider.selectedContacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones?.first.value ?? ''),
                );
              },
            );
          },
        );
      },
    );
  }
}
