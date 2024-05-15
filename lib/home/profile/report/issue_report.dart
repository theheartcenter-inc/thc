import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/style_text.dart';

class IssueReport extends StatefulWidget {
  const IssueReport({super.key});

  @override
  State<IssueReport> createState() => _IssueReportState();
}

class _IssueReportState extends State<IssueReport> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _message = '';

  @override
  Widget build(BuildContext context) {
    final colors = ThcColors.of(context);

    final style = MaterialStateTextStyle.resolveWith((states) => StyleText(
          color: colors.onBackground.withOpacity(states.isFocused ? 1.0 : 0.5),
        ));
    final border = MaterialStateOutlineInputBorder.resolveWith(
      (states) => OutlineInputBorder(
        borderSide: states.isFocused
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide(color: colors.onBackground.withOpacity(0.5)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'name',
                    labelStyle: style,
                    floatingLabelStyle: style,
                    border: border,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value ?? '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'email',
                    labelStyle: style,
                    floatingLabelStyle: style,
                    border: border,
                  ),
                  validator: (value) => switch (value) {
                    final email? when EmailValidator.validate(email) => null,
                    _ => 'Please enter a valid email address',
                  },
                  onSaved: (value) => _email = value ?? '',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'message',
                  labelStyle: style,
                  floatingLabelStyle: style,
                  border: border,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onSaved: (value) => _message = value ?? '',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    backendPrint('$_name $_email $_message');
                  }
                },
                child: const Text('Submit', style: StyleText(weight: 520)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
