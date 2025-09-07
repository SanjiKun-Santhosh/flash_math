import 'dart:async';
import 'package:flash_math/game_algorithm/number_generator.dart';
import 'package:flash_math/models/game_record.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_record.dart';
import '../screens/custom_sheets.dart';

class Addition extends StatefulWidget {
  final String levelType;
  final int min;
  final int max;
  final int timerSetting;

  const Addition({
    super.key,
    this.levelType = practiceLevel,
    this.timerSetting = defaultTimerSetting,
    this.min = minimumForRandomGen,
    this.max = maximumForRandomGen,
  });

  @override
  State<Addition> createState() => _AdditionState();
}

class _AdditionState extends State<Addition> {
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
  bool _isButtonDisabled = false;
  final String _gameType = GameTypes.addition.name;
  int currentRecord = 0;
  int globalRecord = 0;
  CustomSheets alertDialog = CustomSheets();
  late final DatabaseService _service;
  late final GameRecord _selectedGameRecord;
  late final UserRecord _streamUserRecord;

  //late final List<String> _userGameRecordsKeyList;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupGame();
    });
  }

  void _setupGame() {
    final userRecord = Provider.of<UserRecord?>(context, listen: false);
    if (userRecord == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    _service = DatabaseService(uid: userRecord.uid);
    if (widget.levelType == practiceLevel) {
      _timerSpeed = widget.timerSetting;
      _levelIndex = 0;
      _selectedGameRecord = gameTypesInitialisation(_gameType);
    } else {
      _timerSpeed = int.parse(levelList[widget.levelType]!);
      _levelIndex = levelListKeys.indexOf(widget.levelType) + 1;
      _selectedGameRecord = userRecord.gameRecord![_gameType]!;
    }
    _streamUserRecord = userRecord;
    //_userGameRecordsKeyList=gameTypeObjectList;
    currentRecord = globalRecord = int.parse(_selectedGameRecord.record ?? "0");
    _levelUpAt = defaultLevelUpAt;
    _min = widget.min;
    _max = widget.max;
    setState(() {
      _isInitialized = true;
    });
    _getRandom();
    startProgress();
  }

  void _getRandom() async {
    final generator = NumberGenerator(randomMin: _min, randomMax: _max);
    await generator.random();
    await generator.randomAddTotal();
    if (mounted) {
      setState(() {
        _firstValue = generator.firstValue;
        _secondValue = generator.secondValue;
        _total = generator.total;
      });
    }
  }

  void startProgress() {
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

  void resetProgress() {
    stopProgress();
    startProgress();
  }

  void stopProgress() {
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
        }
      }
    });
  }

  void _handleTimeOver() {
    if (mounted) {
      setState(() {
        _isButtonDisabled = true;
        stopProgress();
        if (_record > currentRecord) {
          globalRecord = _record;
          updateRecordDatabase(_record);
        }
        alertDialog.showCustomModalBottomSheet(
          context,
          outputText: GameOutputTexts.personalBest,
          record: globalRecord,
          gameMsg: GameOutputTexts.timeOverMsg,
        );
      });
    }
  }

  void _handleNewHighScore() {
    if (mounted) {
      setState(() {
        _levelCounter++;
        if (_levelCounter > _levelUpAt &&
            _levelIndex <= 5 &&
            widget.levelType != practiceLevel) {
          _selectedGameRecord.gameData[levelListKeys.elementAt(_levelIndex)] =
              true;
          _levelUp(_levelIndex);
        }
        _getRandom();
        _record++;
        resetProgress();
      });
    }
  }

  void _handleNotHighScore() {
    if (mounted) {
      setState(() {
        _isButtonDisabled = true;
        stopProgress();
        if (_record > currentRecord) {
          globalRecord = _record;
          updateRecordDatabase(_record);
        }
        alertDialog.showCustomModalBottomSheet(
          context,
          outputText: GameOutputTexts.personalBest,
          record: globalRecord,
          gameMsg: GameOutputTexts.answerWrongMsg,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateRecordDatabase(int currentRecord) async {
    if (widget.levelType != practiceLevel) {
      _selectedGameRecord.record = currentRecord.toString();
      Map<String, GameRecord>? data = _streamUserRecord.gameRecord;
      data?.update(_gameType, (update) => _selectedGameRecord);
      await _service.updateUserRecord(data!);
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
            SizedBox(height: 75),
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
                            Icon(Icons.add),
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
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          if (_progressValue >= 1.0) {
                            _handleTimeOver();
                          } else {
                            if (_firstValue + _secondValue != _total) {
                              _handleNewHighScore();
                            } else {
                              _handleNotHighScore();
                            }
                          }
                        },
                  icon: Icon(Icons.close, size: 60),
                ),
                SizedBox(width: 60),
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          if (_progressValue >= 1.0) {
                            _handleTimeOver();
                          } else {
                            if (_firstValue + _secondValue == _total) {
                              _handleNewHighScore();
                            } else {
                              _handleNotHighScore();
                            }
                          }
                        },
                  icon: Icon(Icons.check_circle, size: 60),
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
            currentRecord >= _record
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
                        "$currentRecord",
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
          ],
        ),
      ),
    );
  }
}
