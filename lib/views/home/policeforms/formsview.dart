import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormsView extends StatefulWidget {
  const FormsView({super.key});

  @override
  _FormsViewState createState() => _FormsViewState();
}

class _FormsViewState extends State<FormsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms View'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('lostItems').where('ownerId', isEqualTo: _auth.currentUser!.uid).snapshots(),
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
      ),
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
            Image.asset(
              'assets/images/lost-found-banner.png',
              height: 60, // Set the height to 100
              fit: BoxFit.cover, // Maintain the aspect ratio
            ),
            const SizedBox(height: 16),
            Text(
              'Serial no: ${document['uniqueId']}',
              style: TextStyle(
                color: Colors.red, // Set the color to red
              ),
            ),
            Text('Name: ${document['name']}'),
            Text('Address: ${document['address']}'),
            Text('Lost Item: ${document['lostItem']}'),
            Text('Area of Lossing: ${document['areaOfLossing']}'),
            Text('Placement Station: ${document['placementStation']}'),
            Text('Institution: ${document['institution']}'),
            Text('Description: ${document['description']}'),
            Text('Status: ${document['status']}'),
            Text('Post Time: ${document['postTime']}'),
            if (document['image'] != null)
              Image.network(document['image']),
          ],
        ),
      ),
    );
  }
}