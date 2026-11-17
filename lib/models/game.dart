import 'package:hive/hive.dart';

class Game {
  final int id;
  final String name;
  final String? imageUrl;
  final List<String> genres;
  final String? short_description;

  Game({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.genres,
    this.short_description,
  });

  /// Parse from TVMaze API JSON response
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image'] != null ? json['image']['medium'] : null,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      short_description: json['short_description'],
    );
  }

  /// Convert to Map (for Hive storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'genres': genres,
      'short_description': short_description,
    };
  }

  /// Create from Map (from Hive storage)
  factory Game.fromMap(Map<dynamic, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      genres: List<String>.from(map['genres'] ?? []),
      short_description: map['short_description'],
    );
  }
}

/// Hive TypeAdapter for storing Game in local database
class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 0;

  @override
  Game read(BinaryReader reader) {
    final map = reader.readMap();
    return Game.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.writeMap(obj.toMap());
  }
}