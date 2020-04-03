import 'package:flutter/material.dart';
import 'package:mtracking/screens/authen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'M-Tracking',
      theme: ThemeData(primarySwatch: Colors.red),
      home: Authen(),
    );
  }
}
