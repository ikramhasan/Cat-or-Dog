import 'package:cat_or_dog/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat or Dog',
      theme: ThemeData(
        canvasColor: Color(0xFFEBE5E1),
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
