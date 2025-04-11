// import 'package:flutter/material.dart';
// import '../../src/app_color.dart';
// // import 'filters/filter_view.dart';
// import 'policeforms/formsview.dart';
// import 'posts/Posts_view.dart';
// import 'posts/add_post_item.dart';
// import 'profile/profile.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0; 
//   final List<Widget> _screens = [
//     PostViewScreen(),
//     FormsView(),
//     AddPostItem(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColor.defaultColor,
//         elevation: 1.0,
//         title: Image.asset(
//           'assets/images/lost-found-banner.png',
//           height: 40,
//           width: 110,
//         ),
//         automaticallyImplyLeading: false,
//       ),
//       body: _screens[_currentIndex], // Display the selected screen
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex, // Set the current index
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index; // Update the current index
//           });
//         },
//         selectedItemColor: AppColor.secondaryColor,
//         showSelectedLabels: true,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home, color: AppColor.secondaryColor),
//             label: 'Home',
//             backgroundColor: AppColor.defaultColor,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat, color: AppColor.secondaryColor),
//             label: 'Forms',
//             backgroundColor: AppColor.defaultColor,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_to_photos_sharp, color: AppColor.secondaryColor),
//             label: 'Add Post',
//             backgroundColor: AppColor.defaultColor,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_pin, color: AppColor.secondaryColor),
//             label: 'Profile',
//             backgroundColor: AppColor.defaultColor,
//           ),
//         ],
//       ),
//     );
//   }
// }


// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../src/app_color.dart';
import 'policeforms/formsview.dart';
import 'posts/Posts_view.dart';
import 'posts/add_post_item.dart';
import 'profile/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  final List<Widget> _screens = [
    PostViewScreen(),
    FormsView(),
    AddPostItem(),
    ProfilePage(),
  ];

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      // User is on the Home screen
      if (_lastPressedAt == null ||
          DateTime.now().difference(_lastPressedAt!) >
              const Duration(seconds: 2)) {
        // Show a message to press back again to exit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Press back again to exit')),
        );
        _lastPressedAt = DateTime.now();
        return false; // Prevent immediate exit
      }
      // Exit the app
      SystemNavigator.pop();
      return true;
    } else {
      // User is on a different screen, navigate to Home
      setState(() {
        _currentIndex = 0;
      });
      return false; // Prevent immediate pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.defaultColor,
          elevation: 1.0,
          title: Image.asset(
            'assets/images/lost-found-banner.png',
            height: 40,
            width: 110,
          ),
          automaticallyImplyLeading: false,
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColor.secondaryColor,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: AppColor.secondaryColor),
              label: 'Home',
              backgroundColor: AppColor.defaultColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: AppColor.secondaryColor),
              label: 'Forms',
              backgroundColor: AppColor.defaultColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_to_photos_sharp, color: AppColor.secondaryColor),
              label: 'Add Post',
              backgroundColor: AppColor.defaultColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin, color: AppColor.secondaryColor),
              label: 'Profile',
              backgroundColor: AppColor.defaultColor,
            ),
          ],
        ),
      ),
    );
  }
}