import 'package:flutter/material.dart';
import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/home/users/src/permissions.dart';
import 'package:thc/utils/navigator.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  String searchValue = '';

  @override
  Widget build(BuildContext context) {
    final users = ThcUsers.of(context).where((user) {
      return (user.firestoreId.toLowerCase().contains(searchValue.toLowerCase()) ?? false) ||
          user.name.toLowerCase().contains(searchValue.toLowerCase()) ||
          (user.email?.toLowerCase().contains(searchValue.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchValue = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search by ID, Email, Name',
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                prefixIcon: Icon(Icons.search, size: 18.0, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DataTable(
                        sortColumnIndex: 0,
                        columns: const [
                          DataColumn(label: Text('Id')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: [
                          for (final user in users)
                            DataRow(cells: [
                              DataCell(Text(user.firestoreId)),
                              DataCell(Text(user.name)),
                              DataCell(Text(user.type.toString())),
                              DataCell(IconButton.filled(
                                icon: const Icon(Icons.edit),
                                onPressed: () => navigator.push(Permissions(user)),
                              )),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
