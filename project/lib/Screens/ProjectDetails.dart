import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:project/DataModels/Property.dart';
import 'package:project/Services/AuthManagement.dart';

class PropertyDetails extends StatefulWidget {
  final LinkedHashMap args;
  const PropertyDetails(this.args);
  @override
  _PropertyDetailsState createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  Property property;
  FirebaseUser user;
  Auth auth;
  @override
  void initState() {
    super.initState();
    if (widget.args != null) {
      this.property = widget.args["property"];
    }
    auth = new Auth(context);
    getUser();
  }

  getUser() async {
    await auth.getUser().then((value) => setState(() {
          this.user = value;
        }));
    // Listen to Doc changes
    docLis();
  }

  withDrawLease(String id) async {
    try {
      bool breakLoop = false;
      var docs =
          await Firestore.instance.collection("/properties").getDocuments();
      for (var item in docs.documents) {
        DocumentSnapshot documentSnapshot = item;
        print(documentSnapshot.documentID);
        List<dynamic> properties = documentSnapshot?.data["myProperties"];
        for (var x in properties) {
          if (x["tenant"] == this.user?.email && x["id"] == id) {
            x["tenant"] = null;
            await Firestore.instance
                .collection("/properties")
                .document(documentSnapshot.documentID)
                .setData({"myProperties": properties});
            breakLoop = true;
            break;
          }
        }
        if (breakLoop) break;
      }
    } catch (e) {
      print(e);
    }
  }

  docLis() {
    Firestore.instance
        .collection('/properties')
        .document("anuraghsai3@gmail.com")
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      print("Lis");
      print(documentSnapshot.data);
    }).onError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.property.propertyName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          this.property.url != null
              ? Image.network(this.property.url)
              : Text("No Preview Image"),
          Text("Address: " + this.property.address),
          Text("Cost: " + this.property.cost),
          Text("Area: " + this.property.area),
          RaisedButton(
            onPressed: () {
              withDrawLease(this.property.id);
            },
            child: Text("Withdraw Property Lease"),
          )
        ],
      ),
    );
  }
}
