import 'package:fb_clone/pages/AddPost.dart';
import 'package:fb_clone/pages/Home.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/HP/IdeaProjects/fb_clone/lib/pages/RegisterOrLogin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Clone',
      home: RegisterOrLogin(),
      routes: {
        "/home": (BuildContext context) => Home(),
        "/add-post": (BuildContext context) => AddPost(),
        "/login-register": (BuildContext context) => RegisterOrLogin(),

      },
    );
  }
}

