import 'package:flutter/material.dart';
import 'package:splitify/Pages/grouppage.dart';


class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;
  final String createdByUser;

  GroupCard({
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.createdByUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupPage(
              groupId: groupId,
              groupName: groupName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(groupDescription),
            SizedBox(height: 8.0),
            Text('Created by: $createdByUser'),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupPage(
                      groupId: groupId,
                      groupName: groupName,
                    ),
                  ),
                );
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
