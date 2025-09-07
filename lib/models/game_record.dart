class GameRecord{
  final String gameType;
  int ranking;
  String record;
  Map<String, bool> gameData;
  GameRecord({required this.ranking, required this.record, required this.gameType, required this.gameData});

  Map<String,dynamic> toJson(){
    return {
      "gameType":gameType,
      "ranking":ranking,
      "record":record,
      "gameData":gameData
    };
  }

  factory GameRecord.fromJson(Map<String,dynamic> json){
    return GameRecord(
      gameType: json["gameType"] ?? "",
      ranking: json["ranking"] ?? 0,
      record: json["record"] ?? "0",
      gameData: Map<String, bool>.from(json["gameData"] ?? {}),
    );

  }



}