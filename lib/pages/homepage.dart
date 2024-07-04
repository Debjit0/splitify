// home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/Components/groupcard.dart';
import 'package:splitify/Models/groupmodel.dart';

import 'package:splitify/Services/firebaseServices.dart';
import 'package:splitify/Pages/creategroup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Groups"), actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            FirebaseServices().firebaseLogout();
          },
        )
      ]),
      body: GroupList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(CreateGroupPage());
        },
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: Text('Please log in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No groups found.'));
        }

        final groupDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: groupDocs.length,
          itemBuilder: (context, index) {
            var group = GroupModel.fromFirestore(
                groupDocs[index].data() as Map<String, dynamic>,
                groupDocs[index].id);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(group.createdBy)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('User not found.'));
                }

                // var createdByUser = UserModel.fromFirestore(
                //     userSnapshot.data!.data() as Map<String, dynamic>,
                //     userSnapshot.data!.id);

                return GroupCard(
                    groupId: group.id,
                    groupName: group.name,
                    groupDescription: group.description,
                    createdByUser: group.createdBy);
              },
            );
          },
        );
      },
    );
  }
}
