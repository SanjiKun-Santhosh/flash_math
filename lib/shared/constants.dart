import 'package:flutter/material.dart';

class ImageGallery {
  static const primaryBG = "assets/images/primary_bg.jpeg";
  static const secondaryBG = "assets/images/secondary_bg.png";
  static const profilePicture= "assets/images/default_profile_picture.jpg";
}

enum GameTypes { addition, substraction }
class GameOutputTexts{
  static const personalBest="Your personal best is ";
  static const timeOverMsg="Sorry! The time is over!";
  static const answerWrongMsg="Sorry! The answer is wrong!";
  static const congratsMsg="Congratulations!! You new best is ";

}

class CustomFontStyle {
  final primaryFont = "Nunito";
  final secondaryFont = "Bitcount";
}



class ErrorMsg {
  final passwordErrorMsg =
      'Password must contain:\n'
      '• At least 8 characters\n'
      '• At least one uppercase letter\n'
      '• At least one lowercase letter\n'
      '• At least one digit\n'
      '• At least one special character (!@#\$&*~)';
}

class AppDecoration {
  final textDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white54,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.deepOrange,
        width: 3.0,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(35),
      gapPadding: 5.0,
    ),
  );
}
const String userHiveBox="User Box";
