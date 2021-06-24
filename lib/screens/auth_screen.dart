import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fipro/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:fipro/config/strings.dart' as strings;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInputs() + buildSubmitButtons(),
          ),
        ),
      ],
    ));
  }

  List<Widget> buildInputs() {
    if (formType == FormType.login) {
      return [
        AccentColorOverride(
          child: TextFormField(
            decoration: InputDecoration(labelText: strings.email),
            validator: (value) => value!.isEmpty
                ? strings.emailError
                : EmailValidator.validate(value)
                    ? null
                    : strings.emailError,
            onSaved: (value) => email = value,
          ),
        ),
        SizedBox(height: 10.0),
        AccentColorOverride(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: strings.password,
              suffixIcon: IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggle,
              ),
            ),
            validator: (value) => value!.isEmpty ? strings.passwordError : null,
            onSaved: (value) => password = value,
            obscureText: obscureText,
          ),
        ),
      ];
    } else {
      return [
        AccentColorOverride(
          child: TextFormField(
            decoration: InputDecoration(labelText: strings.name),
            validator: (value) => value!.isEmpty ? strings.nameError : null,
            onSaved: (value) => name = value,
          ),
        ),
        SizedBox(height: 10.0),
        AccentColorOverride(
          child: TextFormField(
            decoration: InputDecoration(labelText: strings.email),
            validator: (value) => value!.isEmpty
                ? strings.emailError
                : EmailValidator.validate(value)
                    ? null
                    : strings.emailError,
            onSaved: (value) => email = value,
          ),
        ),
        SizedBox(height: 10.0),
        AccentColorOverride(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: strings.password,
              suffixIcon: IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggle,
              ),
            ),
            validator: (value) => value!.isEmpty ? strings.passwordError : null,
            onSaved: (value) => password = value,
            obscureText: obscureText,
          ),
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
            ),
            onPressed: validateAndSubmit,
          ),
        ),
        TextButton(
          child: Text(strings.register, style: TextStyle(fontSize: 20.0)),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity, // match_parent
          height: 50,
          child: ElevatedButton(
            child: Text(strings.register, style: TextStyle(fontSize: 20.0)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              elevation: 8.0,
            ),
            onPressed: validateAndSubmit,
          ),
        ),
        TextButton(
          child: Text(strings.haveAccount, style: TextStyle(fontSize: 20.0)),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key? key, this.color, this.child})
      : super(key: key);

  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child!,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
