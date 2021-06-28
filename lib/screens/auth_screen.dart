import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fipro/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:fipro/config/strings.dart' as strings;

import 'package:fipro/widgets/button_widget.dart';
import 'package:fipro/widgets/logo_widget.dart';
import 'package:fipro/widgets/title_widget.dart';

enum FormType { login, register }

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = new GlobalKey<FormState>();

  FormType formType = FormType.register;

  String? name;
  String? email;
  String? password;

  bool obscureText = true;
  bool loading = false;

  void moveToRegister() {
    formKey.currentState!.reset();
    setState(() {
      formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState!.reset();
    setState(() {
      formType = FormType.login;
    });
  }

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    if (formType == FormType.login) {
      await auth.login(email!, password!);
    } else if (formType == FormType.register) {
      await auth.registerUser(email!, password!);
    }
  }

  void validateAndSubmit() async {
    if (loading) return;
    if (validateAndSave()) {
      loading = true;
      submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoWidget(fontSize: 50),
              Center(
                child: Card(
                  child: Container(
                    width: 500,
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildInputs() + buildSubmitButtons(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  List<Widget> buildInputs() {
    if (formType == FormType.login) {
      return [
        TitleWidget(title: 'Login'),
        SizedBox(height: 24.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: strings.email),
          validator: (value) => value!.isEmpty
              ? strings.emailError
              : EmailValidator.validate(value)
                  ? null
                  : strings.emailError,
          onSaved: (value) => email = value,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: strings.password,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
          ),
          validator: (value) => value!.isEmpty ? strings.passwordError : null,
          onSaved: (value) => password = value,
          obscureText: obscureText,
        ),
      ];
    } else {
      return [
        TitleWidget(title: 'Register'),
        SizedBox(height: 24.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: strings.email),
          validator: (value) => value!.isEmpty
              ? strings.emailError
              : EmailValidator.validate(value)
                  ? null
                  : strings.emailError,
          onSaved: (value) => email = value,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: strings.password,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
          ),
          validator: (value) => value!.isEmpty ? strings.passwordError : null,
          onSaved: (value) => password = value,
          obscureText: obscureText,
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (formType == FormType.login) {
      return [
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity, // match_parent
          height: 50,
          child: ElevatedButton(
            child: Text(strings.login, style: TextStyle(fontSize: 20.0)),
            onPressed: validateAndSubmit,
          ),
        ),
        SizedBox(height: 8.0),
        TextButton(
          child: Text(strings.register, style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        SizedBox(height: 16),
        ButtonWidget(
          text: strings.register,
          onPressed: validateAndSubmit,
        ),
        SizedBox(height: 8.0),
        TextButton(
          child: Text(strings.haveAccount, style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
