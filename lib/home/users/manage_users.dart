import 'package:flutter/material.dart';
import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/home/users/src/permissions.dart';
import 'package:thc/utils/navigator.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final users = ThcUsers.of(context);

    return LayoutBuilder(
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
    );
  }
}
