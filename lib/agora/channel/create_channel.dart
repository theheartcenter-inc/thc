import 'package:thc/firebase/firebase_auth.dart' as auth;
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/the_good_stuff.dart';
import 'pre_joining_dialog.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final _formKey = FormKey();

  final _unfocusNode = FocusNode();
  final _channelNameController = TextEditingController();

  bool _isCreatingChannel = false;

  @override
  void dispose() {
    _unfocusNode.dispose();
    _channelNameController.dispose();
    super.dispose();
  }

  String? _channelNameValidator(String? value) => switch (value) {
        null || '' => 'Please enter a channel name',
        String(length: > 64) => 'Channel name must be less than 64 characters',
        _ => null,
      };

  Future<void> _joinRoom() async {
    if (!_formKey.validate()) {
      return;
    }
    FocusScope.of(context).requestFocus(_unfocusNode);
    setState(() => _isCreatingChannel = true);
    try {
      final response = await auth.generateToken(<String, dynamic>{
        'channelName': _channelNameController.text,
        'expiryTime': 3600, // 1 hour
      });
      if (response.data case final token?) {
        navigator.snackbarMessage('Token generated successfully!');
        await Future.delayed(const Duration(seconds: 1));
        await navigator.showDialog(
          PreJoiningDialog(
            channelName: _channelNameController.text,
            token: token,
          ),
        );
      }
    } catch (e) {
      navigator.snackbarMessage('Error generating token: $e');
    }
    setState(() => _isCreatingChannel = false);
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 8.0),
          child: Text(
            'Select or Create Channel',
            style: TextStyle(size: 32.0, weight: 500),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 24.0),
          child: Column(
            children: [
              for (final scheduledStream in ScheduledStreams.of(context).scheduled)
                if (scheduledStream.director == 'Liz Lemon')
                  GestureDetector(
                    child: scheduledStream,
                    onTap: () => _channelNameController.text = scheduledStream.title,
                  ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(bottom: 24.0),
          child: Text(
            'Enter a channel name to generate token. The token will be valid for 1 hour.',
            style: TextStyle(color: Colors.grey, size: 16.0),
          ),
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            controller: _channelNameController,
            decoration: InputDecoration(
              labelText: 'Channel Name',
              labelStyle: const TextStyle(color: Colors.blue, size: 16.0),
              hintText: 'Enter your channel name...',
              hintStyle: const TextStyle(color: Color(0xFF57636C), size: 16.0),
              border: MaterialStateOutlineInputBorder.resolveWith(
                (states) => OutlineInputBorder(
                  borderSide: BorderSide(
                    color: states.isError ? Colors.red : Colors.blue,
                    width: states.isFocused ? 2.0 : 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
            style: const TextStyle(color: Colors.black, size: 16.0),
            keyboardType: TextInputType.text,
            validator: _channelNameValidator,
          ),
        ),
        const SizedBox(height: 24.0),
        if (_isCreatingChannel)
          const Center(heightFactor: 1.0, child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _joinRoom,
              child: const Text('Join Room'),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: _unfocusNode.requestFocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
        body: Center(
          heightFactor: 1.0,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: 600,
              child: SingleChildScrollView(child: mainContent),
            ),
          ),
        ),
      ),
    );
  }
}
