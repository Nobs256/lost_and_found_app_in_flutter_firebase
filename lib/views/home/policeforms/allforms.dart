// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AllformsView extends StatefulWidget {
//   const AllformsView({super.key});

//   @override
//   _AllformsViewState createState() => _AllformsViewState();
// }

// class _AllformsViewState extends State<AllformsView> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Police Forms View'),
//         automaticallyImplyLeading: false,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('lostItems').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               DocumentSnapshot document = snapshot.data!.docs[index];
//               return FormCard(document: document);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class FormCard extends StatelessWidget {
//   final DocumentSnapshot document;

//   const FormCard({super.key, required this.document});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Image.asset(
//               'assets/images/lost-found-banner.png',
//               height: 100, // Set the height to 100
//               fit: BoxFit.cover, // Maintain the aspect ratio
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Serial no: ${document['uniqueId']}',
//               style: TextStyle(
//                 color: Colors.red, // Set the color to red
//               ),
//             ),
//             Text('Name: ${document['name']}'),
//             Text('Address: ${document['address']}'),
//             Text('Lost Item: ${document['lostItem']}'),
//             Text('Area of Lossing: ${document['areaOfLossing']}'),
//             Text('Placement Station: ${document['placementStation']}'),
//             Text('Institution: ${document['institution']}'),
//             Text('Description: ${document['description']}'),
//             Text('Status: ${document['status']}'),
//             Text('Post Time: ${document['postTime']}'),
//             if (document['image'] != null)
//               Image.network(document['image']),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllformsView extends StatefulWidget {
  const AllformsView({super.key});

  @override
  _AllformsViewState createState() => _AllformsViewState();
}

class _AllformsViewState extends State<AllformsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Police Forms View'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Forms'),
              Tab(text: 'Add Case'),
              Tab(text: 'Cases'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildForms(),
            _buildAddCase(),
            _buildCases(),
          ],
        ),
      ),
    );
  }

  Widget _buildForms() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('lostItems').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            return FormCard(document: document);
          },
        );
      },
    );
  }

//   Widget _buildAddCase() {
//   final _formKey = GlobalKey<FormState>();
//   final _caseNumberController = TextEditingController();
//   final _reporterNameController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _itemLostController = TextEditingController();

//   return Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: _caseNumberController,
//             decoration: const InputDecoration(
//               labelText: 'Case Number',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter case number';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _reporterNameController,
//             decoration: const InputDecoration(
//               labelText: 'Reporter Name',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter reporter name';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _phoneNumberController,
//             decoration: const InputDecoration(
//               labelText: 'Phone Number',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter phone number';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _itemLostController,
//             decoration: const InputDecoration(
//               labelText: 'Item Lost',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter item lost';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 try {
//                   await _firestore.collection('cases').add({
//                     'caseNumber': _caseNumberController.text,
//                     'reporterName': _reporterNameController.text,
//                     'phoneNumber': _phoneNumberController.text,
//                     'itemLost': _itemLostController.text,
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Case submitted successfully')),
//                   );
//                   _caseNumberController.clear();
//                   _reporterNameController.clear();
//                   _phoneNumberController.clear();
//                   _itemLostController.clear();
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to submit the case: $e')),
//                   );
//                 }
//               }
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _buildAddCase() {
  final _formKey = GlobalKey<FormState>();
  final _caseNumberController = TextEditingController();
  final _ninController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _itemLostController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _caseNumberController,
            decoration: const InputDecoration(
              labelText: 'Case Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter case number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reporterNameController,
            decoration: const InputDecoration(
              labelText: 'Reporter Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter reporter name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ninController,
            decoration: const InputDecoration(
              labelText: 'NIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _itemLostController,
            decoration: const InputDecoration(
              labelText: 'Item Lost',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item lost';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _firestore.collection('cases').add({
                    'caseNumber': _caseNumberController.text,
                    'reporterName': _reporterNameController.text,
                    'nin': _ninController.text,
                    'phoneNumber': _phoneNumberController.text,
                    'itemLost': _itemLostController.text,
                    'status': 'up for claim', // Set initial status
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Case submitted successfully')),
                  );
                  _caseNumberController.clear();
                  _reporterNameController.clear();
                  _ninController.clear();
                  _phoneNumberController.clear();
                  _itemLostController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit the case: $e')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCases() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('cases').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            return CaseCard(document: document);
          },
        );
      },
    );
  }
}

class FormCard extends StatelessWidget {
  final DocumentSnapshot document;

  const FormCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image.asset(
            //   'assets/images/lost-found-banner.png',
            //   height: 60, // Set the height to 100
            //   fit: BoxFit.cover, // Maintain the aspect ratio
            // ),
            // const SizedBox(height: 16),
            Text(
              'Serial no: ${document['uniqueId']}',
              style: TextStyle(
                color: Colors.red, // Set the color to red
              ),
            ),
            Text('Name: ${document['name']}'),
            // Text('NIN: ${document['nin']}'),
            Text('Address: ${document['address']}'),
            Text('Lost Item: ${document['lostItem']}'),
            Text('Area of Lossing: ${document['areaOfLossing']}'),
            Text('Placement Station: ${document['placementStation']}'),
            Text('Institution: ${document['institution']}'),
            Text('Description: ${document['description']}'),
            Text('Status: ${document['status']}'),
            Text('Post Time: ${document['postTime']}'),
            // if (document['image'] != null)
            //   Image.network(document['image']),
          ],
        ),
      ),
    );
  }
}

class CaseCard extends StatelessWidget {
  final DocumentSnapshot document;

  const CaseCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Case Number: ${document['caseNumber']}'),
            Text('Reporter Name: ${document['reporterName']}'),
            Text('Reporter NIN: ${document['nin']}'),
            Text('Phone Number: ${document['phoneNumber']}'),
            Text('Item Lost: ${document['itemLost']}'),
            Text('Case Status: ${document['status']}'),
          ],
        ),
      ),
    );
  }
}