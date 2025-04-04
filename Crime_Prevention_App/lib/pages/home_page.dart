import 'package:crime_pnr/pages/search_page.dart';
import 'package:crime_pnr/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:crime_pnr/pages/home_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final user = FirebaseAuth.instance.currentUser;
  int currentIndex = 0;
  void goToPage(index){
    setState(() {
      currentIndex = index;
    });
  }
  final List _pages = [
    //Home Page
    const HomeScreen(),
    //Search page
    const SearchPage(),
    //Settings Page
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_pages[currentIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 18.0),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            onTabChange: (index) => goToPage(index),
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.report_outlined,
                text: 'Report',

              ),
              GButton(
                  icon: Icons.map_sharp,
                text: 'Maps',
              ),
              GButton(
                  icon: Icons.settings,
                  text: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
