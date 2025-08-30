import 'dart:async';

import 'package:flash_math/game_algorithm/number_generator.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_record.dart';
import '../screens/custom_sheets.dart';

class AdditionWork extends StatefulWidget {
  final String levelType;
  final int min;
  final int max;
  final int timerSetting;

  const AdditionWork({
    super.key,
    required this.levelType,
    this.timerSetting = defaultTimerSetting,
    this.min = minimumForRandomGen,
    this.max = maximumForRandomGen,
  });

  @override
  State<AdditionWork> createState() => _AdditionWorkState();
}

class _AdditionWorkState extends State<AdditionWork> {
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
  final String gameType = GameTypes.addition.name;
  int globalRecord = 0;
  CustomSheets alertDialog = CustomSheets();

  @override
  void initState() {
    super.initState();
    if (widget.levelType == customLevel) {
      _timerSpeed = widget.timerSetting;
      _levelIndex=0;
    } else {
      _timerSpeed = int.parse(levelList[widget.levelType]!);
      _levelIndex = levelListKeys.indexOf(widget.levelType)+1;
    }
    _levelUpAt = defaultLevelUpAt;
    _min = widget.min;
    _max = widget.max;
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _getRandom();
      });
    });
    startProgress();
  }

  void _getRandom() async {
    final generator = NumberGenerator(randomMin: _min, randomMax: _max);
    await generator.random();
    await generator.randomAddTotal();
    _firstValue = generator.firstValue;
    _secondValue = generator.secondValue;
    _total = generator.total;
  }

  void startProgress() {
    final oneHundredthOfASecond = Duration(milliseconds: _timerSpeed);
    _timer = Timer.periodic(oneHundredthOfASecond, (timer) {
      if (_progressValue >= 1.0) {
        timer.cancel();
        alertDialog.showCustomModalBottomSheet(
          context,
          outputText: GameOutputTexts.personalBest,
          record: globalRecord,
          gameMsg: GameOutputTexts.timeOverMsg,
        );
      } else {
        setState(() {
          _progressValue += 0.01;
        });
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
      if(widget.levelType!=customLevel){
        _timerSpeed = int.parse(levelList[levelListKeys[_levelIndex-1]]!);
        _levelIndex++;
        _levelCounter = 0;
      }

    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateRecordDatabase(
    int currentRecord,
    DatabaseService service,
    Map<String, String> gameRecord,
  ) async {
    gameRecord.update(gameType, (record) => currentRecord.toString());
    await service.updateUserRecord(gameRecord);
  }

  ///use provider instead of assigning Database Service.
  @override
  Widget build(BuildContext context) {
    final userRecord = context.watch<UserRecord?>();
    Map<String, String>? gameRecord = userRecord?.gameRecord;
    int currentRecord = globalRecord = int.parse(gameRecord?[gameType] ?? "0");
    final DatabaseService service = DatabaseService(uid: userRecord!.uid);
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
                          setState(() {
                            if (_progressValue >= 1.0) {
                              _isButtonDisabled = true;
                              dispose();
                              if (_record > currentRecord) {
                                globalRecord = _record;
                                updateRecordDatabase(
                                  _record,
                                  service,
                                  gameRecord!,
                                );
                              }
                              alertDialog.showCustomModalBottomSheet(
                                context,
                                outputText: GameOutputTexts.personalBest,
                                record: globalRecord,
                                gameMsg: GameOutputTexts.timeOverMsg,
                              );
                            } else {
                              if (_firstValue + _secondValue != _total) {
                                _levelCounter++;
                                if (_levelCounter > _levelUpAt &&
                                    _levelIndex <= 5) {
                                  _levelUp(_levelIndex);
                                }
                                _getRandom();
                                _record++;
                                resetProgress();
                              } else {
                                _isButtonDisabled = true;
                                stopProgress();
                                if (_record > currentRecord) {
                                  globalRecord = _record;
                                  updateRecordDatabase(
                                    _record,
                                    service,
                                    gameRecord!,
                                  );
                                }
                                alertDialog.showCustomModalBottomSheet(
                                  context,
                                  outputText: GameOutputTexts.personalBest,
                                  record: globalRecord,
                                  gameMsg: GameOutputTexts.answerWrongMsg,
                                );
                              }
                            }
                          });
                        },
                  icon: Icon(Icons.close, size: 60),
                ),
                SizedBox(width: 60),
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          setState(() {
                            if (_progressValue >= 1.0) {
                              _isButtonDisabled = true;
                              dispose();
                              if (_record > currentRecord) {
                                globalRecord = _record;
                                updateRecordDatabase(
                                  _record,
                                  service,
                                  gameRecord!,
                                );
                              }
                              alertDialog.showCustomModalBottomSheet(
                                context,
                                outputText: GameOutputTexts.personalBest,
                                record: globalRecord,
                                gameMsg: GameOutputTexts.timeOverMsg,
                              );
                            } else {
                              if (_firstValue + _secondValue == _total) {
                                _levelCounter++;
                                print(_levelCounter);
                                if (_levelCounter > _levelUpAt &&
                                    _levelIndex <= 5) {
                                  _levelUp(_levelIndex);
                                }
                                _getRandom();
                                _record++;
                                resetProgress();
                              } else {
                                _isButtonDisabled = true;
                                stopProgress();
                                if (_record > currentRecord) {
                                  globalRecord = _record;
                                  updateRecordDatabase(
                                    _record,
                                    service,
                                    gameRecord!,
                                  );
                                }
                                alertDialog.showCustomModalBottomSheet(
                                  context,
                                  outputText: GameOutputTexts.personalBest,
                                  record: globalRecord,
                                  gameMsg: GameOutputTexts.answerWrongMsg,
                                );
                              }
                            }
                          });
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
