import 'package:form_field_validator/form_field_validator.dart';
import 'package:project/Authentication/ForgotPassword.dart';
import 'package:project/Services/AuthManagement.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = new GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  Auth auth;
  bool isHidden = true;
  double height;
  @override
  void initState() {
    super.initState();
    // Create Auth object for accessing authentication services
    auth = new Auth(context);
  }

  // Form validators
  validateAndSave() {
    final form = formkey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    // Form is not filled properly, so return false
    return false;
  }

  validateAndSubmit() async {
    // Takes keyboard out of focus
    // FocusScope.of(context).unfocus();
    if (validateAndSave()) {
      try {
        await auth.signIn(_email.trim(), _password.trim());
      } catch (e) {
        print(e);
      }
    }
  }

  // UI code starts
  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: loginForm(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> loginForm() {
    return <Widget>[
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            labelText: 'Email',
            suffixIcon: Icon(
              Icons.email,
              color: Colors.red,
            )),
        validator: MultiValidator([
          RequiredValidator(errorText: 'Email is required'),
          EmailValidator(errorText: 'Enter a valid email address')
        ]),
        onSaved: (value) => _email = value,
      ),
      SizedBox(height: 15),
      TextFormField(
        decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(isHidden ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  isHidden = !isHidden;
                });
              },
            )),
        obscureText: isHidden,
        validator: (value) {
          if (value.isEmpty)
            return "Password is required";
          else
            return null;
        },
        onSaved: (value) => _password = value,
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                'Send Email verification Link',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await auth.verifyEmail();
                } catch (e) {
                  print(e);
                }
              },
            ),
            FlatButton(
              child: Text(
                'Forgot password?',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()));
              },
            ),
          ],
        ),
      ),
      RaisedButton(
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.blue,
        onPressed: validateAndSubmit,
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Don't have an account?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          RaisedButton(
            child: Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.teal,
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Text(
          "Other SignIn Options",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      _signInButton()
    ];
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await auth.signInWithGoogle();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("images/google_logo.png"),
                height: this.height / 15),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
