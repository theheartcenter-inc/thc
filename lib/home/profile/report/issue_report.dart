import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/theme.dart';

class IssueReport extends HookWidget {
  const IssueReport({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useFormKey();
    final name = useRef('');
    final email = useRef('');
    final message = useRef('');

    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(isDense: true, labelText: 'name'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: name.update,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(isDense: true, labelText: 'email'),
                  validator: (value) => switch (value) {
                    final email? when EmailValidator.validate(email) => null,
                    _ => 'Please enter a valid email address',
                  },
                  onSaved: email.update,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(isDense: true, labelText: 'message'),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onSaved: message.update,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (formKey.validate()) formKey.save();
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
