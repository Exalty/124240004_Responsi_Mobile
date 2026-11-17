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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Library Anda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: Color(0xFF52525B)),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada game di library',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF71717A),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final game = favoriteGames[index];
              final genre = game.genres.isNotEmpty ? game.genres.first : 'Game';
              final platform = game.platform ?? 'Windows';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF27272A), width: 0.8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(showId: game.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: game.imageUrl != null && game.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: game.imageUrl!,
                                    width: 75,
                                    height: 55,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 75,
                                      height: 55,
                                      color: const Color(0xFF27272A),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 75,
                                      height: 55,
                                      color: const Color(0xFF27272A),
                                      child: const Icon(Icons.broken_image, size: 24, color: Color(0xFF71717A)),
                                    ),
                                  )
                                : Container(
                                    width: 75,
                                    height: 55,
                                    color: const Color(0xFF27272A),
                                    child: const Icon(Icons.sports_esports, size: 24, color: Color(0xFF71717A)),
                                  ),
                          ),
                          const SizedBox(width: 14),

                          // Name, Genre, Platform
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  game.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF27272A),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    genre,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD4D4D8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  platform,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF71717A),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete button (merah)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 22),
                            onPressed: () {
                              box.delete(game.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${game.name} dihapus dari Library'),
                                  backgroundColor: const Color(0xFFEF4444),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
