import 'package:flash_math/games/switchGames.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

class ListOfGames extends StatelessWidget {
  final double fontSize;

  const ListOfGames({super.key, required this.fontSize});

  List<String> get _gamesList => ["Addition", "Substraction", "Complex","Flash"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: _gamesList
            .map(
              (val) => Center(
                child: Column(
                  children: [
                    Card.outlined(
                      borderOnForeground: true,
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
                      color: const Color(0xFFeaf4f4),
      
                      clipBehavior: Clip.hardEdge,
      
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SwitchGames(gameChosen: val),
                            ),
                          );
                        },
      
                        splashColor: Colors.blue.withAlpha(50),
                        child: SizedBox(
                          width: 250,
                          height: 75,
                          child: Center(
                            child: Text(
                              val,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: CustomFontStyle().primaryFont,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15,)
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
