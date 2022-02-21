import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page/shared/logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_moment/simple_moment.dart';

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
