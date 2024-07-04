import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroupModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return GroupModel(
      id: documentId,
      name: data['name'],
      description: data['description'],
      members: List<String>.from(data['members']),
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
