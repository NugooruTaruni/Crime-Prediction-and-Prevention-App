import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> activeUsers = [];

  @override
  void initState() {
    super.initState();
    fetchActiveUsers();
  }

  fetchActiveUsers() async {

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      activeUsers = snapshot.docs
          .map<Map<String, dynamic>>(
              (doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  launchMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {

    // Dummy data for top crimes
    List<Map<String, dynamic>> topCrimes = [
      {'crime': 'Robbery', 'probability': '23.46'},
      {'crime': 'Assault', 'probability': '19.23'},
      {'crime': 'Burglary', 'probability': '14.93'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section for top crimes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.black,
                  child: const Text(
                    'Top 3 Crimes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                for (int i = 0; i < topCrimes.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0,horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(
                          '${i + 1}. ${topCrimes[i]['crime']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          'Probability: ${topCrimes[i]['probability']}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: const Text(
                'Active Reports',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Name',
                      textAlign: TextAlign.center,
                    )),
                    DataColumn(
                        label: Text(
                      'Email',
                      textAlign: TextAlign.center,
                    )),
                    DataColumn(
                        label: Text(
                      'Location',
                      textAlign: TextAlign.center,
                    )),
                  ],
                  rows: activeUsers.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(
                        user['name'] ?? 'N/A',
                        textAlign: TextAlign.center,
                      )),
                      DataCell(Text(
                        user['email'] ?? 'N/A',
                        textAlign: TextAlign.center,
                      )),
                      DataCell(
                        TextButton(
                          onPressed: () {
                            launchMaps(user['latitude'], user['longitude']);
                          },
                          child: const Text(
                            'Go',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
