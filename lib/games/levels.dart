import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

import 'addition_work.dart';
import 'custom_level.dart';

class Levels extends StatefulWidget {
  const Levels({super.key, this.widget});

  final Widget? widget;

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  @override
  Widget build(BuildContext context) {
    return Template(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.grey[100],
          ),
          padding: EdgeInsets.all(25),
          margin: EdgeInsets.all(15),
          child: Column(
            children: levelList.keys.map((level) {
              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    elevation: 5.0,
                    shadowColor: Colors.red,
                    surfaceTintColor: Colors.greenAccent,
                    color: Colors.tealAccent[100],
                    clipBehavior: Clip.hardEdge,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (level == customLevel) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext e) =>
                                    CustomLevel(customLevel: level),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext e) =>
                                    AdditionWork(levelType: level),
                              ),
                            );
                          }
                        });
                      },
                      child: Text(level, style: TextStyle(fontSize: 25)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
