class ExpenseParticipant {
  final String userId;
  final String name;
  double amountPaid;
  double amountOwed;

  ExpenseParticipant({
    required this.userId,
    required this.name,
    required this.amountPaid,
    required this.amountOwed,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'amountPaid': amountPaid,
      'amountOwed': amountOwed,
    };
  }

  factory ExpenseParticipant.fromMap(Map<String, dynamic> map) {
    return ExpenseParticipant(
      userId: map['userId'],
      name: map['name'],
      amountPaid: map['amountPaid'],
      amountOwed: map['amountOwed'],
    );
  }
}
