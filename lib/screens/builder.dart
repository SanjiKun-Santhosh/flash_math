import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_math/games/addition.dart';
import 'package:flash_math/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_record.dart';
import 'loading.dart';

class Builder extends StatefulWidget {
  const Builder({super.key});

  @override
  State<Builder> createState() => _BuilderState();
}

class _BuilderState extends State<Builder> {
  @override
  Widget build(BuildContext context) {
    final user=Provider.of<User>(context);
    return StreamBuilder<UserRecord>(stream: DatabaseService(uid: user.uid).userData,
        builder: (context,asyncSnapshot){
      if(asyncSnapshot.hasData){
UserRecord? record=asyncSnapshot.data;
return Addition(userRecord: record);
      }else{
        return Loading();
      }
        });
  }
}
