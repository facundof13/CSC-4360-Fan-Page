import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  void signInWithGoogle() async {
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      user = userCredential.user;
    }

    if (user != null) {
      var userExists =
          await FirebaseFirestore.instance.collection('user').get();

      var signedInUser =
          userExists.docs.where((element) => element['uid'] == user!.uid);

      if (signedInUser.isEmpty) {
        List<String> displayName = user.displayName!.split(" ");
        String firstName = displayName[0];
        String lastName = displayName[1];

        var userMap = {
          'first_name': firstName,
          'last_name': lastName,
          'registered_on': Timestamp.now(),
          'uid': user.uid,
        };

        await FirebaseFirestore.instance.collection('user').add(userMap);
      }
    }
  }

  void login() async {
    String email = usernameController.value.text;
    String password = passwordController.value.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      return showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content:
              const Text("Incorrect username or password. Please try again."),
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CupertinoPageScaffold(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                Center(child: const CupertinoActivityIndicator())
              ]))
        : CupertinoPageScaffold(
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Facundo's Fan Page",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 68,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Email",
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
                              child: const Text("Login"), onPressed: login))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: CupertinoButton.filled(
                              onPressed: () => {signInWithGoogle()},
                              child: const Text("Sign in with Google"))),
                    ],
                  ),
                  Center(
                      child: CupertinoButton(
                          child: const Text("Or register with email"),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          })),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ));
  }
}
