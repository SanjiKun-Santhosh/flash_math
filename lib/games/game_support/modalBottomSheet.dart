import 'package:flutter/material.dart';

import '../../screens/home.dart';
import '../../screens/template.dart';

class ModalBottomSheet {
  void showCustomModalBottomSheet(context, {required String outputText,required String gameMsg}) {
    showModalBottomSheet(
      elevation: 2.0,
      isDismissible: false,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              AlertDialog(
                title: Text(
                  gameMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40),
                ),
                content: Center(
                  child: const Text(
                    'Do you want to play again?',
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
              Text(outputText,textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20))
            ],
          ),
        );
      },
    );
  }
}
