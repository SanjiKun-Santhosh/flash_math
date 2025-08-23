import 'dart:async';

import 'package:flash_math/addition_algorithm/number_generator.dart';
import 'package:flash_math/services/database.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

import '../models/user_record.dart';
import 'game_support/modalBottomSheet.dart';

class Addition extends StatefulWidget {
  final UserRecord? userRecord;

  const Addition({super.key, required this.userRecord});

  @override
  State<Addition> createState() => _AdditionState();
}

class _AdditionState extends State<Addition> {
  int _firstValue = 0;
  int _secondValue = 0;
  int _total = 0;
  int _record = 0;
  double _progressValue = 0.0;
  Timer? _timer;
  bool _isButtonDisabled = false;
  final String gameType = GameTypes.addition.name;
  int globalRecord = 0;
  ModalBottomSheet alertDialog = ModalBottomSheet();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _getRandom();
      });
    });
    startProgress();
  }

  void _getRandom() async {
    final generator = NumberGenerator(randomMin: 0, randomMax: 100);
    await generator.random();
    await generator.randomAddTotal();
    _firstValue = generator.firstValue;
    _secondValue = generator.secondValue;
    _total = generator.total;
  }

  void startProgress() {
    const oneHundredthOfASecond = Duration(milliseconds: 30);
    _timer = Timer.periodic(oneHundredthOfASecond, (timer) {
      if (_progressValue >= 1.0) {
        timer.cancel();
        alertDialog.showCustomModalBottomSheet(context,outputText: 'Your personal record is $globalRecord',gameMsg: "The Time is over!");
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
    Map<String, String>? gameRecord = widget.userRecord?.gameRecord;
    int currentRecord = globalRecord= int.parse(gameRecord?[gameType] ?? "0");
    print(currentRecord);
    final DatabaseService service = DatabaseService(
      uid: widget.userRecord!.uid,
    );

    return Scaffold(
      appBar: AppBar(
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
                                globalRecord=_record;
                                updateRecordDatabase(
                                  _record,
                                  service,
                                  gameRecord!,
                                );
                              }
                              alertDialog.showCustomModalBottomSheet(context,outputText: 'Your personal record is $globalRecord',gameMsg: "The Time is over!");

                            } else {
                              if (_firstValue + _secondValue != _total) {
                                _getRandom();
                                _record++;
                                resetProgress();
                              } else {
                                _isButtonDisabled = true;
                                stopProgress();
                                if (_record > currentRecord) {
                                  globalRecord=_record;
                                  updateRecordDatabase(
                                    _record,
                                    service,
                                    gameRecord!,
                                  );
                                }
                                alertDialog.showCustomModalBottomSheet(context,outputText: 'Your personal record is $globalRecord',gameMsg: "The Answer is wrong!");

                              }
                            }
                          });
                        },
                  icon: Icon(Icons.close, size: 50),
                ),
                SizedBox(width: 30),
                IconButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          setState(() {
                            if (_progressValue >= 1.0) {
                              _isButtonDisabled = true;
                              dispose();
                              if (_record > currentRecord) {
                                globalRecord=_record;
                                updateRecordDatabase(
                                  _record,
                                  service,
                                  gameRecord!,
                                );
                              }
                              alertDialog.showCustomModalBottomSheet(context,outputText: 'Your personal best is $globalRecord',gameMsg: "The Time is over!");

                            } else {
                              if (_firstValue + _secondValue == _total) {
                                _getRandom();
                                _record++;
                                resetProgress();
                              } else {
                                _isButtonDisabled = true;
                                stopProgress();
                                if(_record>currentRecord) {
                                  globalRecord = _record;
                                  updateRecordDatabase(
                                    _record,
                                    service,
                                    gameRecord!,
                                  );
                                }
                                alertDialog.showCustomModalBottomSheet(context,outputText: 'Your personal best is $globalRecord',gameMsg: "The Answer is wrong!");

                              }
                            }
                          });
                        },
                  icon: Icon(Icons.check_circle, size: 50),
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
                ? Text(
                    "Your personal best is $currentRecord",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    "Congratulations!! You new best is $_record",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
