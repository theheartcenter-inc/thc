import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(onPressed: (){
              //handle logout press
            }, icon: const Icon(Icons.logout))
          ],
          backgroundColor: const Color.fromARGB(255, 131, 124, 234),
        ),
        body: const Center(child: Text("Implementation of body content")),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: "About Us", icon: Icon(Icons.info))
          ],
        ),
      ),
    );
  }
}
