import 'package:flutter/material.dart';
import 'package:theeye/Screens/home.dart';

void main() => runApp(Eye());



class Eye extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "The Eye",
      home: Home(),
    );
  }

}
