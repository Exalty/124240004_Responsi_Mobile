import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsi/models/game.dart';

class ApiService {
  static const String _baseUrl = 'https://www.freetogame.com/api';

  /// Fetch list of all games from FreeToGame API
  static Future<List<Game>> fetchGames() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/games'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => Game.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat games (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data: $e');
    }
  }

  /// Fetch detail of a single game by ID
  static Future<Game> fetchGameDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/game?id=$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Game.fromJson(jsonData);
      } else {
        throw Exception('Gagal memuat detail game (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error saat mengambil detail game: $e');
    }
  }

  // Alias methods to preserve compatibility with existing calls
  static Future<List<Game>> fetchShows() => fetchGames();
  static Future<Game> fetchShowDetail(int id) => fetchGameDetail(id);
}
