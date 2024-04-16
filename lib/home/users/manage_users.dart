import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final dataTable = StreamBuilder<QuerySnapshot>(
      stream: db.collection('users').snapshots(),
      builder: (context, snapshot) => DataTable(
        sortColumnIndex: 0,
        columns: const [
          DataColumn(label: Text('Id')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Actions'))
        ],
        rows: [
          if (snapshot.data?.docs.reversed case final users?)
            for (final user in users)
              DataRow(cells: [
                DataCell(Text(user['id'])),
                DataCell(Text(user['name'])),
                DataCell(Text(user['type'])),
                const DataCell(Text(''), placeholder: true),
              ]),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: dataTable,
            ),
          ),
        ),
      ),
    );
  }
}
