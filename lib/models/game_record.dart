class GameRecord{
  final String gameType;
  final int ranking;
  final int record;
  final Map<String, bool> gameData;
  GameRecord({required this.ranking, required this.record, required this.gameType, required this.gameData});
}