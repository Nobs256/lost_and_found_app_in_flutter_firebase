import 'package:flutter/material.dart';

import 'views/authentication/login/login_screen.dart';

class StartUp extends StatefulWidget {
  const StartUp({super.key});

  @override
  State<StartUp> createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {

   @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    welcomePage();
  }

  void welcomePage() async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: media.width,
        height: media.height,
        color: const Color.fromARGB(255, 65, 33, 243), // Set the background color to blue
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/lost-found-banner.png",
              width: media.width * 0.55,
              height: media.width * 0.55,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}