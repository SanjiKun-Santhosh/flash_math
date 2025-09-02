import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'template.dart';

class CustomSheets {
  void showCustomModalBottomSheet(BuildContext context, {required String outputText,required int record,required String gameMsg}) {
    showModalBottomSheet(
      elevation: 2.0,
      isDismissible: false,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              AlertDialog(
                title: Text(
                  gameMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35),
                ),
                content: Center(
                  child: const Text(
                    GameOutputTexts.playAgain,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[300],
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Template(child: Home()),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },

                    child: const Text(
                      'OK',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),

                ],
              ),
              Column(
                children: [
                  Text(outputText,textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  Text(record.toString(),style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),)
                ],
              )
            ],
          ),
        );
      },
    );
  }
  void showLoginErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Login Error"),
          content: Text("Please check your email and password and try again."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
