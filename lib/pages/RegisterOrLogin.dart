import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterOrLogin extends StatefulWidget {
  @override
  _RegisterOrLoginState createState() => _RegisterOrLoginState();
}

class _RegisterOrLoginState extends State<RegisterOrLogin> {
  bool loginOrRegisterProgress;

  TextEditingController emailController;
  TextEditingController passwordController;
  FirebaseAuth auth;
  FirebaseUser user;

  Future<void> initUser() async {
    var myUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = myUser;
    });
  }

  Future<void> _signUp(BuildContext context) async {
    setState(() {
      loginOrRegisterProgress = true;
    });
    FirebaseUser newUser = (await auth.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text))
        .user;

    //showGeneralDialog(context: context, pageBuilder: (BuildContext context, Animation anim1, Animation anim2) => Text("data"));
    await Firestore.instance
        .collection("users")
        .document(newUser.uid)
        .setData({"user-email": newUser.email});
    setState(() {
      user = newUser;
      loginOrRegisterProgress = false;
    });
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(user.email)));
    if (!user.isEmailVerified) {
      user.sendEmailVerification();
    }
    _clearTextFields();
    print("Register done");
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      loginOrRegisterProgress = true;
    });
//    FirebaseUser newUser = (await auth.signInWithEmailAndPassword(
//        email: emailController.text, password: passwordController.text)).user;
    auth
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((AuthResult value) {
      setState(() {
        user = value.user;
      });
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Current User"),
            content: Text(user.email),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  await auth.signOut();
                  Navigator.pop(context);
                  auth.currentUser().then((value) {
                    setState(() {
                      user = value;
                    });
                  });
                },
                child: Text("Sign out"),
              )
            ],
          ));
    }).catchError((error) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in error: $error"),
        ),
      );
    });
    _clearTextFields();
    print("Login done");
  }

  void _clearTextFields() {
    emailController.text = "";
    passwordController.text = "";
  }

  @override
  void initState() {
    loginOrRegisterProgress = false;
    emailController = TextEditingController(text: "");
    passwordController = TextEditingController(text: "");
    auth = FirebaseAuth.instance;
    initUser();
    super.initState();
  }

  Future<void> _checkLogin(BuildContext context) async {
    if (await FirebaseAuth.instance.currentUser() != null) {
      print("${user.email}");
      Navigator.pop(context);
      Navigator.of(context).pushNamed(
        "/home",
        arguments: <String, dynamic>{
          "firebase-user": user,
        },
      );
    } else {
      print("No user");
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLogin(context);

    return Scaffold(body: Builder(builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 8.0),
        child: Center(
          child: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Text(
                    "Facebook",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    children: <Widget>[
                      Text(
                        "Connect with friends and stay safe",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(20.0)),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Email Address"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Text(
                    "By signing up, you have accepted the Terms and Conditions of this service",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text(
                              "Sign in",
                              style: TextStyle(fontSize: 20.0),
                            ),
                            padding: EdgeInsets.all(20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                            onPressed: () {
                              _login(context);
                            }),
                      ),
                      Padding(padding: EdgeInsets.all(16.0)),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                            color: Color(0xFF131F38),
                            textColor: Colors.white,
                            child: Text(
                              "Register",
                              style: TextStyle(fontSize: 20.0),
                            ),
                            padding: EdgeInsets.all(20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                            onPressed: () {
                              _signUp(context);
                            }),
                      ),
                    ],
                  ),
                ],
              ),
              loginOrRegisterProgress
                  ? Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 15.0,
                        ),
                        height: 100.0,
                        width: 100.0,
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      );
    }));
  }
}
