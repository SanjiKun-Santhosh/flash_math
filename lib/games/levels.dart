import 'package:flash_math/games/complex.dart';
import 'package:flash_math/games/flash.dart';
import 'package:flash_math/games/substraction.dart';
import 'package:flash_math/models/game_record.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/user_record.dart';
import '../services/hive_Service.dart';
import 'addition.dart';
import 'custom_level.dart';

class Levels extends StatefulWidget {
  const Levels({super.key, required this.gameType});

  final String gameType;

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  Map<String, bool>? _gameLevelList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathUser = context.read<MathUser?>();
      final userRecord = context.read<UserRecord?>();
      if (mathUser != null) {
        context.read<HiveService>().loadProfileImage(mathUser.uid);
      }

      if (userRecord != null) {
        GameRecord? record =
            userRecord.gameRecord?[widget.gameType.toLowerCase()];
        _gameLevelList = record?.gameData ?? {};
      } else {
        _gameLevelList = {};
      }
    });
  }

  Widget _selectGameWidget(String level) {
    switch (widget.gameType) {
      case "Addition":
        return Addition(levelType: level);
      case "Substraction":
        return Substraction(levelType: level);
      case "Complex":
        return Complex(levelType: level);
      case "Flash":
        return Flash(levelType: level);
      default:
        return const Scaffold(
          body: Center(child: Text("Error: Unknown Game Type")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveService = context.watch<HiveService>();
    return Template(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundImage: hiveService.profileImage != null
                    ? FileImage(hiveService.profileImage!)
                    : null,
                child: hiveService.profileImage == null
                    ? Icon(Icons.person)
                    : null,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(15),
            child: Column(
              children: levelList.keys.map((level) {
                bool levelBool = _gameLevelList?[level] ?? false;
                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3.0,
                      shadowColor: Colors.red,
                      surfaceTintColor: Colors.greenAccent,
                      color: const Color(0xFFeaf4f4),
                      clipBehavior: Clip.hardEdge,
                      child: TextButton(
                        onPressed: levelBool
                            ? () {
                                if (level == practiceLevel) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          CustomLevel(
                                            gameType: widget.gameType,
                                          ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          _selectGameWidget(level),
                                    ),
                                  );
                                }
                              }
                            : null,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            levelBool
                                ? Icon(Icons.lock_open_outlined,color: Colors.black,size: 25,)
                                : Icon(Icons.lock,size: 25,),
                            SizedBox(width: 20),
                            Text(
                              level,
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: CustomFontStyle().primaryFont,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
