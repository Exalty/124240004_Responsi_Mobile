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

  bool _isOwned(int id) {
    return _favoritesBox.containsKey(id);
  }

  void _toggleGetGame(Game game) {
    setState(() {
      if (_isOwned(game.id)) {
        // Hapus dari library
        _favoritesBox.delete(game.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${game.name} dihapus dari Library'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Tambahkan ke library
        _favoritesBox.put(game.id, game);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${game.name} berhasil ditambahkan ke Library!'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  String _cleanText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Tidak ada deskripsi tersedia.';
    }
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return text.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Game>(
        future: _gameDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat detail game:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
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
                        backgroundColor: const Color(0xFF2563EB),
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
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            );
          }

          final game = snapshot.data!;
          final bool owned = _isOwned(game.id);
          final genre = game.genres.isNotEmpty ? game.genres.first : 'Game';
          final platform = game.platform ?? 'Windows';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Image (Thumbnail paling atas & besar)
                if (game.imageUrl != null && game.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: game.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 220,
                      color: const Color(0xFF18181B),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: const Color(0xFF18181B),
                      child: const Icon(Icons.broken_image, size: 50, color: Color(0xFF71717A)),
                    ),
                  )
                else
                  Container(
                    height: 220,
                    color: const Color(0xFF18181B),
                    child: const Icon(Icons.sports_esports, size: 50, color: Color(0xFF71717A)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Genre & Platform Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27272A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE4E4E7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27272A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              platform,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE4E4E7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. Nama Game
                      Text(
                        game.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Tanggal Rilis, Publisher & Developer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Release Date',
                                  style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  game.releaseDate ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Publisher',
                                  style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  game.publisher ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Developer',
                                  style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  game.developer ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 5. Button untuk user mendapatkan game (UI berbeda)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleGetGame(game),
                          icon: Icon(
                            owned ? Icons.check : Icons.add,
                            size: 18,
                            color: owned ? const Color(0xFFD4D4D8) : Colors.white,
                          ),
                          label: Text(
                            owned ? 'In Library' : 'Get',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: owned ? const Color(0xFFD4D4D8) : Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: owned ? const Color(0xFF27272A) : const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Screenshots
                      if (game.screenshots.isNotEmpty) ...[
                        const Text(
                          'Screenshots',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: game.screenshots.length,
                            itemBuilder: (context, index) {
                              final img = game.screenshots[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: img,
                                    width: 160,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 160,
                                      height: 100,
                                      color: const Color(0xFF18181B),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 160,
                                      height: 100,
                                      color: const Color(0xFF18181B),
                                      child: const Icon(Icons.broken_image, color: Color(0xFF71717A)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 7. Deskripsi Game (Overview)
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _cleanText(game.description ?? game.short_description),
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Color(0xFFA1A1AA),
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
