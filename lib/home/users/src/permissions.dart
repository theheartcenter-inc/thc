import 'package:thc/the_good_stuff.dart';

class Permissions extends HookWidget {
  const Permissions(this.user, {super.key});
  final ThcUser user;

  @override
  Widget build(BuildContext context) {
    final selection = useState(user.type);

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'User Permissions',
              style: TextStyle(size: 16.0, weight: 700),
            ),
          ),
          for (final userType in UserType.values)
            RadioListTile<UserType>(
              title: Text('$userType'),
              subtitle: Text(
                switch (userType) {
                  UserType.participant => 'Participants can do 123',
                  UserType.director => 'Directors can do 456',
                  UserType.admin => 'Admin can do 789',
                },
                style: const TextStyle(color: ThcColors.gray),
              ),
              value: userType,
              groupValue: selection.value,
              onChanged: (newValue) {
                selection.value = newValue!;
                updatePermissions(user.id ?? user.email!, newValue);
              },
            ),
        ],
      ),
    );
  }

  Future<void> updatePermissions(String userId, UserType newType) async {
    try {
      await Firestore.users.doc(userId).update({'type': '$newType'});
    } catch (e) {
      navigator.showDialog(ErrorDialog('Error updating permissions: $e'));
    }
  }
}
