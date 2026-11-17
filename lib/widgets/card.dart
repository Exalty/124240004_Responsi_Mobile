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

    return Card(
      elevation: 3,
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF334155), width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x336366F1),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Game Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: show.imageUrl != null && show.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: show.imageUrl!,
                        width: 100,
                        height: 75,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 100,
                          height: 75,
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 100,
                          height: 75,
                          color: const Color(0xFF334155),
                          child: const Icon(Icons.broken_image, size: 30, color: Color(0xFF94A3B8)),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 75,
                        color: const Color(0xFF334155),
                        child: const Icon(Icons.sports_esports, size: 30, color: Color(0xFF94A3B8)),
                      ),
              ),
              const SizedBox(width: 12),
              // Game Info
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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFF1F5F9),
                      ),
                    ),
                    if (show.short_description != null && show.short_description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        show.short_description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x336366F1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0x666366F1), width: 0.8),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA5B4FC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (show.platform != null) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              show.platform!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
