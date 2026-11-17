import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final int showId;

  const DetailPage({super.key, required this.showId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Game> _gameDetailFuture;
  late Box _favoritesBox;

  @override
  void initState() {
    super.initState();
    _gameDetailFuture = ApiService.fetchGameDetail(widget.showId);
    _favoritesBox = Hive.box('favorites');
  }

  // Remove HTML tags or whitespace
  String _cleanSummary(String? rawSummary) {
    if (rawSummary == null || rawSummary.trim().isEmpty) {
      return 'Tidak ada deskripsi tersedia.';
    }
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return rawSummary.replaceAll(exp, '').trim();
  }

  bool _isFavorite(int id) {
    return _favoritesBox.containsKey(id);
  }

  void _toggleFavorite(Game game) {
    setState(() {
      if (_isFavorite(game.id)) {
        _favoritesBox.delete(game.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari Favorit'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        _favoritesBox.put(game.id, game);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke Favorit'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showReminderDialog(Game game) {
    int selectedSeconds = 10;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Row(
                children: [
                  Icon(Icons.alarm_add_rounded, color: Color(0xFF6366F1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pasang Pengingat Game',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingatkan saya untuk bermain "${game.name}" dalam:',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('10 Detik'),
                        selected: selectedSeconds == 10,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 10),
                      ),
                      ChoiceChip(
                        label: const Text('1 Menit'),
                        selected: selectedSeconds == 60,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 60),
                      ),
                      ChoiceChip(
                        label: const Text('5 Menit'),
                        selected: selectedSeconds == 300,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 300),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pengingat berhasil dipasang untuk $selectedSeconds detik lagi!',
                        ),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                    );
                  },
                  label: const Text('Set Pengingat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Game'),
      ),
      body: FutureBuilder<Game>(
        future: _gameDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _gameDetailFuture = ApiService.fetchGameDetail(widget.showId);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Data game tidak ditemukan',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            );
          }

          final game = snapshot.data!;
          final isFav = _isFavorite(game.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Game Banner / Image
                if (game.imageUrl != null && game.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: game.imageUrl!,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: const Color(0xFF1E293B),
                      child: const Icon(Icons.broken_image, size: 64, color: Color(0xFF94A3B8)),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.sports_esports, size: 64, color: Color(0xFF94A3B8)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Favorite button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              game.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                              size: 30,
                            ),
                            onPressed: () => _toggleFavorite(game),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Platform info & Reminder Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.devices, color: Color(0xFF818CF8), size: 20),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    game.platform ?? 'PC / All Platforms',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF818CF8),
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.alarm_add_rounded, size: 18),
                            label: const Text('Ingatkan'),
                            onPressed: () => _showReminderDialog(game),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Metadata Info Box (Publisher, Developer, Release Date)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155), width: 0.8),
                        ),
                        child: Column(
                          children: [
                            if (game.publisher != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Publisher', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                                    Text(game.publisher!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            if (game.developer != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Developer', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                                    Text(game.developer!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            if (game.releaseDate != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Release Date', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                                    Text(game.releaseDate!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Genres
                      if (game.genres.isNotEmpty) ...[
                        const Text(
                          'Genre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: game.genres.map((genre) {
                            return Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(color: Color(0xFFE0E7FF), fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: const Color(0xFF312E81),
                              side: const BorderSide(color: Color(0xFF4338CA)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description
                      const Text(
                        'Deskripsi Game',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cleanSummary(game.description ?? game.short_description),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
