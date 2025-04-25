import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../components/txt_box.dart';
import '../../../src/app_color.dart';
import '../login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedLocation;
  String? selectedCategory; 

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  // var ninController = TextEditingController();
  // var locationController = TextEditingController();
  var categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Local state for loading

  // List of locations and categories
  // final List<String> locations = ['Kakoba', 'Kamukuzi', 'Kihumuru', 'City Town', 'Rwebikona'];
  final List<String> categories = ['User', 'Institution', 'Police'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildSignUpForm(),
            _buildLoginSection(context),
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
      child: Center(
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
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
              label: 'Full Name',
              txtController: nameController,
              icon: Icons.person_rounded,
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 25),
            TxtBox(
              label: 'Phone Number',
              txtController: phoneController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 25),
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
            // SizedBox(height: 25),
            // TxtBox(
            //   label: 'NIN',
            //   txtController: ninController,
            //   icon: Icons.person_rounded,
            //   keyboardType: TextInputType.name,
            // ),
            // SizedBox(height: 25),
            // // Dropdown for location
            // DropdownButtonFormField<String>(
            //   decoration: InputDecoration(
            //     labelText: 'Choose your location',
            //     prefixIcon: Icon(Icons.location_on, color: AppColor.iconsColor),
            //     labelStyle: TextStyle(
            //       color: AppColor.txtShade,
            //     ),
            //     floatingLabelStyle: TextStyle(
            //       color: AppColor.defaultColor,
            //     ),
            //     enabledBorder: OutlineInputBorder(
            //       borderSide: BorderSide(
            //         color: AppColor.secondaryColor,
            //       ),
            //       borderRadius: BorderRadius.circular(25),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderSide: BorderSide(
            //         color: AppColor.defaultColor,
            //       ),
            //       borderRadius: BorderRadius.circular(25),
            //     ),
            //   ),
            //   value: selectedLocation,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       selectedLocation = newValue;
            //     });
            //   },
            //   items: locations.map<DropdownMenuItem<String>>((String location) {
            //     return DropdownMenuItem<String>(
            //       value: location,
            //       child: Text(location),
            //     );
            //   }).toList(),
            //   validator: (value) => value == null ? 'Please select a location' : null,
            // ),
            SizedBox(height: 25),
            // Dropdown for category
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Choose your category',
                prefixIcon: Icon(Icons.category, color: AppColor.iconsColor),
                labelStyle: TextStyle(
                  color: AppColor.txtShade,
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColor.defaultColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.secondaryColor,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.defaultColor,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            SizedBox(height : 25),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : MaterialButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  isLoading = true; // Set loading state
                });

                try {
                  // Create a new user with Firebase authentication
                  final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  // Get the user's ID
                  final String userId = userCredential.user!.uid;

                  // Create a new user document in Firestore
                  await FirebaseFirestore.instance.collection('users').doc(userId).set({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    // 'nin': ninController.text,
                    // 'location': selectedLocation,
                    'category': selectedCategory,
                  });

                  // Simulate a registration process
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      isLoading = false; // Reset loading state
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  });
                } catch (e) {
                  print('Error creating user: $e');
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
              'Sign Up',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
  }


  Widget _buildLoginSection(BuildContext context) {
      return Container(
        alignment: Alignment.center,
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.defaultColor, padding: EdgeInsets.all(0),
              ),
              child: Text(
                ' Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }
}