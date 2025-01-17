import 'package:form_field_validator/form_field_validator.dart';
import 'package:project/Services/AuthManagement.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';
  Auth auth;
  final formKey = new GlobalKey<FormState>();

  // Form validation
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
    FocusScope.of(context).unfocus();
    if (validateAndSave()) {
      try {
        await auth.resetPassword(email);
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Create Auth object for accessing authentication services
    auth = new Auth(context);
  }

  // UI Code starts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Container(
          margin: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: resetForm(),
            ),
          ),
        ),
      ),
    );
  }

  resetForm() {
    // Gets width of the screen
    double width = MediaQuery.of(context).size.width;
    return <Widget>[
      TextFormField(
        decoration: InputDecoration(
            labelText: 'Email', suffixIcon: Icon(MdiIcons.email)),
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          email = value;
        },
        validator: MultiValidator([
          RequiredValidator(errorText: 'Email is required'),
          EmailValidator(errorText: 'Enter a valid email address')
        ]),
      ),
      SizedBox(height: 15),
      SizedBox(
        width: width,
        child: RaisedButton(
          color: Colors.blue,
          child: Text('Reset password', style: TextStyle(color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      ),
    ];
  }
}
