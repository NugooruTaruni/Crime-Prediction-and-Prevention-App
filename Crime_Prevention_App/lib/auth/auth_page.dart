import 'package:crime_pnr/pages/login_page.dart';
import 'package:flutter/material.dart';

import '../pages/register_page.dart';
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  //initially, show the login page
  bool showLoginPage = true;
  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }


  @override
  Widget build(BuildContext context) {
    if(showLoginPage) {
      return LoginPage(showRegisterpage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
