import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addexpense.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupPage({required this.groupId, required this.groupName});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, String> userNames = {};
  List<Map<String, dynamic>> groupMembers = [];
  Map<String, double> balances = {};
  List<String> balanceDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchUserNamesAndCalculateBalances();
  }

  Future<void> _fetchUserNamesAndCalculateBalances() async {
    // Fetch all users to map user IDs to user names
    var userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    userSnapshot.docs.forEach((doc) {
      userNames[doc.id] = doc['name'];
    });

    // Fetch group members
    var groupSnapshot = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    List<String> memberIds = List<String>.from(groupSnapshot['members']);

    groupMembers = memberIds.map((id) => {'id': id, 'name': userNames[id] ?? 'Unknown'}).toList();
    print("$groupMembers member id");

    // Initialize balances for each member
    memberIds.forEach((id) {
      balances[id] = 0.0;
      print(balances);
    });

    // Fetch all expenses for the group
    var expensesSnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('groupId', isEqualTo: widget.groupId)
        .get();

    // Calculate balances
    expensesSnapshot.docs.forEach((expenseDoc) {
      var expense = expenseDoc.data();
      var amount = expense['amount'];
      var paidByUserId = expense['paidByUserId'];
      List<dynamic> participants = expense['participants'];
      print("$expense expense");

      double perPersonAmount = amount / participants.length;

      participants.forEach((participant) {
        var userId = participant['userId'];
        double paidByUserIdParticipant = participant['paidByUserId'] ?? 0.0;
        double owedByParticipant = perPersonAmount - paidByUserIdParticipant;

        if (userId != paidByUserId) {
          balances[userId] = (balances[userId] ?? 0) - owedByParticipant;
        }

        balances[paidByUserId] = (balances[paidByUserId] ?? 0) + paidByUserIdParticipant;
      });
    });

    // Generate balance details
    balanceDetails = _generateBalanceDetails();
    setState(() {}); // Update UI after fetching data
  }

  List<String> _generateBalanceDetails() {
    List<String> details = [];

    balances.forEach((userId, balance) {
      if (balance != 0) {
        String userName = userNames[userId] ?? 'Unknown';
        String formattedBalance = balance > 0 ? 'gets \$${balance.toStringAsFixed(2)}' : 'owes \$${(-balance).toStringAsFixed(2)}';

        // Find out who the balance is owed to or gets from
        List<String> transactions = [];
        balances.forEach((otherUserId, otherBalance) {
          if (userId != otherUserId) {
            if (balance > 0 && otherBalance < 0) {
              transactions.add('$userName gets \$${(-otherBalance).toStringAsFixed(2)} from ${userNames[otherUserId] ?? 'Unknown'}');
            } else if (balance < 0 && otherBalance > 0) {
              transactions.add('$userName owes \$${otherBalance.toStringAsFixed(2)} to ${userNames[otherUserId] ?? 'Unknown'}');
            }
          }
        });

        // Append details for this user
        details.addAll(transactions);
      }
    });

    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('groupId', isEqualTo: widget.groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No expenses found.'));
                }

                final expenses = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];
                    String paidByUserIdName = userNames[expense['paidByUserId']] ?? 'Unknown';

                    return Card(
                      child: ListTile(
                        title: Text(expense['description']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: ${expense['amount']}'),
                            Text('Paid by: $paidByUserIdName'),
                            Text('Participants: ${expense['participants'].map((participant) => userNames[participant['userId']] ?? 'Unknown').join(', ')}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Balances',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: balanceDetails.length,
              itemBuilder: (context, index) {
                String balanceDetail = balanceDetails[index];
                return ListTile(
                  title: Text(balanceDetail),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage(
                groupId: widget.groupId,
                groupMembers: groupMembers,
              ),
            ),
          );
        },
      ),
    );
  }
}
