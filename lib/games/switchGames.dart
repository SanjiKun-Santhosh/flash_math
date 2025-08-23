import 'package:flash_math/games/addition.dart';
import 'package:flash_math/games/substraction.dart';
import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../models/user.dart';

class SwitchGames extends StatefulWidget {
  final String gameChosen;

  const SwitchGames({super.key, required this.gameChosen});

  @override
  State<SwitchGames> createState() => _SwitchGamesState();
}

class _SwitchGamesState extends State<SwitchGames> {
  @override
  Widget build(BuildContext context) {
    final mathUser = Provider.of<MathUser?>(context);
    return StreamBuilder<UserRecord>(
      stream: DatabaseService(uid: mathUser!.uid).userData,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return Text('Something went wrong: ${asyncSnapshot.error}');
        }
        if (asyncSnapshot.hasData) {
          UserRecord? userRecord = asyncSnapshot.data;
          switch (widget.gameChosen) {
            case "Addition":
              return Addition(userRecord: userRecord);
            case "Substraction":
              return Substraction(userRecord: userRecord);
            default:
              return const Template(child: Loading());
          }
          ;
        } else {
          return const Template(child: Loading());
        }
      },
    );
  }
}
