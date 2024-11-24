import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pdfreader/HomePage.dart';

import 'package:pdfreader/HomePage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'First Screen',
      theme: ThemeData(
        primarySwatch: Colors.red
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay for the splash screen
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network("data:image/png;base64,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")
            ,SizedBox(height: 20),
            Text(
              'PDF Reader',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

