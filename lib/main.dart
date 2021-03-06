import 'package:fan_page/firebase_options.dart';
import 'package:fan_page/home_page.dart';
import 'package:fan_page/login.dart';
import 'package:fan_page/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import 'package:fan_page/services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  return runApp(const MyCupertinoApp());
}

class MyCupertinoApp extends StatelessWidget {
  const MyCupertinoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: const MainPage(),
      initialRoute: '/',
      routes: {
        '/register': (context) => const RegisterApp(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State {
  FirebaseAuth auth = FirebaseAuth.instance;

  final user = FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      Auth.setUser(user);
    } else {
      Auth.clearUser();
    }
  });

  @override
  Widget build(BuildContext content) {
    return StreamBuilder(
        stream: auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> user) {
          return user.data?.uid != null ? const HomePage() : const LoginApp();
        });
  }
}
