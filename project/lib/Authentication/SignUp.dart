import 'package:form_field_validator/form_field_validator.dart';
import 'package:project/Services/AuthManagement.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = new GlobalKey<FormState>();
  String email = '', name = '', password = '';
  bool isHidden = true;
  Auth auth;
  double height;
  // Form validators
  validateAndSave() {
    final form = formKey.currentState;

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
        await auth.signUp(name.trim(), email.trim(), password.trim());
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Create Auth object for accessing authentication services
    auth = Auth(context);
  }

  // UI Code starts
  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: registerForm(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> registerForm() {
    return <Widget>[
      TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: 'Name',
            suffixIcon: Icon(
              Icons.person,
              color: Colors.green,
            )),
        validator: MultiValidator([
          RequiredValidator(errorText: 'Name is required'),
          MinLengthValidator(5,
              errorText: 'Name must be at least 5 characters long'),
          MaxLengthValidator(10,
              errorText: "Name shouldn't exceed 10 characters long"),
        ]),
        onSaved: (value) => name = value,
      ),
      SizedBox(
        height: 15,
      ),
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
        onSaved: (value) => email = value,
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
        validator: MultiValidator([
          RequiredValidator(errorText: 'Password is required'),
          MinLengthValidator(5,
              errorText: 'Password must be at least 6 characters long'),
        ]),
        onSaved: (value) => password = value,
      ),
      SizedBox(height: 15),
      RaisedButton(
        color: Colors.blue,
        child: Text('Sign up', style: TextStyle(color: Colors.white)),
        onPressed: validateAndSubmit,
      ),
      SizedBox(
        height: 10,
      ),
      Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            'Make sure you verify your email before login!',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      _signInButton()
    ];
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        auth.signInWithGoogle();
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
                'Sign up with Google',
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
