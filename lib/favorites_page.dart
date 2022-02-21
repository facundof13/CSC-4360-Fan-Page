import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/shared/logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_moment/simple_moment.dart';

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
