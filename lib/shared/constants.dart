import 'package:flutter/material.dart';

class ImageGallery {
  final primaryBG = "assets/images/primary_bg.jpeg";
  final secondaryBG = "assets/images/secondary_bg.png";
  final profilePicture= "assets/images/default_profile_picture.jpg";
}

enum GameTypes { addition, substraction }

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
