import '../Models/expensemodel.dart';

class Calculations{
  void splitEquallyAmongMembers(ExpenseModel expense, List<String> memberIds) {
  double totalAmount = expense.participants.fold(0.0, (sum, p) => sum + p.amountPaid);
  double equalShare = totalAmount / memberIds.length;

  expense.participants.forEach((p) {
    if (p.userId != expense.paidByUserId) {
      p.amountOwed = equalShare;
    }
  });
}

void splitUnequallyAmongMembers(ExpenseModel expense, Map<String, double> customShares) {
  expense.participants.forEach((p) {
    if (p.userId != expense.paidByUserId && customShares.containsKey(p.userId)) {
      p.amountOwed = customShares[p.userId]!;
    }
  });
}
}