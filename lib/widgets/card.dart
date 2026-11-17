import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/game.dart';

class ShowCard extends StatelessWidget {
  final Game show;
  final VoidCallback onTap;

  const ShowCard({
    super.key,
    required this.show,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final genre = show.genres.isNotEmpty ? show.genres.first : 'Game';
    final platform = show.platform ?? 'PC (Windows)';

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: show.imageUrl != null && show.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: show.imageUrl!,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 60,
                            color: const Color(0xFF27272A),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 60,
                            color: const Color(0xFF27272A),
                            child: const Icon(Icons.broken_image, size: 28, color: Color(0xFF71717A)),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 60,
                          color: const Color(0xFF27272A),
                          child: const Icon(Icons.sports_esports, size: 28, color: Color(0xFF71717A)),
                        ),
                ),
                const SizedBox(width: 14),

                // Info: Name, Genre, Platform
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        show.name,
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

                // Trailing Chevron
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF71717A),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
