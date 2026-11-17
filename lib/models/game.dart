import 'package:hive/hive.dart';

class Game {
  final int id;
  final String name; // mapped from 'title' or 'name'
  final String? imageUrl; // mapped from 'thumbnail' or 'image'
  final List<String> genres; // mapped from 'genre' (String) or 'genres' (List)
  final String? short_description;
  final String? description;
  final String? platform;
  final String? publisher;
  final String? developer;
  final String? releaseDate;

  Game({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.genres,
    this.short_description,
    this.description,
    this.platform,
    this.publisher,
    this.developer,
    this.releaseDate,
  });

  /// Parse from FreeToGame or TVMaze API JSON response
  factory Game.fromJson(Map<String, dynamic> json) {
    // FreeToGame uses 'genre' (String), TVMaze uses 'genres' (List)
    List<String> parsedGenres = [];
    if (json['genre'] != null && json['genre'].toString().isNotEmpty) {
      parsedGenres = [json['genre'].toString()];
    } else if (json['genres'] != null && json['genres'] is List) {
      parsedGenres = List<String>.from(json['genres']);
    }

    // FreeToGame uses 'thumbnail', TVMaze uses 'image' -> 'medium'
    String? imgUrl = json['thumbnail'];
    if (imgUrl == null && json['image'] != null && json['image'] is Map) {
      imgUrl = json['image']['medium'] ?? json['image']['original'];
    }

    return Game(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['title'] ?? json['name'] ?? 'Unknown Game',
      imageUrl: imgUrl,
      genres: parsedGenres,
      short_description: json['short_description'],
      description: json['description'] ?? json['short_description'],
      platform: json['platform'],
      publisher: json['publisher'],
      developer: json['developer'],
      releaseDate: json['release_date'],
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
      'description': description,
      'platform': platform,
      'publisher': publisher,
      'developer': developer,
      'releaseDate': releaseDate,
    };
  }

  /// Create from Map (from Hive storage)
  factory Game.fromMap(Map<dynamic, dynamic> map) {
    return Game(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? 'Unknown Game',
      imageUrl: map['imageUrl'],
      genres: List<String>.from(map['genres'] ?? []),
      short_description: map['short_description'],
      description: map['description'] ?? map['short_description'],
      platform: map['platform'],
      publisher: map['publisher'],
      developer: map['developer'],
      releaseDate: map['releaseDate'],
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
