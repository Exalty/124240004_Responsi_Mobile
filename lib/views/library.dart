import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/game.dart';
import 'detail.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box favoritesBox = Hive.box('favorites');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Favorit'),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Color(0xFF475569)),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada game favorit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final favoriteGames = box.values.toList().cast<Game>();

          return ListView.builder(
            itemCount: favoriteGames.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final game = favoriteGames[index];

              return Card(
                elevation: 3,
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF334155), width: 0.8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: game.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: game.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFF0F172A),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFF334155),
                              child: const Icon(Icons.sports_esports, size: 24, color: Color(0xFF94A3B8)),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFF334155),
                            child: const Icon(Icons.sports_esports, size: 24, color: Color(0xFF94A3B8)),
                          ),
                  ),
                  title: Text(
                    game.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF1F5F9)),
                  ),
                  subtitle: Text(
                    game.genres.isNotEmpty ? game.genres.first : (game.platform ?? 'Free-to-Play'),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFF43F5E)),
                    onPressed: () {
                      box.delete(game.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${game.name} dihapus dari favorit'),
                          backgroundColor: const Color(0xFFEF4444),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(showId: game.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
