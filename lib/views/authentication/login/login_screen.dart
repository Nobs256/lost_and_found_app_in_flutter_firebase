import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../components/txt_box.dart';
import '../../../src/app_color.dart';
import '../../home/home_screen.dart';
import '../../home/policeforms/allforms.dart';
import '../register/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Local state for loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.defaultColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildLoginForm(),
            _buildSignUpSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
        color: AppColor.defaultColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Login to continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TxtBox(
              label: 'Email Address',
              txtController: emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 25),
            TxtBox(
              label: 'Password',
              txtController: passwordController,
              icon: Icons.lock,
              keyboardType: TextInputType.visiblePassword,
              // obscureText: true,
            ),
            TextButton(
              onPressed: () {
                // Handle forget password
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.defaultColor, textStyle: TextStyle(fontSize: 13),
              ),
              child: Text('Forget Password?'),
            ),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }
  Widget _buildLoginButton() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : MaterialButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  isLoading = true; // Set loading state
                });

                try {
                  // Sign in with Firebase authentication
                  final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  // Get the user's ID
                  final String userId = userCredential.user!.uid;

                  // Get the user's category from Firestore
                  final DocumentSnapshot userDocument = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                  final String userCategory = userDocument['category'];

                  // Simulate a delay for login process
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      isLoading = false; // Reset loading state
                    });

                    // Redirect to AllFormsScreen if the user's category is "Police"
                    if (userCategory == 'Police') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AllformsView()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  });
                } catch (e) {
                  // Login failed
                  setState(() {
                    isLoading = false; // Reset loading state
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid email or password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            color: AppColor.defaultColor,
            height: 60,
            minWidth: 250,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'LOGIN',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        );
  }


  Widget _buildSignUpSection(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New User?',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColor.defaultColor, padding: EdgeInsets.all(0),
            ),
            child: Text(
              ' Sign Up',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}