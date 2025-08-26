import 'package:flash_math/screens/listOfGames.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/user_record.dart';
import '../services/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Auth _auth = Auth();
  @override
  Widget build(BuildContext context) {

    final userRecord = context.watch<UserRecord?>();
    if (userRecord != null) {
      return
        Scaffold(
            appBar: AppBar(centerTitle: true,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 30,),
                    ElevatedButton.icon(onPressed: () {
                      setState(() {
                        Navigator.pushNamed(context, "/userProfile");
                      });
                    },
                        icon: Icon(Icons.person_2_outlined),
                        label: Text("Profile")),
                    SizedBox(width: 130,),
                    ElevatedButton.icon(onPressed: () async {
                      await _auth.signOut();
                    }, icon: Icon(Icons.logout_rounded), label: Text("Logout")),

                    SizedBox(width: 30,)
                  ],
                )

              ],),
            backgroundColor: Colors.transparent,
            body: Container(padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              margin: EdgeInsets.all(40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListOfGames(fontSize: 30),
                ],
              ),

            ));
    }
    else {
      return Template(child: Loading());
    }
  }
}
