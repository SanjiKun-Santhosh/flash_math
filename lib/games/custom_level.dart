import 'package:flash_math/games/substraction.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'addition.dart';
import 'complex.dart';

class CustomLevel extends StatefulWidget {
  final String gameType;

  const CustomLevel({super.key, required this.gameType});

  @override
  State<CustomLevel> createState() => _CustomLevelState();
}

class _CustomLevelState extends State<CustomLevel> {
  double _timerSlide = 1;
  int _timer = 0;
  int _min = 0;
  int _max = 100;
  final _formKey = GlobalKey<FormState>();

  Widget _selectGameWidget() {
    switch (widget.gameType) {
      case "Addition":
        return Addition(
          levelType: customLevel,
          min: _min,
          max: _max,
          timerSetting: _timer,
        );
      case "Substraction":
        return Substraction(
          levelType: customLevel,
          min: _min,
          max: _max,
          timerSetting: _timer,
        );
      case "Complex":
        return Complex(
          levelType: customLevel,
          min: _min,
          max: _max,
          timerSetting: _timer,
        );
      default:
        return const Scaffold(
          body: Center(child: Text("Error: Unknown Game Type")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[100],
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
                value: _timerSlide,
                activeColor: Colors.red[_timerSlide.round() * 100],
                inactiveColor: Colors.brown[_timerSlide.round() * 100],
                onChanged: (val) {
                  setState(() {
                    _timerSlide = val;
                    _timer = (val).round() * 10;
                  });
                },
                min: 1,
                max: 10,
                divisions: 10,
              ),
              Text(
                "${_timerSlide.round().toString()} seconds",
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
                  hintText: "Lowest number",
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
                  hintText: "Highest number",
                ),
                style: TextStyle(fontSize: 25),
                onChanged: (val) {
                  setState(() {
                    _max = int.parse(val);
                  });
                },
              ),
              SizedBox(height: 60),
              (_max < _min)
                  ? Text(
                      "Highest number be greater than lowest number!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext e) => _selectGameWidget(),
                          ),
                        );
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
