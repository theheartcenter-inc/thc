import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final List<DataRow> userWidgets = [];
            if (snapshot.hasData) {
              final users = snapshot.data?.docs.reversed.toList();
              for (var user in users!) {
                final userWidget = DataRow(selected: true, cells: [
                  DataCell(Text(user['id'])),
                  DataCell(Text(user['name'])),
                  DataCell(Text(user['type'])),
                  const DataCell(Text(''), placeholder: true),
                ]);
                userWidgets.add(userWidget);
              }
            }
            return Expanded(
              child: Scrollbar(
                child: ListView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          // headingTextStyle: const TextStyle(
                          //   fontSize: 14,
                          // ),
                          // dataTextStyle: const TextStyle(
                          //   fontSize: 12,
                          // ),
                          sortColumnIndex: 0,
                          columns: const [
                            DataColumn(label: Text('Id')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Actions'))
                          ],
                          rows: userWidgets,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
