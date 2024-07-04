import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitify/Models/groupmodel.dart';
import 'package:splitify/Models/usermodel.dart';


class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<UserModel> _selectedUsers = [];
  List<UserModel> _searchResults = [];
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(labelText: 'Group Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Add Users by Email'),
                onChanged: _searchUsersByEmail,
              ),
              Expanded(child: _buildSearchResults()),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGroup,
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _searchUsersByEmail(String email) async {
    if (email.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: email)
        .where('email', isLessThanOrEqualTo: '$email\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs
          .where((doc) => doc.id != currentUser!.uid) // Exclude current user
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var user = _searchResults[index];
        bool isSelected = _selectedUsers.any((u) => u.id == user.id);
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: isSelected
              ? Icon(Icons.check, color: Colors.green)
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedUsers.add(user);
                    });
                  },
                  child: Text('Add'),
                ),
        );
      },
    );
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      List<String> memberIds = [currentUser!.uid];
      memberIds.addAll(_selectedUsers.map((user) => user.id));

      GroupModel group = GroupModel(
        id: '', // Firestore will generate this
        name: _groupNameController.text,
        description: _groupDescriptionController.text,
        members: memberIds,
        createdBy: currentUser!.uid,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('groups').add(group.toFirestore());

      Navigator.pop(context);
    }
  }
}
