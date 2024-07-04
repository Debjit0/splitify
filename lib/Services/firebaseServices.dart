import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:splitify/Models/expensemodel.dart';
import 'package:splitify/Pages/signin.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  firebaseLogout() async {
    await _auth.signOut();
    Get.to(SignInScreen());
  }

  createGroup(String gname, String gdesc, List memIds, String createdBy)async{
    await FirebaseFirestore.instance.collection('groups').add({
        'name': gname,
        'description': gdesc,
        'members': memIds,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
  }

  void saveExpense(ExpenseModel expense) {
    Map<String, dynamic> expenseMap = expense.toMap();

    FirebaseFirestore.instance.collection('expenses').add(expenseMap);
  }
}
