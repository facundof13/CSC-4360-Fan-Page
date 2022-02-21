import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/shared/logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:fan_page/favorites_page.dart';
import 'package:fan_page/main_feed_page.dart';

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
  composePost() {
    var postController = TextEditingController();

    showCupertinoDialog(
        builder: (builder) {
          return CupertinoAlertDialog(
            title: const Text("Compose a post"),
            content: Column(
              children: [
                const Text("Enter post details"),
                const Padding(padding: EdgeInsets.only(top: 10)),
                CupertinoTextField(
                  controller: postController,
                  placeholder: "Enter post",
                  maxLines: null,
                  autofocus: true,
                ),
              ],
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("Discard"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                },
              ),
              CupertinoDialogAction(
                child: const Text("Post message"),
                isDefaultAction: true,
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop("Discard");

                  await FirebaseFirestore.instance.collection('post').add({
                    'content': postController.text,
                    'date': Timestamp.now()
                  });
                },
              )
            ],
          );
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('user').snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data!.docs.isNotEmpty &&
                    snapshot.data!.docs.where((element) {
                      return element.data()['uid'] ==
                              FirebaseAuth.instance.currentUser!.uid &&
                          element.data()['is_admin'] != null &&
                          element.data()['is_admin'];
                    }).isNotEmpty) {
                  return FloatingActionButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: () {
                      composePost();
                    },
                  );
                }
              }

              return const SizedBox();
            }),
        body: Stack(fit: StackFit.expand, children: [
          CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.news), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.heart), label: "Favorites"),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                return CupertinoTabView(builder: (BuildContext context) {
                  if (index == 0) {
                    return const MainFeedPage();
                  } else {
                    return const FavoritesPage();
                  }
                });
              })
        ]));
  }
}
