import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: const EdgeInsets.all(10),
        onPressed: () {
          showCupertinoDialog(
              context: context,
              builder: (builder) {
                return CupertinoAlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you would like to logout?"),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      child: const Text("No"),
                      onPressed: () => {
                        Navigator.of(context, rootNavigator: true)
                            .pop("Discard")
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text("Yes"),
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true)
                            .pop("Discard");
                        await FirebaseAuth.instance.signOut();
                      },
                    )
                  ],
                );
              });
        },
        child: const Icon(CupertinoIcons.square_arrow_left));
  }
}
