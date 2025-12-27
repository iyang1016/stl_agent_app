import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lotto_result.dart';

class PcsoApiService {
  static const String baseUrl = 'https://pcso-lotto-api.vercel.app/api';

  Future<List<LottoResult>> getLiveResults() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/live-lotto-results'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LottoResult.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<LottoResult>> getDailyResults({String? date, String? game, String? drawTime}) async {
    try {
      String url = '$baseUrl/daily-lotto-results';
      
      final parts = <String>[];
      if (date != null) parts.add(date);
      if (game != null) parts.add(game);
      if (drawTime != null) parts.add(drawTime);
      
      if (parts.isNotEmpty) {
        url = '$url/${parts.join('/')}';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LottoResult.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<LottoResult?> get2DResult(String drawTime) async {
    final results = await getDailyResults(game: '2D-Lotto', drawTime: drawTime);
    return results.isNotEmpty ? results.first : null;
  }

  Future<LottoResult?> get3DResult(String drawTime) async {
    final results = await getDailyResults(game: '3D-Lotto', drawTime: drawTime);
    return results.isNotEmpty ? results.first : null;
  }

  Future<LottoResult?> getPick3SourceResult() async {
    final now = DateTime.now();
    String game;
    
    switch (now.weekday) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.friday:
        game = 'Mega-Lotto-6-45';
        break;
      case DateTime.tuesday:
      case DateTime.thursday:
      case DateTime.sunday:
        game = 'Super-Lotto-6-49';
        break;
      case DateTime.saturday:
        game = 'Grand-Lotto-6-55';
        break;
      default:
        game = 'Mega-Lotto-6-45';
    }

    final results = await getDailyResults(game: game, drawTime: '9PM');
    return results.isNotEmpty ? results.first : null;
  }

  String getPick3GameLabel() {
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
}
