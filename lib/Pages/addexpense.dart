// import 'dart:ffi';
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AddExpensePage extends StatefulWidget {
//   final String groupId;
//   final List<Map<String, dynamic>> groupMembers;
//
//   AddExpensePage({required this.groupId, required this.groupMembers});
//
//   @override
//   _AddExpensePageState createState() => _AddExpensePageState();
// }
//
// class _AddExpensePageState extends State<AddExpensePage> {
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   String _paidByUserId = '';
//   List<Map<String, dynamic>> _selectedParticipants = [];
//   List<double> _participantShares = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _paidByUserId = FirebaseAuth.instance.currentUser!.uid;
//     _participantShares = List<double>.filled(widget.groupMembers.length, 0.0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Expense'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Description'),
//             ),
//             TextFormField(
//               controller: _amountController,
//               decoration: InputDecoration(labelText: 'Amount'),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//             ),
//             DropdownButtonFormField<String>(
//               value: _paidByUserId,
//               items: widget.groupMembers.map((member) {
//                 return DropdownMenuItem<String>(
//                   value: member['id'],
//                   child: Text(member['name']),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _paidByUserId = value!;
//                 });
//               },
//               decoration: InputDecoration(labelText: 'Paid by'),
//             ),
//             SizedBox(height: 20),
//             Text('Select participants:'),
//             Wrap(
//               children: widget.groupMembers.map((member) {
//                 int index = widget.groupMembers.indexOf(member);
//                 return CheckboxListTile(
//                   title: Text(member['name']),
//                   value: _selectedParticipants.contains(member),
//                   onChanged: (bool? selected) {
//                     setState(() {
//                       if (selected!) {
//                         _selectedParticipants.add(member);
//                       } else {
//                         _selectedParticipants.remove(member);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             if (_selectedParticipants.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Enter shares (as decimal):'),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _selectedParticipants.length,
//                     itemBuilder: (context, index) {
//                       var participant = _selectedParticipants[index];
//                       return Row(
//                         children: [
//                           Expanded(
//                             child: Text(participant['name']),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             flex: 2,
//                             child: TextFormField(
//                               keyboardType: TextInputType.numberWithOptions(decimal: true),
//                               onChanged: (value) {
//                                 _participantShares[index] = double.tryParse(value) ?? 0.0;
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _addExpense();
//               },
//               child: Text('Add Expense'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addExpense() async {
//     String description = _descriptionController.text.trim();
//     double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
//
//     if (description.isEmpty || amount <= 0 || _paidByUserId.isEmpty || _selectedParticipants.isEmpty) {
//       return;
//     }
//
//     // Prepare expense data
//     List<Map<String, dynamic>> participantsData = _selectedParticipants.map((participant) {
//       int index = widget.groupMembers.indexOf(participant);
//       double share = _participantShares[index];
//       return {
//         'userId': participant['id'],
//         'share': share,
//       };
//     }).toList();
//
//     Map<String, dynamic> expenseData = {
//       'groupId': widget.groupId,
//       'description': description,
//       'amount': amount,
//       'paidByUserId': _paidByUserId,
//       'participants': participantsData,
//       'createdAt': FieldValue.serverTimestamp(),
//     };
//     double individualShare = amount/_selectedParticipants.length;
//     Map<String, double> toGetMap = {};
//
//     // Set the values in the map
//     for (var participant in _selectedParticipants) {
//       // print("$participant participant");
//       // print("$_paidByUserId paidby");
//       if (participant['id'] == _paidByUserId) {
//         toGetMap[participant['id']] = 0.0;
//       } else {
//         toGetMap[participant['id']] = individualShare;
//       }
//     }
//     print("$toGetMap to get map");
//
//
//     // try {
//     //   // Update expenses collection
//     //   DocumentReference docRef = await FirebaseFirestore.instance.collection('expenses').add(expenseData);
//     //
//     //   // Update balances collection based on the new expense
//     //   await _updateBalances(expenseData);
//     //
//     //   // Navigate back to previous screen
//     //   Navigator.pop(context);
//     // } catch (e) {
//     //   print('Error adding expense: $e');
//     //   // Handle error
//     // }
//   }
//
//   Future<void> _updateBalances(Map<String, dynamic> expenseData) async {
//     double totalAmount = expenseData['amount'];
//     List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(expenseData['participants']);
//     String paidByUserId = expenseData['paidByUserId'];
//
//     // Create a batch for Firestore writes
//     WriteBatch batch = FirebaseFirestore.instance.batch();
//
//     // Calculate the amount each participant owes/receives
//     participants.forEach((participant) {
//       String userId = participant['userId'];
//       double share = participant['share'];
//       double amount = totalAmount * share;
//
//       // Update balance of paidByUserId (negative for amount paid)
//       batch.set(
//         FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(paidByUserId).doc(userId),
//         {'amount': FieldValue.increment(-amount)},
//       );
//
//       // Update balance of participant (positive for amount owed)
//       batch.set(
//         FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(userId).doc(paidByUserId),
//         {'amount': FieldValue.increment(amount)},
//       );
//     });
//
//     // Commit the batch
//     await batch.commit();
//   }
// }


// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AddExpensePage extends StatefulWidget {
//   final String groupId;
//   final List<Map<String, dynamic>> groupMembers;
//
//   AddExpensePage({required this.groupId, required this.groupMembers});
//
//   @override
//   _AddExpensePageState createState() => _AddExpensePageState();
// }
//
// class _AddExpensePageState extends State<AddExpensePage> {
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   String _paidByUserId = '';
//   List<Map<String, dynamic>> _selectedParticipants = [];
//   List<double> _participantShares = [];
//   bool _splitEqually = false; // Add this state
//   Map<String, double> toGetMap = {};
//   @override
//   void initState() {
//     super.initState();
//     _paidByUserId = FirebaseAuth.instance.currentUser!.uid;
//     _participantShares = List<double>.filled(widget.groupMembers.length, 0.0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Expense'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Description'),
//             ),
//             TextFormField(
//               controller: _amountController,
//               decoration: InputDecoration(labelText: 'Amount'),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//             ),
//             DropdownButtonFormField<String>(
//               value: _paidByUserId,
//               items: widget.groupMembers.map((member) {
//                 return DropdownMenuItem<String>(
//                   value: member['id'],
//                   child: Text(member['name']),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _paidByUserId = value!;
//                 });
//               },
//               decoration: InputDecoration(labelText: 'Paid by'),
//             ),
//             SizedBox(height: 20),
//             Text('Select participants:'),
//             Wrap(
//               children: widget.groupMembers.map((member) {
//                 int index = widget.groupMembers.indexOf(member);
//                 return CheckboxListTile(
//                   title: Text(member['name']),
//                   value: _selectedParticipants.contains(member),
//                   onChanged: (bool? selected) {
//                     setState(() {
//                       if (selected!) {
//                         _selectedParticipants.add(member);
//                       } else {
//                         _selectedParticipants.remove(member);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             SwitchListTile(
//               title: Text('Split Equally'),
//               value: _splitEqually,
//               onChanged: (value) {
//                 setState(() {
//                   _splitEqually = value;
//                 });
//               },
//             ),
//             if (_selectedParticipants.isNotEmpty && !_splitEqually)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Enter shares (as decimal):'),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _selectedParticipants.length,
//                     itemBuilder: (context, index) {
//                       var participant = _selectedParticipants[index];
//                       return Row(
//                         children: [
//                           Expanded(
//                             child: Text(participant['name']),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             flex: 2,
//                             child: TextFormField(
//                               keyboardType: TextInputType.numberWithOptions(decimal: true),
//                               onChanged: (value) {
//                                 _participantShares[index] = double.tryParse(value) ?? 0.0;
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _addExpense();
//               },
//               child: Text('Add Expense'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addExpense() async {
//     String description = _descriptionController.text.trim();
//     double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
//
//     if (description.isEmpty || amount <= 0 || _paidByUserId.isEmpty || _selectedParticipants.isEmpty) {
//       return;
//     }
//
//     // Prepare expense data
//     List<Map<String, dynamic>> participantsData = _selectedParticipants.map((participant) {
//       int index = widget.groupMembers.indexOf(participant);
//       double share = _splitEqually ? 1.0 / _selectedParticipants.length : _participantShares[index];
//       return {
//         'userId': participant['id'],
//         'share': share,
//       };
//     }).toList();
//
//     Map<String, dynamic> expenseData = {
//       'groupId': widget.groupId,
//       'description': description,
//       'amount': amount,
//       'paidByUserId': _paidByUserId,
//       'participants': participantsData,
//       'createdAt': FieldValue.serverTimestamp(),
//     };
//     double individualShare = amount / _selectedParticipants.length;
//
//
//     // Set the values in the map
//     if(_splitEqually==true) {
//       for (var participant in _selectedParticipants) {
//         if (participant['id'] == _paidByUserId) {
//           toGetMap[participant['id']] = 0.0;
//         } else {
//           toGetMap[participant['id']] = individualShare;
//         }
//       }
//     }else{
//
//     }
//
//     print("$toGetMap to get map");
//
//     // Uncomment the following code to enable Firestore updates
//     // try {
//     //   // Update expenses collection
//     //   DocumentReference docRef = await FirebaseFirestore.instance.collection('expenses').add(expenseData);
//     //
//     //   // Update balances collection based on the new expense
//     //   await _updateBalances(expenseData);
//     //
//     //   // Navigate back to previous screen
//     //   Navigator.pop(context);
//     // } catch (e) {
//     //   print('Error adding expense: $e');
//     //   // Handle error
//     // }
//   }
//
//   Future<void> _updateBalances(Map<String, dynamic> expenseData) async {
//     double totalAmount = expenseData['amount'];
//     List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(expenseData['participants']);
//     String paidByUserId = expenseData['paidByUserId'];
//
//     // Create a batch for Firestore writes
//     WriteBatch batch = FirebaseFirestore.instance.batch();
//
//     // Calculate the amount each participant owes/receives
//     participants.forEach((participant) {
//       String userId = participant['userId'];
//       double share = participant['share'];
//       double amount = totalAmount * share;
//
//       // Update balance of paidByUserId (negative for amount paid)
//       batch.set(
//         FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(paidByUserId).doc(userId),
//         {'amount': FieldValue.increment(-amount)},
//       );
//
//       // Update balance of participant (positive for amount owed)
//       batch.set(
//         FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(userId).doc(paidByUserId),
//         {'amount': FieldValue.increment(amount)},
//       );
//     });
//
//     // Commit the batch
//     await batch.commit();
//   }
// }

import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpensePage extends StatefulWidget {
  final String groupId;
  final List<Map<String, dynamic>> groupMembers;

  AddExpensePage({required this.groupId, required this.groupMembers});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _paidByUserId = '';
  List<Map<String, dynamic>> _selectedParticipants = [];
  List<double> _participantShares = [];
  bool _splitEqually = false; // Add this state

  @override
  void initState() {
    super.initState();
    _paidByUserId = FirebaseAuth.instance.currentUser!.uid;
    _participantShares = List<double>.filled(widget.groupMembers.length, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            DropdownButtonFormField<String>(
              value: _paidByUserId,
              items: widget.groupMembers.map((member) {
                return DropdownMenuItem<String>(
                  value: member['id'],
                  child: Text(member['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paidByUserId = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Paid by'),
            ),
            SizedBox(height: 20),
            Text('Select participants:'),
            Wrap(
              children: widget.groupMembers.map((member) {
                int index = widget.groupMembers.indexOf(member);
                return CheckboxListTile(
                  title: Text(member['name']),
                  value: _selectedParticipants.contains(member),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected!) {
                        _selectedParticipants.add(member);
                      } else {
                        _selectedParticipants.remove(member);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Split Equally'),
              value: _splitEqually,
              onChanged: (value) {
                setState(() {
                  _splitEqually = value;
                });
              },
            ),
            if (_selectedParticipants.isNotEmpty && !_splitEqually)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter shares (as decimal):'),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedParticipants.length,
                    itemBuilder: (context, index) {
                      var participant = _selectedParticipants[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Text(participant['name']),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                _participantShares[index] = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addExpense();
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() async {
    String description = _descriptionController.text.trim();
    double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (description.isEmpty || amount <= 0 || _paidByUserId.isEmpty || _selectedParticipants.isEmpty) {
      return;
    }

    // Prepare expense data
    List<Map<String, dynamic>> participantsData = _selectedParticipants.map((participant) {
      int index = _selectedParticipants.indexOf(participant);
      double share = _splitEqually ? amount / _selectedParticipants.length : amount * _participantShares[index];
      return {
        'userId': participant['id'],
        'share': share,
      };
    }).toList();

    Map<String, dynamic> expenseData = {
      'groupId': widget.groupId,
      'description': description,
      'amount': amount,
      'paidByUserId': _paidByUserId,
      'participants': participantsData,
      'createdAt': FieldValue.serverTimestamp(),
    };

    Map<String, double> toGetMap = {};

    // Set the values in the map
    for (var participant in _selectedParticipants) {
      double individualShare = _splitEqually
          ? amount / _selectedParticipants.length
          : _participantShares[_selectedParticipants.indexOf(participant)];

      if (participant['id'] == _paidByUserId) {
        toGetMap[participant['id']] = 0.0;
      } else {
        toGetMap[participant['id']] = individualShare;
      }
    }
    print("$toGetMap to get map");

    // Uncomment the following code to enable Firestore updates
    // try {
    //   // Update expenses collection
    //   DocumentReference docRef = await FirebaseFirestore.instance.collection('expenses').add(expenseData);
    //
    //   // Update balances collection based on the new expense
    //   await _updateBalances(expenseData);
    //
    //   // Navigate back to previous screen
    //   Navigator.pop(context);
    // } catch (e) {
    //   print('Error adding expense: $e');
    //   // Handle error
    // }
  }

  Future<void> _updateBalances(Map<String, dynamic> expenseData) async {
    double totalAmount = expenseData['amount'];
    List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(expenseData['participants']);
    String paidByUserId = expenseData['paidByUserId'];

    // Create a batch for Firestore writes
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Calculate the amount each participant owes/receives
    participants.forEach((participant) {
      String userId = participant['userId'];
      double share = participant['share'];
      double amount = share;

      // Update balance of paidByUserId (negative for amount paid)
      batch.set(
        FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(paidByUserId).doc(userId),
        {'amount': FieldValue.increment(-amount)},
      );

      // Update balance of participant (positive for amount owed)
      batch.set(
        FirebaseFirestore.instance.collection('balances').doc(widget.groupId).collection(userId).doc(paidByUserId),
        {'amount': FieldValue.increment(amount)},
      );
    });

    // Commit the batch
    await batch.commit();
  }
}


