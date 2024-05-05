import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HeartCenterInfo extends StatefulWidget {
  const HeartCenterInfo({super.key});
  
  @override
  _HeartCenterInfoState createState() => _HeartCenterInfoState();
}

class _HeartCenterInfoState extends State<HeartCenterInfo> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  int _selectedIndex = 0;

  // Function to launch the specified URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to submit form data to server API
  Future<void> _submitForm(String email, String message) async {
    const String apiUrl = 'server API URL';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: '{"email": "$email", "message": "$message"}',
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Please try again.')),
      );
    }
  }

  List<Widget> _getPages() {
    return [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The Heart Center',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Our intention is to provide individuals impacted by mass incarceration with access to various healing modalities, events & retreats. We do this with programming, donors and corporate sponsors that align with our values.',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _launchURL("https://secure.givelively.org/donate/heart-center-inc");
                },
                child: const Text('Donate'),
              ),
            ),
          ],
        ),
      ),
      const Center(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Our Intention',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Lokah Samastah Sukhino Bhavantu is the underlying core principle at The Heart Center. Translated, it means May all beings everywhere be happy, joyous, and free. Toward that, we value love, healthy communication, and definitive boundaries.',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'To support others along their journeys toward this light, we provide Mindfulness Wellness programming. Our services include yoga, sound healing, and guided meditation. We work with students, faculty, and staff at schools, universities, and other places of business. We believe safe spaces to experience release through movement, community, and emotional expression are critical to living a joyous, happy life. Those who participate in our workshops often report a better understanding of the connection between mental, physical, and emotional well-being. ',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "With the funding we receive from our regularly scheduled programs, in addition to monetary donations and other financial support, we held The Heart Center's first holistic retreat, You are the Master of You at no cost to individuals impacted by incarceration which included transportation, 1 bedroom stay near the lake, 90 minute massage, yoga and meditation classes, nourishing food, understanding the nervous system training, and more.",
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Now that our participants have embarked on a life-changing journey this has ignited the creation of The Heart Center's exclusive 6-month Wellness \nProgram: The Art of Nurturing Your Nervous System. Our 6 month Wellness Program includes the You are the Master of You multi-day holistic retreat, 1on1 coaching sessions, and live guided meditations.",
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'At The Heart Center, we feel that the wellness of one is the wellness of all. Support our next 6 month wellness program: the art of nurturing your nervous system.',
                textAlign: TextAlign.center,
              ),
            ),
            ],
          ),
        ),
      ),
      Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The Heart Center Inc',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Your Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _messageController,
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
                        if (_formKey.currentState!.validate()) {
                          _submitForm(
                            _emailController.text,
                            _messageController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form submitted successfully!')),
                          );
                          _emailController.clear();
                          _messageController.clear();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Email: info@theheartcenter.one\nLocation: 1701 South Figueroa #1437 Los Angeles, CA 90015',
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () => _launchURL('https://theheartcenter.one/'),
              child: const Text(
                'Visit Our Website',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              )
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _launchURL('https://secure.givelively.org/donate/heart-center-inc'),
              child: const Text('Donate'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _launchURL('https://docs.google.com/forms/d/e/1FAIpQLScOEwS0sew6teRQoov6h1kzLt0xOAw0hk-bmKM14FZ28YAqDA/viewform'),
              child: const Text('Volunteer'),
            ),
          ],
        ),
      ),
    ];
  }

  // Handle changes in the selected bottom navigation item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPages()[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'THC',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
      ),
    );
  }
}
