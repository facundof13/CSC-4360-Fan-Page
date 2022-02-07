import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainFeed();
  }
}

class MainFeed extends StatefulWidget {
  const MainFeed({Key? key}) : super(key: key);

  @override
  _MainFeedState createState() => _MainFeedState();
}

class _MainFeedState extends State {
  Stream<QuerySnapshot> collectionStream =
      FirebaseFirestore.instance.collection('post').snapshots();

  Route _route() {
    return PageRouteBuilder(
      pageBuilder: (context, animcation, secondaryAnimation) {
        return ComposeMessageApp();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CupertinoFullscreenDialogTransition(
            primaryRouteAnimation: animation,
            secondaryRouteAnimation: secondaryAnimation,
            linearTransition: true,
            child: child);

        child;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(_route());
          },
        ),
        body: CupertinoPageScaffold(
            child: StreamBuilder<QuerySnapshot>(
                stream: collectionStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return ListView(
                    children: <Widget>[
                      ...snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Column(children: [
                          Text(data['title']),
                          Text(data['content']),
                          Text(data['date'].toDate().toString()),
                          Divider(),
                        ]);
                      }).toList()
                    ],
                  );
                }),
            navigationBar: CupertinoNavigationBar(
              middle: const Text("Home"),
              leading: CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text("Logout")),
            )));
  }
}

class ComposeMessageApp extends StatelessWidget {
  const ComposeMessageApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const ComposeScreen();
  }
}

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({Key? key}) : super(key: key);

  @override
  _ComposeAppState createState() => _ComposeAppState();
}

class _ComposeAppState extends State {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool _isButtonDisabled = true;

  dynamic updateButton(String any) {
    setState(() {
      _isButtonDisabled =
          titleController.text.isEmpty || contentController.text.isEmpty;
    });
  }

  CollectionReference posts = FirebaseFirestore.instance.collection('post');

  Future<void> submitPost() {
    return posts
        .add({
          'title': titleController.value.text,
          'content': contentController.value.text,
          'date': Timestamp.now()
        })
        .then((value) => Navigator.pop(context))
        .catchError((error) => print("failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Compose a post"),
          leading: CupertinoButton(
            padding: EdgeInsets.all(10),
            child: Icon(CupertinoIcons.chevron_down),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Title"),
              CupertinoTextField(
                controller: titleController,
                onChanged: updateButton,
              ),
              SizedBox(height: 10),
              Text("Content"),
              CupertinoTextField(
                expands: true,
                minLines: null,
                maxLines: null,
                controller: contentController,
                onChanged: updateButton,
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                        child: Text("Submit post"),
                        onPressed: _isButtonDisabled ? null : submitPost),
                  )
                ],
              )
            ],
          ),
        )));
  }
}
