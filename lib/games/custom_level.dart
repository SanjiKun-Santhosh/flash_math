import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';

import 'addition_work.dart';

class CustomLevel extends StatefulWidget {
  final String customLevel;

  const CustomLevel({super.key, required this.customLevel});

  @override
  State<CustomLevel> createState() => _CustomLevelState();
}

class _CustomLevelState extends State<CustomLevel> {
  double _valueSlide = 1;
  int _timer = 0;
  int _min = 0;
  int _max = 100;
  bool _boxChecked = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Template(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[200],
          ),
          padding: EdgeInsets.all(25),
          margin: EdgeInsets.all(15),
          child: Column(
            key: _formKey,
            children: [
              Text(
                "Answer timer",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontFamily: CustomFontStyle().primaryFont,
                ),
              ),
              SizedBox(height: 30),
              Slider(
                value: _valueSlide,
                activeColor: Colors.red[_valueSlide.round() * 100],
                inactiveColor: Colors.brown[_valueSlide.round() * 100],
                onChanged: (val) {
                  setState(() {
                    _valueSlide = val;
                    _timer = (val).round() * 10;
                  });
                },
                min: 1,
                max: 10,
                divisions: 10,
              ),
              Text(
                "${_valueSlide.round().toString()} seconds",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  fontFamily: CustomFontStyle().primaryFont,
                ),
              ),
              SizedBox(height: 60),
              TextField(
                textAlign: TextAlign.center,
                decoration: AppDecoration().textDecoration.copyWith(
                  hintText: "Enter min X value",
                ),
                style: TextStyle(fontSize: 25),
                onChanged: (val) {
                  setState(() {
                    _min = int.parse(val);
                  });
                },
              ),
              SizedBox(height: 60),
              TextField(
                textAlign: TextAlign.center,
                decoration: AppDecoration().textDecoration.copyWith(
                  hintText: "Enter max Y value",
                ),
                style: TextStyle(fontSize: 25),
                onChanged: (val) {
                  setState(() {
                    _max = int.parse(val);
                  });
                },
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Do you want to play infinite time?",
                    style: TextStyle(fontSize: 15),
                  ),
                  Checkbox(
                    value: _boxChecked,
                    onChanged: (val) {
                      setState(() {
                        _boxChecked = !_boxChecked;
                        if (_boxChecked) {}
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(height: 30),

              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext e) => AdditionWork(
                          levelType: widget.customLevel,
                          min: _min,
                          max: _max,
                          timerSetting: _timer,
                        ),
                      ),
                    );
                  });
                },
                label: Text("Play"),
                icon: Icon(Icons.games),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
