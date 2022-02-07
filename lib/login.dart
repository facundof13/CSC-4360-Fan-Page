import 'package:fan_page/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State {
  bool _isButtonDisabled = true;
  bool _isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  updateButton(value) {
    setState(() {
      _isButtonDisabled =
          usernameController.text.isEmpty || passwordController.text.isEmpty;
    });
  }

  void login() async {
    String email = usernameController.value.text;
    String password = passwordController.value.text;

    setState(() {
      _isLoading = true;
    });

    await auth.signInWithEmailAndPassword(email: email, password: password);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CupertinoPageScaffold(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Center(child: const CupertinoActivityIndicator())
              ]))
        : CupertinoPageScaffold(
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Username",
                  textAlign: TextAlign.left,
                ),
                CupertinoTextField(
                  suffix: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(CupertinoIcons.person)),
                  clearButtonMode: OverlayVisibilityMode.always,
                  controller: usernameController,
                  onChanged: (value) => updateButton(value),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Password"),
                CupertinoTextField(
                  suffix: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(CupertinoIcons.padlock)),
                  obscureText: true,
                  controller: passwordController,
                  onChanged: (value) => updateButton(value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: CupertinoButton.filled(
                            child: const Text("Login"),
                            onPressed: _isButtonDisabled ? null : login))
                  ],
                ),
                Center(
                    child: CupertinoButton(
                        child: const Text("Need an account?"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        })),
                const SizedBox(height: 10),
              ],
            ),
          ));
  }
}
