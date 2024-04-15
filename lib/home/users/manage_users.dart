import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final horizontalScroll = ScrollController();

  @override
  void dispose() {
    super.dispose();
    horizontalScroll.dispose();
  }

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
        child: Scrollbar(
          controller: horizontalScroll,
          thumbVisibility: mobileDevice ? null : true,
          child: SingleChildScrollView(
            controller: horizontalScroll,
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
      ),
    );
  }
}
