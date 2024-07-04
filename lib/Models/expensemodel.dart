import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitify/Models/expenseparticipantmodel.dart';

class ExpenseModel {
  final String id;
  final String groupId;
  final String paidByUserId;
  final List<ExpenseParticipant> participants; // List of participants

  ExpenseModel({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.participants,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<ExpenseParticipant> participants =
        (data['participants'] as List<dynamic>)
            .map((participant) => ExpenseParticipant.fromMap(participant))
            .toList();

    return ExpenseModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      paidByUserId: data['paidByUserId'] ?? '',
      participants: participants,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'paidByUserId': paidByUserId,
      'participants': participants.map((p) => p.toMap()).toList(),
    };
  }
}
