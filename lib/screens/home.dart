import 'package:flash_math/screens/authenticate.dart';
import 'package:flash_math/screens/list_of_games.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/user_record.dart';
import '../services/hive_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Auth _auth = Auth();
  bool _loading = false;
  String _userName="Player";

  @override
  void initState() {
    super.initState();

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathUser = context.read<MathUser?>();
      final userRecord = context.read<UserRecord?>();
      if (mathUser != null) {
        context.read<HiveService>().loadProfileImage(mathUser.uid);
      }
      if(userRecord!=null){
        setState(() {
          _userName=userRecord.name;
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final mathUser = context.watch<MathUser?>();
    final hiveService = context.watch<HiveService>();
    if (mathUser != null) {
      return _loading
          ? const Loading()
          : Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        dynamic result=await _auth.signOutMethod();
                        setState(() {
                          _loading = false;
                          if (result.isFailure) {
                            ErrorHandling().showError(
                              context,
                              result.errorMsg,
                            );
                          }
                        });

                      },
                      icon: Icon(Icons.logout_rounded),
                      label: Text("Logout"),
                    ),
                    const SizedBox(width: 10,)
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                         Navigator.pushNamed(context, "/userProfile");
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: hiveService.profileImage != null
                              ? FileImage(hiveService.profileImage!)
                              : null,
                          child: hiveService.profileImage == null
                              ? Icon(Icons.person)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Welcome $_userName",
                        style: TextStyle(fontSize: 30,fontFamily: CustomFontStyle().primaryFont,fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 55),
                      ListOfGames(fontSize: 30),
                    ],
                  ),
                ),
              ),
            );
    } else {
      return const Authenticate();
    }
  }
}
