class LottoResult {
  final String timestamp;
  final String date;
  final String game;
  final String draw;
  final List<String> ballNumbers;
  final String? jackpot;
  final String? winners;

  LottoResult({
    required this.timestamp,
    required this.date,
    required this.game,
    required this.draw,
    required this.ballNumbers,
    this.jackpot,
    this.winners,
  });

  factory LottoResult.fromJson(Map<String, dynamic> json) {
    return LottoResult(
      timestamp: json['timestamp'] ?? '',
      date: json['date'] ?? '',
      game: json['game'] ?? '',
      draw: json['draw'] ?? '',
      ballNumbers: List<String>.from(json['ballNumbers'] ?? []),
      jackpot: json['jackpot'],
      winners: json['winners'],
    );
  }

  String get formattedNumbers => ballNumbers.join('-');

  List<String> get lastThreeNumbers {
    if (ballNumbers.length >= 3) {
      return ballNumbers.sublist(ballNumbers.length - 3);
    }
    return ballNumbers;
  }

  bool checkPick3Win(String betNumbers) {
    final betNums = betNumbers.split('-').map((e) => e.trim()).toSet();
    final resultNums = lastThreeNumbers.toSet();
    return betNums.length == 3 && 
           resultNums.length == 3 && 
           betNums.difference(resultNums).isEmpty;
  }

  bool check2DWin(String betNumbers, bool isRamble) {
    final betNums = betNumbers.split('-').map((e) => e.trim()).toList();
    if (ballNumbers.length < 2) return false;
    
    if (isRamble) {
      return betNums.toSet().difference(ballNumbers.take(2).toSet()).isEmpty;
    } else {
      return betNums[0] == ballNumbers[0] && betNums[1] == ballNumbers[1];
    }
  }

  bool check3DWin(String betNumbers, bool isRamble) {
    final betNums = betNumbers.split('-').map((e) => e.trim()).toList();
    if (ballNumbers.length < 3) return false;
    
    if (isRamble) {
      return betNums.toSet().difference(ballNumbers.take(3).toSet()).isEmpty;
    } else {
      return betNums[0] == ballNumbers[0] && 
             betNums[1] == ballNumbers[1] && 
             betNums[2] == ballNumbers[2];
    }
  }
}
