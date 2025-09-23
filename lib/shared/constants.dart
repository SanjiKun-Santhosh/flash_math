import 'package:flash_math/models/game_record.dart';
import 'package:flutter/material.dart';

class ImageGallery {
  static const primaryBG = "assets/images/primary_bg.jpeg";
  static const secondaryBG = "assets/images/secondary_bg.png";
  static const profilePicture = "assets/images/default_profile_picture.jpg";
}

enum GameTypes { addition, subtraction, multiply,complex, flash }


class GameOutputTexts {
  static const personalBest = "Your personal best is ";
  static const timeOverMsg = "Time over!!";
  static const answerWrongMsg = "Wrong answer!!";
  static const congratsMsg = "Congratulations!! You new best is ";
  static const playAgain = "Do you want to play again?";
  static const levelUp="New level reached!";
  static const onFire="You are fantastic!";
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

const String userHiveBox = "User Box";

const Map<String, String> levelList = {
  "Level 1": "100",
  "Level 2": "80",
  "Level 3": "55",
  "Level 4": "30",
  "Level 5": "15",
  "Practice": "",
};
final List levelListKeys = levelList.keys.toList();
const String practiceLevel = "Practice";
const int defaultTimerSetting = 30;
const int defaultLevelUpAt = 5;
const int maximumLevelUpAt = 10000;
const int minimumForRandomGen = 0;
const int maximumForRandomGen = 100;

GameRecord gameTypesInitialisation(String gameMode){
  final GameRecord gameInitialisation = GameRecord(
    ranking: 0,
    record: "0",
    gameType: gameMode,
    gameData: const {
      "Level 1": true,
      "Level 2": false,
      "Level 3": false,
      "Level 4": false,
      "Level 5": false,
      "Practice": true,
    },
  );
  return gameInitialisation;
}

final Map<String,GameRecord> gameRecordInitialization={
  "addition": gameTypesInitialisation("addition"),
  "subtraction": gameTypesInitialisation("subtraction"),
  "multiply": gameTypesInitialisation("multiply"),
  "complex": gameTypesInitialisation("complex"),
  "flash": gameTypesInitialisation("flash"),
};

final List<String> gameTypeObjectList = gameRecordInitialization.keys.toList();
class CustomNavigation {

PageRouteBuilder navigateToDetailScreen(BuildContext context, Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
  );
}}

class ErrorHandling{
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text(message,textAlign:TextAlign.center,style: TextStyle(fontSize: 30),)), backgroundColor: Colors.red),
    );
  }
}



