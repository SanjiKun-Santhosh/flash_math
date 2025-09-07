import 'package:flash_math/models/game_record.dart';
import 'package:flutter/material.dart';
class RecordBottomSheet{
  void showCustomModalBottomSheet(BuildContext context, {required Map<String, GameRecord> gameRecord}) {
    showModalBottomSheet(
      elevation: 2.0,
      isDismissible: false,
      context: context,
      builder: (BuildContext bottomSheetContext) {
        if(gameRecord.isEmpty){
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text("No records to display!"),
            ),
          );
        }
        return Container(
          height: 700,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding:EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: gameRecord.entries.map((entry){
                return Column(
                  children: [
                    SizedBox(height: 25,),
                    Card(
                      elevation: 2.0,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${entry.key}: ",style: TextStyle(
                            fontSize: 30,
                          ),),
                          Text(entry.value.record,style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.normal,

                          )),

                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                  ],
                );
              }).toList()
            ),
          ),
        );
      },
    );
  }
}