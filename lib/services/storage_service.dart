import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bet.dart';

class StorageService extends ChangeNotifier {
  static const String betsBoxName = 'bets';
  static const String settingsBoxName = 'settings';
  static const double commissionRate = 0.42;

  Box<Bet> get _betsBox => Hive.box<Bet>(betsBoxName);
  Box get _settingsBox => Hive.box(settingsBoxName);

  String get agentName => _settingsBox.get('agentName', defaultValue: 'AGENT');

  set agentName(String value) {
    _settingsBox.put('agentName', value);
    notifyListeners();
  }

  List<Bet> get allBets => _betsBox.values.toList();

  List<Bet> getTodaysBets() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allBets.where((bet) {
      final betDate = DateTime(bet.createdAt.year, bet.createdAt.month, bet.createdAt.day);
      return betDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<Bet> getBetsByDrawTime(String drawTime) {
    return getTodaysBets().where((bet) => bet.drawTime == drawTime).toList();
  }

  double get totalAmount => getTodaysBets().fold(0.0, (sum, bet) => sum + bet.amount);

  double get commission => totalAmount * commissionRate;

  double get remitAmount => totalAmount - commission;

  Future<void> addBet(Bet bet) async {
    await _betsBox.add(bet);
    notifyListeners();
  }

  Future<void> deleteBet(Bet bet) async {
    await bet.delete();
    notifyListeners();
  }

  Future<void> clearTodaysBets() async {
    final todaysBets = getTodaysBets();
    for (final bet in todaysBets) {
      await bet.delete();
    }
    notifyListeners();
  }

  String generateFormattedBetList(String drawTime) {
    final bets = getBetsByDrawTime(drawTime);
    if (bets.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln(agentName);
    buffer.writeln('📋 BETS - $drawTime');
    
    for (final bet in bets) {
      buffer.writeln(bet.toFormattedString());
    }
    
    buffer.writeln('─────────────');
    return buffer.toString();
  }
}
