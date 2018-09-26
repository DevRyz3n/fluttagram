import 'package:flutter/material.dart';
import 'package:fluttagram/fg_home.dart';



// void main() => runApp(new FgMain());

class FgMain extends StatelessWidget {


  String name;
  FgMain({Key key, @required this.name}) : super(key: key);



  static String staticName;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    staticName = name;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
          primaryIconTheme: IconThemeData(color: Colors.black),
          primaryTextTheme: TextTheme(
              title:
              TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 30.0)),
          textTheme: TextTheme(title: TextStyle(color: Colors.black))),
      home: new FgHome(),
    );
  }
}