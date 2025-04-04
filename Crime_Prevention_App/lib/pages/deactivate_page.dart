import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeactivateReports extends StatefulWidget {
  const DeactivateReports({super.key});

  @override
  State<DeactivateReports> createState() => _DeactivateReportsState();
}

class _DeactivateReportsState extends State<DeactivateReports> {
  late final String currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
  }

  Future<void> _updateStatus(String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .update({'status': 'inactive'});
      setState(() {}); // Refresh the list view
    } catch (error) {
      // Handle any errors that occur during the update process
      // ignore: avoid_print
      print('Error updating report status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Reports'),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.black,
        color: Colors.white,
        onRefresh: () async {
          // Implement your refresh logic here
          setState(() {const DeactivateReports();}); // Refresh the list view
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('status', isEqualTo: 'active') // Filter by status == 'active'
              .where('email', isEqualTo: currentUserEmail) // Filter by user's email
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final reports = snapshot.data!.docs;
            if (reports.isEmpty) {
              return const Center(
                child: Text('No active reports available for the current user.'),
              );
            }
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final timestamp = (report['timestamp'] as Timestamp).toDate();
                return ListTile(
                  title: Text('Date: ${timestamp.toString()}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () => _updateStatus(report.id),
                    child: const Text(
                      'Deactivate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
