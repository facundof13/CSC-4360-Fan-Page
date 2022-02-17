import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/shared/logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_moment/simple_moment.dart';

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

class MainFeedPage extends StatefulWidget {
  const MainFeedPage({Key? key}) : super(key: key);

  @override
  _MainFeedPageState createState() => _MainFeedPageState();
}

class _MainFeedPageState extends State<MainFeedPage> {
  final Stream<List<QuerySnapshot<Object?>>> _combined =
      CombineLatestStream.list([
    FirebaseFirestore.instance.collection('favorite').snapshots(),
    FirebaseFirestore.instance
        .collection('post')
        .orderBy('date', descending: true)
        .snapshots(),
  ]);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: StreamBuilder<List<QuerySnapshot>>(
            stream: _combined,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              var allFavorites =
                  snapshot.data![0].docs.map((i) => i['post_id']);

              var favoritePosts = snapshot.data![0].docs
                  .where((i) =>
                      i['user_id'] == FirebaseAuth.instance.currentUser!.uid)
                  .map((i) => i['post_id']);

              Map<String, int> postLikeCount = {};
              var posts = snapshot.data![1].docs;

              return posts.isEmpty
                  ? const SafeArea(
                      child: Center(
                      child: Text("Stay tuned, new posts coming soon!"),
                    ))
                  : ListView(
                      children: <Widget>[
                        ...posts.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(data['content'])),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  Align(
                                      alignment: Alignment.bottomLeft,
                                      child: IconButton(
                                        color: CupertinoColors.systemRed,
                                        tooltip: allFavorites
                                            .where((i) => i == document.id)
                                            .length
                                            .toString(),
                                        icon: Builder(builder: (context) {
                                          return Row(
                                            children: [
                                              favoritePosts
                                                      .contains(document.id)
                                                  ? const Icon(
                                                      CupertinoIcons.heart_fill)
                                                  : const Icon(
                                                      CupertinoIcons.heart),
                                              Flexible(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(allFavorites
                                                          .where((i) =>
                                                              i == document.id)
                                                          .length
                                                          .toString()))),
                                            ],
                                          );
                                        }),
                                        onPressed: () async {
                                          if (favoritePosts
                                              .contains(document.id)) {
                                            var doc = await FirebaseFirestore
                                                .instance
                                                .collection('favorite')
                                                .where('post_id',
                                                    isEqualTo: document.id)
                                                .where('user_id',
                                                    isEqualTo: FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid)
                                                .get();

                                            await FirebaseFirestore.instance
                                                .collection('favorite')
                                                .doc(doc.docs.first.id)
                                                .delete();
                                          } else {
                                            FirebaseFirestore.instance
                                                .collection('favorite')
                                                .add({
                                              'post_id': document.id,
                                              'user_id': FirebaseAuth
                                                  .instance.currentUser!.uid
                                            });
                                          }
                                        },
                                      )),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Text(Moment.now()
                                            .from(data['date'].toDate())),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(),
                          ]);
                        }).toList()
                      ],
                    );
            }),
        navigationBar: const CupertinoNavigationBar(
          middle: Text("Home"),
          leading: LogoutButton(),
        ));
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Stream<List<QuerySnapshot<Object?>>> _combined =
      CombineLatestStream.list([
    FirebaseFirestore.instance
        .collection('favorite')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('post')
        .orderBy('date', descending: true)
        .snapshots(),
  ]);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: StreamBuilder<List<QuerySnapshot>>(
            stream: _combined,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              var favoritePosts =
                  snapshot.data![0].docs.map((i) => i['post_id']);
              var posts = snapshot.data![1].docs;

              if (favoritePosts.isEmpty) {
                return SafeArea(
                    child: Container(
                        alignment: Alignment.center,
                        child: RichText(
                            text: const TextSpan(children: [
                          TextSpan(
                              text: "Click on the ",
                              style: TextStyle(color: CupertinoColors.black)),
                          WidgetSpan(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Icon(
                                    CupertinoIcons.heart,
                                    color: CupertinoColors.systemRed,
                                  ))),
                          TextSpan(
                              text: "on a post to favorite it!",
                              style: TextStyle(color: CupertinoColors.black)),
                        ]))));
              } else {
                return ListView(
                  children: <Widget>[
                    ...posts.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return favoritePosts.contains(document.id)
                          ? Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(data['content'])),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Align(
                                        alignment: Alignment.bottomLeft,
                                        child: IconButton(
                                          color: CupertinoColors.systemRed,
                                          icon: const Icon(
                                              CupertinoIcons.heart_fill),
                                          onPressed: () async {
                                            var doc = await FirebaseFirestore
                                                .instance
                                                .collection('favorite')
                                                .where('post_id',
                                                    isEqualTo: document.id)
                                                .where('user_id',
                                                    isEqualTo: FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid)
                                                .get();

                                            await FirebaseFirestore.instance
                                                .collection('favorite')
                                                .doc(doc.docs.first.id)
                                                .delete();
                                          },
                                        )),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(Moment.now()
                                              .from(data['date'].toDate())),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Divider(),
                            ])
                          : const SizedBox();
                    }).toList()
                  ],
                );
              }
            }),
        navigationBar: const CupertinoNavigationBar(
          middle: Text("Favorites"),
          leading: LogoutButton(),
        ));
  }
}
