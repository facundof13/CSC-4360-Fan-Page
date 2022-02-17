import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class Auth {
  static User? user;
  static bool? isAdmin = false;

  static Stream<QuerySnapshot<dynamic>> getIsAdmin = FirebaseFirestore.instance
      .collection('admin')
      // .where('uid', isEqualTo: user?.uid)
      .snapshots();

  static setUser(User user1) {
    user = user1;
  }

  static clearUser() {
    user = null;
  }

  static final Stream<List<QuerySnapshot<Object?>>> combined =
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
}
