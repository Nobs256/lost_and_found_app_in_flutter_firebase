// import 'package:cloudinary_sdk/cloudinary_sdk.dart';

// class CloudinaryConfig {
//   static const String cloudName = 'your-cloud-name';
//   static const String apiKey = 'your-api-key';
//   static const String apiSecret = 'your-api-secret';

//   static Cloudinary cloudinary = Cloudinary(
//     cloudName: cloudName,
//     apiKey: apiKey,
//     apiSecret: apiSecret,
//   );
// }



// Future<String?> uploadImage(File? image) async {
//   if (image != null) {
//     final Cloudinary cloudinary = CloudinaryConfig.cloudinary;
//     final UploadResult result = await cloudinary.upload(
//       image.path,
//       options: UploadOptions(
//         folder: 'images',
//         publicId: DateTime.now().millisecondsSinceEpoch.toString(),
//       ),
//     );
//     return result.secureUrl;
//   } else {
//     return 'assets/images/post.jpeg';
//   }
// }



// onPressed: () async {
//   if (_formKey.currentState!.validate()) {
//     final String? imageUrl = await uploadImage(_image);
//     final Uuid uuid = Uuid();
//     final String uniqueId = uuid.v4();
//     Map<String, dynamic> lostItem = {
//       'name': _fullNameController.text,
//       'address': _addressController.text,
//       'lostItem': _lostItemController.text,
//       'areaOfLossing': _areaoflossing.text,
//       'placementStation': _placementstation.text,
//       'institution': _selectedInstitution,
//       'description': _descriptionController.text,
//       'status': 'lost',
//       'postTime': DateTime.now().toString(),
//       'ownerId': _auth.currentUser!.uid,
//       'uniqueId': uniqueId,
//       'image': imageUrl,
//     };

//     try {
//       // Insert data into Firestore
//       await _firestore.collection('lostItems').add(lostItem);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Report submitted successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to submit report: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// },







// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http; // Import http
// import 'dart:convert';
// import 'package:uuid/uuid.dart';

// import '../home_screen.dart';

// class AddPostItem extends StatefulWidget {
//   const AddPostItem({super.key});

//   @override
//   _AddPostItemState createState() => _AddPostItemState();
// }

// class _AddPostItemState extends State<AddPostItem> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _lostItemController = TextEditingController();
//   final TextEditingController _areaoflossing = TextEditingController();
//   final TextEditingController _placementstation = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   File? _image;

//   String? _selectedInstitution;
//   final List<String> _institutions = ['NIRA', 'UNEB', 'MUST'];

//   // Cloudinary Configuration
//   final String cloudName = 'YOUR_CLOUD_NAME'; // Replace with your Cloudinary cloud name
//   final String uploadPreset = 'YOUR_UPLOAD_PRESET'; // Replace with your Cloudinary upload preset

//   Future<void> _selectImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (image != null) {
//         _image = File(image.path);
//       } else {
//         _image = null;
//       }
//     });
//   }

//   Future<String?> uploadImageToCloudinary(File? image) async {
//     if (image == null) {
//       return 'assets/images/post.jpeg'; // Default image if no image is selected
//     }

//     try {
//       final uri = Uri.parse(
//           'https://api.cloudinary.com/v1_1/$cloudName/image/upload?upload_preset=$uploadPreset');
//       final request = http.MultipartRequest('POST', uri);
//       final http.MultipartFile multipartFile =
//           await http.MultipartFile.fromPath('file', image.path);
//       request.files.add(multipartFile);

//       final http.StreamedResponse response = await request.send();
//       final http.Response httpResponse =
//           await http.Response.fromStream(response);

//       if (httpResponse.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(httpResponse.body);
//         return responseData['secure_url'];
//       } else {
//         print('Cloudinary upload failed: ${httpResponse.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error uploading to Cloudinary: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildFormField(
//                 controller: _fullNameController,
//                 label: "Full Name",
//                 icon: Icons.person_outline,
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 controller: _addressController,
//                 label: "Address",
//                 icon: Icons.location_on_outlined,
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 controller: _lostItemController,
//                 label: "Item Lost",
//                 icon: Icons.search_off_outlined,
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 controller: _areaoflossing,
//                 label: "Area of lossing",
//                 icon: Icons.location_on_outlined,
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 controller: _placementstation,
//                 label: "Placement station",
//                 icon: Icons.home_repair_service,
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 controller: null,
//                 label: "Institution",
//                 icon: Icons.home,
//                 isDropdown: true,
//                 items: _institutions,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedInstitution = value;
//                   });
//                 },
//                 value: _selectedInstitution,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   labelText: "Description",
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: const Icon(Icons.description_outlined),
//                   hintText: "Describe the lost item (color, size, special marks...)",
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please provide a description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         TextButton.icon(
//                           icon: const Icon(Icons.camera_alt_outlined, size: 22),
//                           label: const Text("Add Photo"),
//                           style: TextButton.styleFrom(
//                             foregroundColor: Colors.blue,
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               side: const BorderSide(color: Colors.blue),
//                             ),
//                           ),
//                           onPressed: _selectImage,
//                         ),
//                         Text(
//                           _image != null ? _image!.path.split('/').last : "No image selected",
//                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                         const Text(
//                           "Note: Please only fill this form if you have a photo to upload.",
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.send_outlined, size: 22),
//                       label: const Text("Submit Report"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           final String? imageUrl = await uploadImageToCloudinary(_image);
//                           if(imageUrl == null){
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Image upload to cloudinary failed'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }
//                           final Uuid uuid = const Uuid();
//                           final String uniqueId = uuid.v4();
//                           Map<String, dynamic> lostItem = {
//                             'name': _fullNameController.text,
//                             'address': _addressController.text,
//                             'lostItem': _lostItemController.text,
//                             'areaOfLossing': _areaoflossing.text,
//                             'placementStation': _placementstation.text,
//                             'institution': _selectedInstitution,
//                             'description': _descriptionController.text,
//                             'status': 'lost',
//                             'postTime': DateTime.now().toString(),
//                             'ownerId': _auth.currentUser!.uid,
//                             'uniqueId': uniqueId,
//                             'image': imageUrl,
//                           };

//                           try {
//                             await _firestore.collection('lostItems').add(lostItem);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Report submitted successfully'),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (context) => const HomeScreen()),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(