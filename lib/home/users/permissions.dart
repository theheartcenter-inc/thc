import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/utils/theme.dart';

class Permissions extends StatelessWidget {
  const Permissions({Key? key, required this.user}) : super(key: key);
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user['name'])),
      body: RadioGroup(user: user),
    );
  }
}

class RadioGroup extends StatefulWidget {
  const RadioGroup({Key? key, required this.user}) : super(key: key);
  final Map<String, dynamic> user;

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  late String _selectedRadio;

  @override
  void initState() {
    super.initState();
    _selectedRadio = widget.user['type'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Text(
            'User Permissions',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buildRadioListTile('Participant', 'Participants can do 123'),
        buildRadioListTile('Admin', 'Admin can do 456'),
        buildRadioListTile('Director', 'Directors can do 789'),
      ],
    );
  }

  RadioListTile<String> buildRadioListTile(String title, String subtitle) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: ThcColors.gray),
      ),
      value: title,
      groupValue: _selectedRadio,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedRadio = newValue;
            updatePermissions(widget.user['id'], newValue);
          });
        }
      },
    );
  }

  Future<void> updatePermissions(String userId, String newName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'type': newName});
    } catch (e) {
      print('Error updating permissions: $e');
    }
  }
}