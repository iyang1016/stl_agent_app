import 'package:hive/hive.dart';

part 'bet.g.dart';

@HiveType(typeId: 0)
enum GameType {
  @HiveField(0)
  twoD,
  @HiveField(1)
  threeD,
  @HiveField(2)
  pick3,
}

@HiveType(typeId: 1)
enum BetType {
  @HiveField(0)
  straight,
  @HiveField(1)
  ramble,
}

@HiveType(typeId: 2)
class Bet extends HiveObject {
  @HiveField(0)
  String bettorName;

  @HiveField(1)
  GameType gameType;

  @HiveField(2)
  BetType betType;

  @HiveField(3)
  String numbers;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String drawTime;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isWinner;

  Bet({
    required this.bettorName,
    required this.gameType,
    required this.betType,
    required this.numbers,
    required this.amount,
    required this.drawTime,
    required this.createdAt,
    this.isWinner = false,
  });

  String get gameTypeLabel {
    switch (gameType) {
      case GameType.twoD:
        return '2D';
      case GameType.threeD:
        return '3D';
      case GameType.pick3:
        return getPick3SourceGame();
    }
  }

  String get betTypeLabel {
    if (gameType == GameType.pick3) return '';
    return betType == BetType.ramble ? 'R' : 'S';
  }

  String getPick3SourceGame() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.friday:
        return '6/45';
      case DateTime.tuesday:
      case DateTime.thursday:
      case DateTime.sunday:
        return '6/49';
      case DateTime.saturday:
        return '6/55';
      default:
        return '6/45';
    }
  }

  String toFormattedString() {
    final suffix = betTypeLabel.isNotEmpty ? ' $betTypeLabel' : '';
    return '   - $gameTypeLabel: $numbers$suffix';
  }
}
