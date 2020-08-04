import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project/Services/AuthManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/UI/Loading.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Auth auth;
  String email;
  FirebaseUser user;
  // Initial logic starts
  @override
  void initState() {
    super.initState();
    auth = new Auth(context);
    getUser();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUser() async {
    await auth.getUser().then((value) => setState(() {
          this.user = value;
        }));
  }

  // Initial logic ends

  // UI code starts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          leading: Icon(Icons.home),
          actions: <Widget>[
            Container(
              width: 60.0,
              child: PopupMenuButton<String>(
                icon: ClipOval(
                  child: Align(
                    heightFactor: 1,
                    widthFactor: 1,
                    child: Image.network((this.user != null &&
                            this.user.photoUrl != null)
                        ? this.user.photoUrl
                        : "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png"),
                  ),
                ),
                onSelected: (choice) => choiceAction(choice, context),
                itemBuilder: (BuildContext context) {
                  return ['Sign-Out'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title:
                              Text(choice, style: (TextStyle(fontSize: 15)))),
                    );
                  }).toList();
                },
              ),
            )
          ],
        ),

        // Wait for required data to be initialized. For that, using FutureBuilder. Same pattern is used in several other pages
        body: Text("Welcome User"));
  }

  void choiceAction(String choice, BuildContext context) async {
    if (choice == "Sign-Out") {
      if (user.providerData[1].providerId == "password") {
        await auth.signOut();
      } else {
        await auth.signOutGoogle();
      }
    }
  }
}
