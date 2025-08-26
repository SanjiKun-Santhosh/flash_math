import 'dart:async';

import 'package:flash_math/models/user_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_algorithm/number_generator.dart';
import '../screens/loading.dart';
import '../services/database.dart';
import '../shared/constants.dart';
import '../screens/custom_sheets.dart';

class Substraction extends StatefulWidget {
  final UserRecord? userRecord;

  const Substraction({super.key, required this.userRecord});

  @override
  State<Substraction> createState() => _SubstractionState();
}

class _SubstractionState extends State<Substraction> {
  int _firstValue = 0;
  int _secondValue = 0;
  int _total = 0;
  int _record = 1;
  double _progressValue = 0.0;
  Timer? _timer;
  bool _isButtonDisabled = false;
  final String gameType = GameTypes.substraction.name;
  int globalRecord = 0;
  CustomSheets alertDialog = CustomSheets();

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
    await generator.randomForSub();
    await generator.randomSubTotal();
    _firstValue = generator.firstValue;
    _secondValue = generator.secondValue;
    _total = generator.total;
  }

  void startProgress() {
    const oneHundredthOfASecond = Duration(milliseconds: 30);
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

  @override
  Widget build(BuildContext context) {
    final userRecord = context.watch<UserRecord?>();
    Map<String, String>? gameRecord = userRecord?.gameRecord;
    int currentRecord = globalRecord = int.parse(gameRecord?[gameType] ?? "0");
    final DatabaseService service = DatabaseService(
      uid: widget.userRecord!.uid,
    );
    if (userRecord == null) {
      return Loading();
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
      backgroundColor: Colors.greenAccent[100],
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
                            Icon(Icons.remove),
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
                              if (_firstValue - _secondValue != _total) {
                                _getRandom();
                                _record++;
                                resetProgress();
                                print("mushi");
                              } else {
                                _isButtonDisabled = true;
                                stopProgress();
                                if (_record > currentRecord) {
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
                              if (_firstValue - _secondValue == _total) {
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
