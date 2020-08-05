import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/DataModels/Property.dart';
import 'package:project/Services/AuthManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/UI/Loading.dart';

enum Status { loading, loaded }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Auth auth;
  FirebaseUser user;
  var tenantProps;
  Status _status;
  // Initial logic starts
  @override
  void initState() {
    super.initState();
    auth = new Auth(context);
    this._status = Status.loading;
    this.tenantProps = new List<Property>();
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
    // Fetch Properties is a listener Call it after getting user
    fetchProperties();
  }

  fetchProperties() {
    try {
      Firestore.instance
          .collection("/properties")
          .snapshots()
          .listen((QuerySnapshot querySnapshot) {
        print(querySnapshot.documents);
        //Clearing Array whenever it listens
        this.tenantProps.clear();
        for (var item in querySnapshot.documents) {
          DocumentSnapshot documentSnapshot = item;
          List<dynamic> properties = documentSnapshot?.data["myProperties"];
          for (var x in properties) {
            if (x["tenant"] == this.user?.email) {
              setState(() {
                tenantProps.add(Property.fromJson(x));
              });
            }
          }
          setState(() {
            this._status = Status.loaded;
          });
          print(tenantProps.length);
        }
      });
    } catch (e) {
      print(e);
    }
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
                      child: (this.user != null && this.user.photoUrl != null)
                          ? Image.network(this.user.photoUrl)
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 2, color: Colors.green)),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            )),
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
        body: this._status == Status.loading
            ? Loading()
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(height: 1),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: this.tenantProps.length,
                        itemBuilder: (context, index) {
                          return (GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed("/propertyDetails", arguments: {
                                "property": this.tenantProps[index]
                              });
                            },
                            child: ListTile(
                                title:
                                    Text(this.tenantProps[index].propertyName)),
                          ));
                        }))));
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
