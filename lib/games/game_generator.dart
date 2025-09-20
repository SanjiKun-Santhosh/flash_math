import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_math/game_algorithm/number_generator.dart';
import 'package:flash_math/models/game_record.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_record.dart';
import '../screens/custom_sheets.dart';

class GameGenerator extends StatefulWidget {
  final String queryGame;
  final String levelType;
  final int min;
  final int max;
  final int timerSetting;

  const GameGenerator({
    super.key,
    this.levelType = practiceLevel,
    this.timerSetting = defaultTimerSetting,
    this.min = minimumForRandomGen,
    this.max = maximumForRandomGen,
    required this.queryGame,
  });

  @override
  State<GameGenerator> createState() => _GameGeneratorState();
}

class _GameGeneratorState extends State<GameGenerator> {
  late int _timerSpeed;
  late int _levelIndex;
  int _levelUpAt = 0;
  int _levelCounter = 0;
  int _min = 0;
  int _max = 0;
  int _firstValue = 0;
  int _secondValue = 0;
  int _total = 0;
  int _record = 0;
  double _progressValue = 0.0;
  Timer? _timer;
  bool _isButtonChanged = false;
  bool _isButtonDisabled = false;
  String _gameType = "";
  late final String _gameTypeForDBProcessing;
  int _currentRecord = 0;
  int _globalRecord = 0;
  CustomSheets _alertDialog = CustomSheets();
  late final DatabaseService _service;
  late final GameRecord _selectedGameRecord;
  late final UserRecord _streamUserRecord;
  final Random _rand = Random();
  bool _isHighScore = false;
  bool _isInitialized = false;
  bool _isLevelledUp = false;
  late Widget _operatorWidget;
  final List<String> _listOfGameTypes = ["addition", "subtraction", "multiply"];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupGame();
    });
  }

  Widget _getOperatorIcon(String gametype) {
    switch (gametype) {
      case "addition":
        return Icon(Icons.add);
      case "subtraction":
        return Icon(Icons.remove);
      case "multiply":
        return Icon(Icons.close_sharp);
      case "complex":
        return Icon(Icons.add);
      case "flash":
        return Icon(Icons.add);
      default:
        return SizedBox.shrink(); // Return an empty widget by default
    }
  }

  Future<void> _setupGame() async {
    final userRecord = Provider.of<UserRecord?>(context, listen: false);
    if (userRecord == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      _gameType = _gameTypeForDBProcessing = widget.queryGame;
      _operatorWidget = _getOperatorIcon(_gameType);
      _service = DatabaseService(uid: userRecord.uid);
      if (widget.levelType == practiceLevel) {
        _timerSpeed = widget.timerSetting;
        _levelIndex = 0;
        _selectedGameRecord = gameTypesInitialisation(_gameType);
      } else {
        _timerSpeed = int.parse(levelList[widget.levelType]!);
        _levelIndex = levelListKeys.indexOf(widget.levelType) + 1;
        _selectedGameRecord =
            userRecord.gameRecord![_gameType] ??
            gameTypesInitialisation(_gameType);
      }
      _streamUserRecord = userRecord;
      _currentRecord = _globalRecord = int.parse(
        _selectedGameRecord.record ?? "0",
      );
      _levelUpAt = defaultLevelUpAt;
      _min = widget.min;
      _max = widget.max;
      _isInitialized = true;
    });
    await _getRandom(_gameType);
    _startProgress();
  }

  Future<void> _getRandom(String gametype) async {
    final generator = NumberGenerator(randomMin: _min, randomMax: _max);
    switch (gametype) {
      case "addition":
        await generator.random();
        await generator.randomAddTotal();
        break;
      case "subtraction":
        await generator.randomForSub();
        await generator.randomSubTotal();
        break;
      case "multiply":
        await generator.random();
        await generator.randomMultiplyTotal();
        break;
      default:
        await generator.random();
        await generator.randomAddTotal();
        break;
    }
    final bool isButtonChangeOperation = _rand.nextBool();
    if (mounted) {
      setState(() {
        _firstValue = generator.firstValue;
        _secondValue = generator.secondValue;
        _total = generator.total;
        if (_gameTypeForDBProcessing == GameTypes.flash.name) {
          _isButtonChanged = isButtonChangeOperation;
        }
      });
    }
  }

  void _startProgress() {
    final oneHundredthOfASecond = Duration(milliseconds: _timerSpeed);
    _timer = Timer.periodic(oneHundredthOfASecond, (timer) {
      if (_progressValue >= 1.0) {
        if (mounted) timer.cancel();
        _handleTimeOver();
      } else {
        if (mounted) {
          setState(() {
            _progressValue += 0.01;
          });
        }
      }
    });
  }

  void _resetProgress() {
    _stopProgress();
    _startProgress();
  }

  void _stopProgress() {
    _timer?.cancel();
    setState(() {
      _progressValue = 0.0;
    });
  }

  void _levelUp(int levelIndex) {
    setState(() {
      if (widget.levelType != practiceLevel) {
        if (mounted) {
          _timerSpeed = int.parse(levelList[levelListKeys[levelIndex - 1]]!);
          _levelIndex++;
          _levelCounter = 0;
          _isLevelledUp = true;
        }
      }
    });
  }

  void _handleTimeOver() {
    if (mounted) {
      setState(() {
        _isButtonDisabled = true;
        _stopProgress();
        if (_record > _currentRecord) {
          _globalRecord = _record;
          _updateRecordDatabase(_record);
          _isHighScore = true;
        }
        _alertDialog.showCustomModalBottomSheet(
          context,
          outputText: GameOutputTexts.personalBest,
          record: _globalRecord,
          gameMsg: GameOutputTexts.timeOverMsg,
          playConfetti: _isHighScore,
        );
      });
    }
  }

  bool _checkBasedOnGametype(int firstValue, int secondValue, int total) {
    switch (_gameType) {
      case "addition":
        return _firstValue + _secondValue == _total;
      case "subtraction":
        return _firstValue - _secondValue == _total;
      case "multiply":
        return _firstValue * _secondValue == _total;
      default:
        return _firstValue + _secondValue == _total;
    }
  }

  void _processAnswer(bool userGuess) {
    if (_progressValue >= 1.0) {
      _handleTimeOver();
      return;
    }
    bool isActuallyCorrect = _checkBasedOnGametype(
      _firstValue,
      _secondValue,
      _total,
    );
    if (userGuess == isActuallyCorrect) {
      if (_gameTypeForDBProcessing == GameTypes.complex.name || _gameTypeForDBProcessing == GameTypes.flash.name) {
        int randomIndex = _rand.nextInt(_listOfGameTypes.length);
        _gameType = _listOfGameTypes[randomIndex].toLowerCase();
      }
      _handleCorrectAnswer(_gameType);
    } else {
      _handleWrongAnswer();
    }
  }

  Future<void> _handleCorrectAnswer(String gameType) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _levelCounter++;
      _record++;
    });
    if (_levelCounter > _levelUpAt &&
        _levelIndex <= 5 &&
        widget.levelType != practiceLevel) {
      setState(() {
        _selectedGameRecord.gameData[levelListKeys.elementAt(_levelIndex)] =
            true;
        _levelUp(_levelIndex);
      });
      _stopProgress();
      String? result = await CustomSheets().showLevelUp(
        context,
        _levelIndex.toString(),
      );
      if (result == "exit") {
        _handleWrongAnswer(gameMessage: GameOutputTexts.onFire);
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _getRandom(gameType);
      _operatorWidget = _getOperatorIcon(gameType);
      _resetProgress();
    });
  }

  void _handleWrongAnswer({
    String gameMessage = GameOutputTexts.answerWrongMsg,
  }) {
    if (mounted) {
      setState(() {
        _isButtonDisabled = true;
        _stopProgress();
        if (_record > _currentRecord) {
          _globalRecord = _record;
          _updateRecordDatabase(_record);
          _isHighScore = true;
        }
        _alertDialog.showCustomModalBottomSheet(
          context,
          outputText: GameOutputTexts.personalBest,
          record: _globalRecord,
          gameMsg: gameMessage,
          playConfetti: _isHighScore,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRecordDatabase(int currentRecord) async {
    if (widget.levelType != practiceLevel) {
      _selectedGameRecord.record = currentRecord.toString();
      Map<String, GameRecord>? data = _streamUserRecord.gameRecord;
      data?.update(_gameTypeForDBProcessing, (update) => _selectedGameRecord);
      if (data != null) {
        await _service.updateUserRecord(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, "/home");
          },
        ),
      ),
      backgroundColor: Colors.blue[100],
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              "Question ${_record + 1}",
              style: TextStyle(
                fontSize: 30,
                fontFamily: CustomFontStyle().primaryFont,
              ),
            ),
            SizedBox(height: 30),
            Card(
              child: SizedBox(
                height: 175,
                width: 400,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _firstValue.toString(),
                              style: TextStyle(fontSize: 40),
                            ),
                            _operatorWidget,
                            Text(
                              _secondValue.toString(),
                              style: TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                        SizedBox(height: 13),
                        SizedBox(
                          child: Text(
                            _total.toString(),
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                        SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),_isButtonChanged
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () => _processAnswer(true),
                  icon: const Icon(Icons.check_circle, size: 60),
                ),
                const SizedBox(width: 60),
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () => _processAnswer(false),
                  icon: const Icon(Icons.close, size: 60),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () => _processAnswer(false),
                  icon: const Icon(Icons.close, size: 60),
                ),
                const SizedBox(width: 60),
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () => _processAnswer(true),
                  icon: const Icon(Icons.check_circle, size: 60),
                ),
              ],
            ),
            Text(
              "Game on!",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _currentRecord >= _record
                ? Column(
                    children: [
                      Text(
                        GameOutputTexts.personalBest,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "$_currentRecord",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        GameOutputTexts.congratsMsg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "$_record",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            _isLevelledUp
                ? AnimatedTextKit(
                    animatedTexts: [
                      FlickerAnimatedText(
                        GameOutputTexts.levelUp,
                        textStyle: TextStyle(
                          fontSize: 25,
                          fontFamily: CustomFontStyle().secondaryFont,
                        ),
                      ),
                    ],
                    pause: Duration(seconds: 5),
                    onFinished: () {
                      setState(() {
                        _isLevelledUp = false;
                      });
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
