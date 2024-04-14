import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thc/home/stream/active_stream.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

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
                  DataColumn(label: Text('Action'))
                ],
                rows: userWidgets,
              ),
            );
          },
        ),
      ),
    );
  }
}
