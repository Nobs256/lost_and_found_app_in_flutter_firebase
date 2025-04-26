import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/databasehelper.dart';
import '../home_screen.dart';

class AddPostItem extends StatefulWidget {
  const AddPostItem({super.key});

  @override
  _AddPostItemState createState() => _AddPostItemState();
}

class _AddPostItemState extends State<AddPostItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ninController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _lostItemController = TextEditingController();
  final TextEditingController _areaoflossing = TextEditingController();
  final TextEditingController _placementstation = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;

  String? _selectedInstitution;
  final List<String> _institutions = ['NIRA', 'UNEB', 'MUST','MUBS', 'BSU', 'URA', 'BANK'];


  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        _image = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                controller: _fullNameController,
                label: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              // _buildFormField(
              //   controller: _ninController,
              //   label: "NIN",
              //   icon: Icons.person_outline,
              // ),
              _buildFormField(
                controller: _ninController,
                label: "NIN (Optional)", // Updated label to indicate it's optional
                icon: Icons.person_outline,
                isOptional: true, // New parameter to indicate optional field
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _addressController,
                label: "Address",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _lostItemController,
                label: "Item Lost",
                icon: Icons.search_off_outlined,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _areaoflossing,
                label: "Area of lossing",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _placementstation,
                label: "Placement station",
                icon: Icons.home_repair_service,
              ),
              const SizedBox(height: 20),
              // _buildFormField(
              //   controller: _institution,
              //   label: "Institution",
              //   icon: Icons.home,
              // ),
              _buildFormField(
                controller: null,
                label: "Institution",
                icon: Icons.home,
                isDropdown: true,
                items: _institutions,
                onChanged: (value) {
                  setState(() {
                    _selectedInstitution = value;
                  });
                },
                value: _selectedInstitution,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                  hintText: "Describe the lost item (color, size, special marks...)",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
             
              const SizedBox(height: 20),
              _buildFormField(
                controller: _rewardsController,
                label: "reward (Optional)",
                icon: Icons.money_sharp,
                isOptional: true,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined, size: 22),
                          label: const Text("Add Photo (Optional)"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          onPressed: _selectImage,
                        ),
                        Text(
                          _image != null ? basename(_image!.path) : "No image selected",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        // const Text(
                        //   "Note: Please if you don't have a document photo to upload leave the photo field blank.",
                        //   style: TextStyle(fontSize: 12, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_outlined, size: 22),
                      label: const Text("Submit Report"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final DatabaseHelper _databaseHelper = DatabaseHelper();
                          
                          // Only insert the image if it is not null
                          if (_image != null) {
                            await _databaseHelper.insertImage(_image!);
                          }

                          final Uuid uuid = Uuid();
                          final String uniqueId = uuid.v4();
                          Map<String, dynamic> lostItem = {
                            'name': _fullNameController.text,
                            'nin': _ninController.text,
                            'address': _addressController.text,
                            'lostItem': _lostItemController.text,
                            'areaOfLossing': _areaoflossing.text,
                            'placementStation': _placementstation.text,
                            'institution': _selectedInstitution,
                            'description': _descriptionController.text,
                            'reward': _rewardsController.text,
                            'status': 'lost',
                            'postTime': DateTime.now().toString(),
                            'ownerId': _auth.currentUser !.uid,
                            'uniqueId': uniqueId,
                          };

                          try {
                            // Insert data into Firestore
                            await _firestore.collection('lostItems').add(lostItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Report submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit report: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController? controller,
    required String label,
    required IconData icon,
    bool isDropdown = false,
    List<String>? items,
    Function? onChanged,
    String? value,
    bool isOptional = false, // New parameter for optional fields
  }) {
    if (isDropdown) {
      return DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please select an institution';
          }
          return null;
        },
        items: items?.map((institution) {
          return DropdownMenuItem(
            value: institution,
            child: Text(institution),
          );
        }).toList(),
        onChanged: (value) {
          if (onChanged != null) {
            onChanged(value);
          }
        },
        value: value,
      );
      } else {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(icon),
            hintText: "Enter your $label",
          ),
          validator: (value) {
            // Allow empty value if the field is optional
            if (!isOptional && (value == null || value.isEmpty)) {
              return 'Please enter your $label';
            }
            return null;
          },
        );
      }
    }
}