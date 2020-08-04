import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:project/Services/AuthExceptionHandler.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  AuthResultStatus _status;
  BuildContext context;
  Auth(context) {
    this.context = context;
  }
  Future<void> signUp(String name, String email, String password) async {
    FirebaseUser user;
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Creating account');
    pr.show();

    //Sign up -> Add user data to *users* collection ->  Send Email verification -> return user id
    try {
      user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      await Firestore.instance
          .collection('/users')
          .add({'name': name, 'email': email});
      print(user);
      await user.sendEmailVerification();
      pr.hide();
      Fluttertoast.showToast(
          msg: 'Account created successfully, Please verify your email',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      await signOut();
    } catch (e) {
      pr.hide();
      print('Exception @createAccount: $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  Future<void> signIn(email, pass) async {
    ProgressDialog pr = new ProgressDialog(context);
    try {
      // Start showing progress indicator
      pr.style(message: 'Just a moment');
      pr.show();
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: pass);

      FirebaseUser user = await getUser();
      pr.hide();
      print(user.isEmailVerified);
      if (user.isEmailVerified) {
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        Fluttertoast.showToast(
            msg: "Email not verified",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (e) {
      pr.hide();
      print('Exception : $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  // Google SignIn
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await _firebaseAuth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _firebaseAuth.currentUser();

      dynamic res = await Firestore.instance
          .collection("/users")
          .where("email", isEqualTo: currentUser.email)
          .getDocuments();
      // If not present in Collection add user
      if (res.documents.length == 0) {
        await Firestore.instance
            .collection('/users')
            .add({'name': currentUser.displayName, 'email': currentUser.email});
      }
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pushNamedAndRemoveUntil('/homepage', (v) => false);
    } catch (e) {
      print('Exception : $e');
    }
  }

  // Returns current user of type FirebaseUser
  Future<FirebaseUser> getUser() async {
    try {
      FirebaseUser user = await _firebaseAuth.currentUser();
      return user;
    } catch (e) {
      print('Exception : $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  // Return user email
  Future<String> getUserEmail() async {
    try {
      FirebaseUser user = await _firebaseAuth.currentUser();
      return user.email;
    } catch (e) {
      print('Exception : $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  Future<void> signOut() async {
    // Signout -> navigate to landing page
    try {
      await FirebaseAuth.instance.signOut().then((value) {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/landingpage', (v) => false);
      });
    } catch (e) {
      print('Exception: $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut().then((onValue) {
        print(onValue);
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/landingpage', (v) => false);
      });
    } catch (e) {
      print('Exception : $e');
    }
  }

  resetPassword(email) async {
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Sending password reset email');
    pr.show();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      pr.hide();

      Fluttertoast.showToast(
          msg: 'Email sent!',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    } catch (e) {
      pr.hide();
      print('Exception @createAccount: $e');
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  verifyEmail() async {
    try {
      FirebaseUser user = await getUser();
      if (user == null) {
        Fluttertoast.showToast(
            msg: 'User not found, Try signing up',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      } else {
        await user.sendEmailVerification();
      }
    } on PlatformException catch (e) {
      print(e);
      _status = AuthExceptionHandler.handleException(e);
      print(_status);
      Fluttertoast.showToast(
          msg: AuthExceptionHandler.generateExceptionMessage(_status),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }
}
