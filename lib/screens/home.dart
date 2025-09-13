import 'package:flash_math/screens/authenticate.dart';
import 'package:flash_math/screens/listOfGames.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/hive_Service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Auth _auth = Auth();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathUser = context.read<MathUser?>();

      if (mathUser != null) {
        context.read<HiveService>().loadProfileImage(mathUser.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mathUser = context.watch<MathUser?>();
    final hiveService = context.watch<HiveService>();
    if (mathUser != null) {
      return _loading
          ? Loading()
          : Scaffold(
              appBar: AppBar(
                toolbarHeight: 70,
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/userProfile");
                      },
                      icon: Icon(Icons.person_2_outlined),
                      label: Text("Profile"),
                    ),

                    CircleAvatar(
                      radius: 35,
                      backgroundImage: hiveService.profileImage != null
                          ? FileImage(hiveService.profileImage!)
                          : null,
                      child: hiveService.profileImage == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        await _auth.signOutMethod();
                        setState(() {
                          _loading = false;
                        });
                      },
                      icon: Icon(Icons.logout_rounded),
                      label: Text("Logout"),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                  margin: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [SizedBox(height: 55), ListOfGames(fontSize: 30)],
                  ),
                ),
              ),
            );
    } else {
      return Authenticate();
    }
  }
}
