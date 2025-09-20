import 'package:flash_math/games/complex.dart';
import 'package:flash_math/games/flash.dart';
import 'package:flash_math/games/subtraction.dart';
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
import 'game_generator.dart';

class Levels extends StatefulWidget {
  const Levels({super.key, required this.gameType});

  final String gameType;

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  Map<String, bool> _gameLevelList = {};
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setupLevels();
  }

  void _setupLevels() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathUser = context.read<MathUser?>();
      final userRecord = Provider.of<UserRecord?>(context, listen: false);
      if (userRecord == null) {
        setState(() {
          _loading = false;
          _errorMessage = "No user Record found!";
        });
        return;
      }
      if (mathUser != null) {
        context.read<HiveService>().loadProfileImage(mathUser.uid);
      }
      GameRecord? gameObject =
          userRecord.gameRecord?[widget.gameType.toLowerCase()];
      setState(() {
        _gameLevelList =
            gameObject?.gameData ??
            gameTypesInitialisation(widget.gameType.toLowerCase()).gameData;
        _loading = false;
      });
    });
  }

  Widget _selectGameWidget(String level) {
    switch (widget.gameType) {
      case "Addition":
        return GameGenerator(levelType: level, queryGame: GameTypes.addition.name,);
      case "Subtraction":
        return GameGenerator(levelType: level, queryGame: GameTypes.subtraction.name,);
      case "Multiply":
        return GameGenerator(levelType: level, queryGame: GameTypes.multiply.name,);
      case "Complex":
        return GameGenerator(levelType: level, queryGame: GameTypes.complex.name,);
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
    if (_loading) {
      return const Template(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_errorMessage != null) {
      return Template(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Template(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
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
                bool levelBool = _gameLevelList[level] ?? false;
                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3.0,
                      shadowColor: Colors.black,
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
                                ? Icon(
                                    Icons.lock_open_outlined,
                                    color: Colors.black,
                                    size: 25,
                                  )
                                : Icon(Icons.lock, size: 25),
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
