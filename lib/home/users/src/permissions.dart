import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/dialogs.dart';

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
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
