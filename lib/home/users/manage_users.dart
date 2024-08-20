import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/home/users/src/permissions.dart';
import 'package:thc/the_good_stuff.dart';

class ManageUsers extends HookWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final search = useState('');
    final users = ThcUsers.of(context, filter: search.value);

    if (users.isEmpty) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: search.update,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search by ID, Email, Name',
                prefixIcon: Icon(Icons.search, size: 20),
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
