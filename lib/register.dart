import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/services/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterApp extends StatelessWidget {
  const RegisterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RegisterScreen();
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State {
  FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String bullet = "\u2022";

  bool _isLoading = false;

  register() async {
    var inputs = [
      {"value": usernameController.text, 'type': 'email'},
      {"value": passwordController.text, 'type': 'password'},
      {"value": firstNameController.text, 'type': 'text'},
      {"value": lastNameController.text, 'type': 'text'}
    ];

    if (!Validator.validateControllers(inputs)) {
      showCupertinoDialog(
          builder: (builder) {
            return CupertinoAlertDialog(
              title: const Text("Form Error"),
              content: Column(
                children: [
                  if (!Validator.validateText(firstNameController.text)) ...[
                    Text('$bullet First name is not valid.')
                  ],
                  if (!Validator.validateText(lastNameController.text)) ...[
                    Text('$bullet Last name is not valid.')
                  ],
                  if (!Validator.validateEmail(usernameController.text)) ...[
                    Text(
                        '$bullet Username is not valid. Username must be a valid email.')
                  ],
                  if (!Validator.validatePassword(passwordController.text)) ...[
                    Text(
                        '$bullet Password is not valid. Password must be at least 8 characters long.')
                  ],
                ],
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: const Text("Okay"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop("Discard");
                  },
                )
              ],
            );
          },
          context: context);

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.createUserWithEmailAndPassword(
          email: usernameController.text, password: passwordController.text);

      var userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('user').add({
        'first_name': firstNameController.text,
        'is_admin': false,
        'last_name': lastNameController.text,
        'registered_on': Timestamp.now(),
        'uid': userId,
      });

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      return showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: Text(getErrorMessage(e.code)),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              child: const Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            middle: const Text("Register")),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    CupertinoFormSection(
                        header: const Text("Personal Information"),
                        children: [
                          CupertinoTextField(
                            padding: const EdgeInsets.fromLTRB(25, 15, 10, 15),
                            prefix: const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text("First Name")),
                            controller: firstNameController,
                            clearButtonMode: OverlayVisibilityMode.editing,
                          ),
                          CupertinoTextField(
                            padding: const EdgeInsets.fromLTRB(25, 15, 10, 15),
                            prefix: const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text("Last Name")),
                            controller: lastNameController,
                            clearButtonMode: OverlayVisibilityMode.editing,
                          ),
                        ]),
                    CupertinoFormSection(
                        header: const Text("Login"),
                        children: [
                          CupertinoTextField(
                            padding: const EdgeInsets.fromLTRB(25, 15, 10, 15),
                            prefix: const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text("Username")),
                            controller: usernameController,
                            clearButtonMode: OverlayVisibilityMode.editing,
                          ),
                          CupertinoTextField(
                            padding: const EdgeInsets.fromLTRB(25, 15, 10, 15),
                            prefix: const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text("Password")),
                            obscureText: true,
                            controller: passwordController,
                            clearButtonMode: OverlayVisibilityMode.editing,
                          ),
                        ]),
                  ])),
              if (_isLoading) ...[
                const Spacer(),
                const Center(child: CupertinoActivityIndicator()),
              ],
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                        child: CupertinoButton.filled(
                            child: const Text("Register for account"),
                            onPressed: register))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return '';
      case 'email-already-in-use':
        return 'A user already exists with this email.';
      case 'invalid-email':
        return 'Your email is not valid';
      default:
        return 'There was an error creating your account';
    }
  }
}
