import 'package:flash_math/games/substraction.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'addition.dart';
import 'custom_level.dart';

class Levels extends StatefulWidget {
  const Levels({super.key, required this.gameType});

  final String gameType;

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  Widget _selectGameWidget(String level) {
    if (widget.gameType == "Addition") {
      return Addition(levelType: level);
    } else if (widget.gameType == "Substraction") {
      return Substraction(levelType: level);
    }
    return const Scaffold(
      body: Center(
        child: Text("Error: Unknown Game Type"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.all(15),
          child: Column(
            children: levelList.keys.map((level) {
              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5.0,
                    shadowColor: Colors.red,
                    surfaceTintColor: Colors.greenAccent,
                    color: const Color(0xFFfb6f92),
                    clipBehavior: Clip.hardEdge,
                    child: TextButton(
                      onPressed: () {
                        if (level == customLevel) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  CustomLevel(gameType: widget.gameType),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => _selectGameWidget(level),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all<Size>(const Size.fromWidth(150)),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: CustomFontStyle().primaryFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
    );
  }
}