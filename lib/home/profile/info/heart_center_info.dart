import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:thc/the_good_stuff.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HeartCenterInfo extends HookWidget {
  const HeartCenterInfo({super.key});

  static void donate() =>
      launchUrlString('https://secure.givelively.org/donate/heart-center-inc');

  static Future<void> _submitForm(String email, String message) async {
    const String apiUrl = 'server API URL';

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: '{"email": "$email", "message": "$message"}',
    );

    navigator.snackbarMessage(switch (response.statusCode) {
      200 => 'Form submitted successfully!',
      _ => 'Submission failed. Please try again.',
    });
  }

  static const aboutUs = '''\
Lokah Samastah Sukhino Bhavantu is the underlying core principle at The Heart Center. 
Translated, it means May all beings everywhere be happy, joyous, and free. 
Toward that, we value love, healthy communication, and definitive boundaries.

To support others along their journeys toward this light, we provide 
Mindfulness Wellness programming. Our services include yoga, sound healing, 
and guided meditation. We work with students, faculty, and staff 
at schools, universities, and other places of business. 
We believe safe spaces to experience release through movement, community, 
and emotional expression are critical to living a joyous, happy life. 
Those who participate in our workshops often report a better understanding of 
the connection between mental, physical, and emotional well-being.

With the funding we receive from our regularly scheduled programs, 
in addition to monetary donations and other financial support, 
we held The Heart Center's first holistic retreat, You are the Master of You 
at no cost to individuals impacted by incarceration which included transportation, 
1 bedroom stay near the lake, 90 minute massage, yoga and meditation classes, 
nourishing food, understanding the nervous system training, and more.

Now that our participants have embarked on a life-changing journey this has ignited 
the creation of The Heart Center's exclusive 6-month Wellness Program: 
The Art of Nurturing Your Nervous System. Our 6 month Wellness Program 
includes the You are the Master of You multi-day holistic retreat, 
1on1 coaching sessions, and live guided meditations.

At The Heart Center, we feel that the wellness of one is the wellness of all. 
Support our next 6 month wellness program: the art of nurturing your nervous system.
''';

  @override
  Widget build(BuildContext context) {
    final formKey = useFormKey();
    final emailController = useTextEditingController();
    final messageController = useTextEditingController();
    final index = useState(0);

    final List<Widget> contents = switch (index.value) {
      0 => const [
          Text('The Heart Center', style: TextStyle(size: 24, weight: 650)),
          SizedBox(height: 16),
          Text(
            'Our intention is to provide individuals impacted by mass incarceration with '
            'access to various healing modalities, events & retreats. We do this with '
            'programming, donors and corporate sponsors that align with our values.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: HeartCenterInfo.donate,
            child: Text('Donate'),
          ),
        ],
      1 => [
          const Text('Our Intention', style: TextStyle(size: 24, weight: 650)),
          const SizedBox(height: 16),
          Text(aboutUs.replaceAll(' \n', ' '), textAlign: TextAlign.center),
        ],
      2 || _ => [
          const Text(
            'The Heart Center Inc',
            style: TextStyle(size: 24, weight: 650),
          ),
          const SizedBox(height: 16),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Your Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Your Message'),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.validate()) {
                      _submitForm(emailController.text, messageController.text);

                      emailController.clear();
                      messageController.clear();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SelectableText(
            'Email: info@theheartcenter.one\n'
            'Location: 1701 South Figueroa #1437 Los Angeles, CA 90015',
            textAlign: TextAlign.center,
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            onPressed: () => launchUrlString('https://theheartcenter.one/'),
            child: const Text(
              'Visit Our Website',
              style: TextStyle(
                size: 16,
                weight: 500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          const ElevatedButton(
            onPressed: HeartCenterInfo.donate,
            child: Text('Donate'),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () => launchUrlString(
              'https://docs.google.com/forms/d/e/1FAIpQLScOEwS0sew6teRQoov6h1kzLt0xOAw0hk-bmKM14FZ28YAqDA/viewform',
            ),
            child: const Text('Volunteer'),
          ),
        ],
    };

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: contents),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.favorite), label: 'THC'),
          NavigationDestination(icon: Icon(Icons.info), label: 'About Us'),
          NavigationDestination(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
        selectedIndex: index.value,
        onDestinationSelected: index.update,
      ),
    );
  }
}
