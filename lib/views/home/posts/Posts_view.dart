// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../authentication/databasehelper.dart';
import '../home_screen.dart';

import 'email_sender.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({super.key});

  @override
  _PostViewScreenState createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _currentUserCategory = '';
  String _selectedInstitution = '';
  String _selectedLostItem = '';
  String _selectedAreaOfLossing = '';
  // String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        _currentUserCategory = value.data()!['category'];
      });
    });
    // _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _currentUserCategory == 'Institution' ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Posts"),
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Lost'),
              Tab(text: 'Found'),
              if (_currentUserCategory == 'Institution')
                Tab(text: 'Claim/Taken'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilter(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPosts('lost'),
                  _buildPosts('found'),
                  if (_currentUserCategory == 'Institution')
                    _buildClaimTakenPosts(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimTakenPosts() {
    return FutureBuilder(
      future: Future.wait([
        DatabaseHelper().getImages(),
        _firestore.collection('lostItems').orderBy('postTime').get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<File> images = snapshot.data![0] as List<File>;
          QuerySnapshot querySnapshot = snapshot.data![1] as QuerySnapshot;
          List<Map<String, dynamic>> posts = querySnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList()
              .cast<Map<String, dynamic>>();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              if ((post['status'] == 'claimed' || post['status'] == 'taken') &&
                  (post['institution'] == _selectedInstitution ||
                      _selectedInstitution.isEmpty) &&
                  (post['lostItem'] == _selectedLostItem ||
                      _selectedLostItem.isEmpty) &&
                  (post['areaOfLossing'] == _selectedAreaOfLossing ||
                      _selectedAreaOfLossing.isEmpty)) {
                return PostCard(
                  postId: post['id'] ?? '',
                  userName: post['name'] ?? '',
                  nin: post['nin'] ?? '',
                  userImage: 'assets/images/profile.png',
                  postTime: post['postTime'] != null
                      ? DateTime.parse(post['postTime'])
                      : DateTime.now(),
                  postStatus: post['status'] ?? '',
                  postText: post['description'] ?? '',
                  postImage: images.length > index ? images[index].path : '',
                  address: post['address'] ?? '',
                  lostItem: post['lostItem'] ?? '',
                  areaOfLossing: post['areaOfLossing'] ?? '',
                  placementStation: post['placementStation'] ?? '',
                  reward: post['reward'] ?? '',
                  ownerId: post['ownerId'] ?? '',
                  institution: post['institution'] ?? '',
                  currentUserCategory: _currentUserCategory,
                );
              } else {
                return Container();
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildFilter() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('lostItems').orderBy('postTime').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available'));
          } else {
            List<Map<String, dynamic>> posts = snapshot.data!.docs
                .map((doc) => doc.data())
                .toList()
                .cast<Map<String, dynamic>>();
            String? institution = posts.first['institution'];
            String? lostItem = posts.first['lostItem'];
            String? areaOfLossing = posts.first['areaOfLossing'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Institution',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedInstitution.isEmpty
                          ? institution
                          : _selectedInstitution,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedInstitution = newValue!;
                        });
                      },
                      items: posts
                          .map((post) => post['institution'])
                          .toSet()
                          .map<DropdownMenuItem<String>>((institution) {
                        return DropdownMenuItem<String>(
                          value: institution,
                          child: Text(
                            institution,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lost Item',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLostItem.isEmpty
                          ? lostItem
                          : _selectedLostItem,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLostItem = newValue!;
                        });
                      },
                      items: posts
                          .map((post) => post['lostItem'])
                          .toSet()
                          .map<DropdownMenuItem<String>>((lostItem) {
                        return DropdownMenuItem<String>(
                          value: lostItem,
                          child: Text(lostItem),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Area of Lossing',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedAreaOfLossing.isEmpty
                          ? areaOfLossing
                          : _selectedAreaOfLossing,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAreaOfLossing = newValue!;
                        });
                      },
                      items: posts
                          .map((post) => post['areaOfLossing'])
                          .toSet()
                          .map<DropdownMenuItem<String>>((areaOfLossing) {
                        return DropdownMenuItem<String>(
                          value: areaOfLossing,
                          child: Text(areaOfLossing),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildPosts(String status) {
    return FutureBuilder(
      future: Future.wait([
        DatabaseHelper().getImages(),
        _firestore.collection('lostItems').orderBy('postTime').get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<File> images = snapshot.data![0] as List<File>;
          QuerySnapshot querySnapshot = snapshot.data![1] as QuerySnapshot;
          List<Map<String, dynamic>> posts = querySnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList()
              .cast<Map<String, dynamic>>();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              if (post['status'] == status &&
                  (post['institution'] == _selectedInstitution ||
                      _selectedInstitution.isEmpty) &&
                  (post['lostItem'] == _selectedLostItem ||
                      _selectedLostItem.isEmpty) &&
                  (post['areaOfLossing'] == _selectedAreaOfLossing ||
                      _selectedAreaOfLossing.isEmpty)) {
                return PostCard(
                  postId: post['id'] ?? '',
                  userName: post['name'] ?? '',
                  nin: post['nin'] ?? '',
                  userImage: 'assets/images/profile.png',
                  postTime: post['postTime'] != null
                      ? DateTime.parse(post['postTime'])
                      : DateTime.now(),
                  postStatus: post['status'] ?? '',
                  postText: post['description'] ?? '',
                  postImage: images.length > index ? images[index].path : '',
                  address: post['address'] ?? '',
                  lostItem: post['lostItem'] ?? '',
                  areaOfLossing: post['areaOfLossing'] ?? '',
                  placementStation: post['placementStation'] ?? '',
                  institution: post['institution'] ?? '',
                  reward: post['reward'] ?? '',
                  ownerId: post['ownerId'] ?? '',
                  currentUserCategory: _currentUserCategory,
                );
              } else {
                return Container();
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String userName;
  final String nin;
  final String userImage;
  final DateTime postTime;
  final String postStatus;
  final String postText;
  final String postImage;
  final String address;
  final String lostItem;
  final String areaOfLossing;
  final String placementStation;
  final String institution;
  final String reward;
  final String ownerId;
  final String currentUserCategory;

  PostCard({
    required this.postId,
    required this.userName,
    required this.nin,
    required this.userImage,
    required this.postTime,
    required this.postStatus,
    required this.postText,
    required this.postImage,
    required this.address,
    required this.lostItem,
    required this.areaOfLossing,
    required this.placementStation,
    required this.institution,
    required this.reward,
    required this.ownerId,
    required this.currentUserCategory,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPostDetails,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.userImage),
                    radius: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(widget.postTime),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10),
            //   child: Container(
            //     margin: EdgeInsets.symmetric(horizontal: 12),
            //     height: 180, // Reduced image height
            //     width: double.infinity,
            //     child: File(widget.postImage).existsSync()
            //         ? Image.file(
            //             File(widget.postImage),
            //             fit: BoxFit.cover,
            //           )
            //         : Icon(
            //             Icons.image,
            //             size: 100,
            //             color: Colors.grey[400],
            //           ),
            //   ),
            // ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                height: 180, // Reduced image height
                width: double.infinity,
                child: File(widget.postImage).existsSync()
                    ? Image.file(
                        File(widget.postImage),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/logo.png', // Show the logo image from assets
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
              ),
            ),

            // Interaction Icons and Status
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.postStatus == 'lost'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.postStatus == 'lost'
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.postStatus.toUpperCase(),
                          style: TextStyle(
                            color: widget.postStatus == 'lost'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                        widget.currentUserCategory == 'Institution'
                            ? IconButton(
                                icon: Icon(Icons.edit, size: 16),
                                onPressed: () {
                                  _showEditPostStatusDialog();
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      (widget.postStatus == 'found' &&
                              widget.currentUserCategory == 'User' &&
                              widget.ownerId ==
                                  FirebaseAuth.instance.currentUser!.uid)
                          ? ElevatedButton(
                              onPressed: () {
                                _showClaimDialog();
                              },
                              child: Text('Claim'),
                            )
                          : Container(),
                      SizedBox(width: 8),
                      (widget.postStatus == 'claimed' &&
                              widget.currentUserCategory == 'Institution')
                          ? ElevatedButton(
                              onPressed: () {
                                _showVerifyDialog();
                              },
                              child: Text('Verify'),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            // Text Content
            Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, bottom: 12), // Fixed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    widget.postText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//   void _showClaimDialog() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       final TextEditingController policeCaseNumberController =
//           TextEditingController();

//       return AlertDialog(
//         title: Text('Claim Item'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Please enter the police case number:'),
//             SizedBox(height: 16),
//             TextField(
//               controller: policeCaseNumberController,
//               decoration: InputDecoration(
//                 labelText: 'Police Case Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Claim'),
//             onPressed: () async {
//               final caseNumber = policeCaseNumberController.text;

//               // Check if the case number is valid and has status "up for claim"
//               final caseDoc = await FirebaseFirestore.instance
//                   .collection('cases')
//                   .where('caseNumber', isEqualTo: caseNumber)
//                   .where('status', isEqualTo: 'up for claim')
//                   .get();

//               if (caseDoc.docs.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Invalid or already claimed case number')),
//                 );
//               } else {
//                 // Proceed with claiming the item
//                 await FirebaseFirestore.instance
//                     .collection('lostItems')
//                     .doc(widget.postId)
//                     .update({
//                       'status': 'claimed',
//                     });

//                 // Update the case status to "claimed"
//                 await FirebaseFirestore.instance
//                     .collection('cases')
//                     .doc(caseDoc.docs.first.id) // Get the document ID
//                     .update({
//                       'status': 'claimed',
//                     });

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Item claimed successfully')),
//                 );
//               }

//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController policeCaseNumberController =
            TextEditingController();

        return AlertDialog(
          title: Text('Claim Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter the police case number:'),
              SizedBox(height: 16),
              TextField(
                controller: policeCaseNumberController,
                decoration: InputDecoration(
                  labelText: 'Police Case Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Claim'),
              onPressed: () async {
                final caseNumber = policeCaseNumberController.text;

                // Check if the case number is valid and has status "up for claim"
                final caseDoc = await FirebaseFirestore.instance
                    .collection('cases')
                    .where('caseNumber', isEqualTo: caseNumber)
                    .where('status', isEqualTo: 'up for claim')
                    .get();

                if (caseDoc.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Invalid or already claimed case number')),
                  );
                } else {
                  // Proceed with claiming the item
                  await FirebaseFirestore.instance
                      .collection('lostItems')
                      .doc(widget.postId)
                      .update({
                    'status': 'claimed',
                  });

                  // Update the case status to "claimed"
                  await FirebaseFirestore.instance
                      .collection('cases')
                      .doc(caseDoc.docs.first.id) // Get the document ID
                      .update({
                    'status': 'claimed',
                  });

                  // Send email to the owner
                  String ownerEmail =
                      ''; // Fetch the owner's email from Firestore
                  DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.ownerId)
                      .get();
                  if (ownerDoc.exists) {
                    ownerEmail = ownerDoc['email'];
                  }

                  await EmailService.sendEmail(
                    ownerEmail,
                    'Item Claimed',
                    'Your item has been claimed. Please check the status.',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item claimed successfully')),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void _showVerifyDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Verify Item'),
  //         content: Text('Are you sure you want to verify this item?'),
  //         actions: [
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Verify'),
  //             onPressed: () async {
  //               await FirebaseFirestore.instance
  //                   .collection('lostItems')
  //                   .doc(widget.postId)
  //                   .update({
  //                     'status': 'taken',
  //                   });

  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Item verified successfully')),
  //               );

  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Item'),
          content: Text('Are you sure you want to verify this item?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Verify'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('lostItems')
                    .doc(widget.postId)
                    .update({
                  'status': 'taken',
                });

                // Send email to the owner
                String ownerEmail =
                    ''; // Fetch the owner's email from Firestore
                DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.ownerId)
                    .get();
                if (ownerDoc.exists) {
                  ownerEmail = ownerDoc['email'];
                }

                await EmailService.sendEmail(
                  ownerEmail,
                  'Item Verified',
                  'Your item has been verified as taken. Thank you for your cooperation.',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item verified successfully')),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPostDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Post Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User  Name: ${widget.userName}'),
              Text('Post NIN: ${widget.nin}'),
              Text('Address: ${widget.address}'),
              Text('Lost Item: ${widget.lostItem}'),
              Text('Area of Lossing: ${widget.areaOfLossing}'),
              Text('Placement Station: ${widget.placementStation}'),
              Text('Institution: ${widget.institution}'),
              Text('Post Time: ${widget.postTime}'),
              Text('Post Status: ${widget.postStatus}'),
              Text('Post Text: ${widget.postText}'),
              Text('Post Reward: ${widget.reward}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//   void _showEditPostStatusDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         String _newStatus = widget.postStatus;

//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Edit Post Status'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Select a new post status:'),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _newStatus = 'lost';
//                           });
//                           _updatePostStatus(_newStatus);
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Lost'),
//                       ),
//                       SizedBox(width: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _newStatus = 'found';
//                           });
//                           _updatePostStatus(_newStatus);
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Found'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _updatePostStatus(String newStatus) async {
//     try {
//       await FirebaseFirestore.instance.collection('lostItems').doc(widget.postId).update({
//         'status': newStatus,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Post status updated successfully')),
//       );
//       Navigator.of(context).pop(); // Close the dialog
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       ); // Navigate to HomeScreen
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update post status: $e')),
//       );
//     }
//   }
// }
  void _showEditPostStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String _newStatus = widget.postStatus;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Post Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select a new post status:'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _newStatus = 'lost';
                          });
                          _updatePostStatus(_newStatus);
                          Navigator.of(context).pop();
                        },
                        child: Text('Lost'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _newStatus = 'found';
                          });
                          _updatePostStatus(_newStatus);
                          Navigator.of(context).pop();
                        },
                        child: Text('Found'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updatePostStatus(String newStatus) async {
    try {
      // Update the status of the post
      await FirebaseFirestore.instance
          .collection('lostItems')
          .doc(widget.postId)
          .update({
        'status': newStatus,
      });

      // Fetch the owner's email
      String ownerEmail = ''; // Initialize the variable
      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ownerId)
          .get();
      if (ownerDoc.exists) {
        ownerEmail = ownerDoc['email'];
      }

      // Send email notification if the status is 'found'
      if (newStatus == 'found') {
        await EmailService.sendEmail(
          ownerEmail,
          'Item Found',
          'Good news! Your lost item has been found. Please check the app for more details.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post status updated successfully')),
      );
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ); // Navigate to HomeScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post status: $e')),
      );
    }
  }
}
