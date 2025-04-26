import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'views/authentication/login/login_screen.dart';

class StartUp extends StatefulWidget {
  const StartUp({super.key});

  @override
  State<StartUp> createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward(); // Start the animation immediately

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 6)); // Adjusted delay for better visibility
    welcomePage();
  }

  void welcomePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: media.width,
        height: media.height,
        color: Colors.white, // Set the background color to white
        child: Stack(
          alignment: Alignment.center,
          children: [
            // FadeTransition for the logo image
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                "assets/images/logo.png", // Your logo image
                width: media.width * 0.7, // Adjust the size as needed
                height: media.width * 0.8, // Adjust the size as needed
                fit: BoxFit.contain,
              ),
            ),
            // Typing animation for the welcome message
            Positioned(
              bottom: 35, // Position the text below the image
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome to DocFinder!',
                    textStyle: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366), // Dark blue color
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                  // TypewriterAnimatedText(
                  //   'Your documents are recovered here.',
                  //   textStyle: const TextStyle(
                  //     fontSize: 24.0,
                  //     fontWeight: FontWeight.w500,
                  //     color: Color(0xFF003366), // Dark blue color
                  //   ),
                  //   speed: const Duration(milliseconds: 100),
                  // ),
                  TypewriterAnimatedText(
                    'Let’s recover together!',
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF003366), // Dark blue color
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1, // Set to 1 to show each message once
                pause: const Duration(milliseconds: 1000), // Pause between messages
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}













// // import 'package:flutter/material.dart';

// // import 'views/authentication/login/login_screen.dart';

// // class StartUp extends StatefulWidget {
// //   const StartUp({super.key});

// //   @override
// //   State<StartUp> createState() => _StartUpState();
// // }

// // class _StartUpState extends State<StartUp> {

// //    @override
// //   void initState() {
// //     super.initState();
// //     goWelcomePage();
// //   }

// //   void goWelcomePage() async {
// //     await Future.delayed(const Duration(seconds: 3));
// //     welcomePage();
// //   }

// //   void welcomePage() async {
// //     Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => LoginScreen()),
// //       );
    
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     var media = MediaQuery.of(context).size;
// //     return Scaffold(
// //       body: Container(
// //         width: media.width,
// //         height: media.height,
// //         color: const Color.fromARGB(255, 65, 33, 243), // Set the background color to blue
// //         child: Stack(
// //           alignment: Alignment.center,
// //           children: [
// //             Image.asset(
// //               "assets/images/lost-found-banner.png",
// //               width: media.width * 0.55,
// //               height: media.width * 0.55,
// //               fit: BoxFit.contain,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'views/authentication/login/login_screen.dart';

// class StartUp extends StatefulWidget {
//   const StartUp({super.key});

//   @override
//   State<StartUp> createState() => _StartUpState();
// }

// class _StartUpState extends State<StartUp> {
//   @override
//   void initState() {
//     super.initState();
//     goWelcomePage();
//   }

//   void goWelcomePage() async {
//     await Future.delayed(const Duration(seconds: 10)); // Adjusted delay for better visibility
//     welcomePage();
//   }

//   void welcomePage() async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Container(
//         width: media.width,
//         height: media.height,
//         color: const Color.fromARGB(255, 65, 33, 243), // Set the background color to blue
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Typing animation for the welcome message
//             AnimatedTextKit(
//               animatedTexts: [
//                 TypewriterAnimatedText(
//                   'Welcome to DocFinder!',
//                   textStyle: const TextStyle(
//                     fontSize: 32.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   speed: const Duration(milliseconds: 100),
//                 ),
//                 TypewriterAnimatedText(
//                   'Your documents are recovered here.',
//                   textStyle: const TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                   speed: const Duration(milliseconds: 100),
//                 ),
//                 TypewriterAnimatedText(
//                   'Let’s recover together!',
//                   textStyle: const TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                   speed: const Duration(milliseconds: 100),
//                 ),
//               ],
//               totalRepeatCount: 1, // Set to 1 to show each message once
//               pause: const Duration(milliseconds: 1000), // Pause between messages
//               displayFullTextOnTap: true,
//               stopPauseOnTap: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }