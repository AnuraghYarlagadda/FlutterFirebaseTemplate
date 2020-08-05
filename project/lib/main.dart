import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project/Authentication/LoginPage.dart';
import 'package:project/Authentication/SignUp.dart';
import 'package:project/Home/HomePage.dart';
import 'package:project/UI/Loading.dart';
import 'Screens/ProjectDetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: "Project",
          home: LandingPage(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/signup': (context) => SignUp(),
            '/landingpage': (context) => LandingPage(),
            '/homepage': (context) => HomePage(),
            "/propertyDetails": (context) =>
                PropertyDetails(ModalRoute.of(context).settings.arguments)
          },
        ));
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return LoginPage();
          }
          print(user.providerData[1].providerId);
          if (user.isEmailVerified)
            return HomePage();
          else
            return LoginPage();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: Loading()),
          );
        } else
          return null;
      },
    );
  }
}
