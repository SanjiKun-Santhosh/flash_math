import 'package:firebase_core/firebase_core.dart';
import 'package:flash_math/models/storage_hive_model.dart';
import 'package:flash_math/models/user.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/home.dart';
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
        ProxyProvider<MathUser?, DatabaseService?>(
          update: (context, mathUser, previousDatabaseService) {
            if (mathUser == null) {
              return null;
            }
            if (previousDatabaseService?.uid == mathUser.uid) {
              return previousDatabaseService;
            }
            return DatabaseService(uid: mathUser.uid);
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return HiveService();
          },
        ),
      ],
      child: Consumer<DatabaseService?>(
        builder: (context, dbService, child) {
          return StreamProvider<UserRecord?>.value(
            value: dbService?.userData ?? Stream.value(null),
            initialData: null,
            child: child,
          );
        },
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case '/home':
            return CustomNavigation().navigateToDetailScreen(
              context,
              const Template(child: Home()),
            );
          case '/userProfile':
            return CustomNavigation().navigateToDetailScreen(
              context,
              const Template(child: UserProfile()),
            );
          default:
            return CustomNavigation().navigateToDetailScreen(
              context,
              const Template(child: Home()),
            );
        }
      },

      home: const Wrapper(),
    );
  }
}
