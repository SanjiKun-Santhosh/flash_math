import 'package:firebase_core/firebase_core.dart';
import 'package:flash_math/models/storage_hive_model.dart';
import 'package:flash_math/models/user.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/authenticate.dart';
import 'package:flash_math/screens/home.dart';
import 'package:flash_math/screens/login.dart';
import 'package:flash_math/screens/profile/profile.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/screens/wrapper.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/services/hive_Service.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(UserHiveStorageAdapter());
  await Hive.openBox<UserHiveStorage>(userHiveBox);

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<MathUser?>.value(
          value: Auth().mathUser,
          initialData: null,
        ),
        StreamProvider<UserRecord?>(
          create: (context) {
            final mathUser = Provider.of<MathUser?>(context);
            return mathUser != null
                ? DatabaseService(uid: mathUser.uid).userData
                : Stream.value(null);
          },
          initialData: null,
        ),
         ChangeNotifierProvider(create: (context){
          return HiveService();
        })
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => const Template(child: Home()),
        '/userProfile': (context) => const Template(child: UserProfile()),
      },
      home: const Wrapper(),
    );
  }
}
