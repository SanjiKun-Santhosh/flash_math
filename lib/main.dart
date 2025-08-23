import 'package:firebase_core/firebase_core.dart';
import 'package:flash_math/games/addition.dart';
import 'package:flash_math/models/user.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/home.dart';
import 'package:flash_math/screens/profile.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/screens/wrapper.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MathUser?>.value(
      value: Auth().mathUser,
      initialData: null,
      child: MaterialApp(
        routes: {
          '/home':(context) => const Template(child: Home()),
      /*    '/addition':(context) {
          final UserRecord? userRecord = ModalRoute.of(context)!.settings.arguments as UserRecord?;
        return Addition(userRecord: userRecord);
          },*/
          '/userProfile':(context) => const Template(child: UserProfile()),

        },
        home: const Wrapper() ,
      ),
    );
  }
}


