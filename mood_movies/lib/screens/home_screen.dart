import 'package:flutter/cupertino.dart';
import '../services/tmdb_service.dart';
import 'movie_list_screen.dart';
import 'search_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> moods = [
      {
        'name': 'Mutlu',
        'icon': const Icon(CupertinoIcons.smiley_fill, size: 32, color: CupertinoColors.white),
        'description': 'Komedi ve aile filmleri',
      },
      {
        'name': 'Üzgün',
        'icon': const Icon(CupertinoIcons.heart_slash_fill, size: 32, color: CupertinoColors.white),
        'description': 'Drama ve romantik filmler',
      },
      {
        'name': 'Heyecanlı',
        'icon': const Icon(CupertinoIcons.star_fill, size: 32, color: CupertinoColors.white),
        'description': 'Aksiyon ve macera filmleri',
      },
      {
        'name': 'Sakin',
        'icon': const Icon(CupertinoIcons.moon_fill, size: 32, color: CupertinoColors.white),
        'description': 'Animasyon ve fantastik filmler',
      },
      {
        'name': 'Düşünceli',
        'icon': const Icon(CupertinoIcons.lightbulb_fill, size: 32, color: CupertinoColors.white),
        'description': 'Belgesel ve tarih filmleri',
      },
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mood Movies'),
        trailing: SearchButton(),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CupertinoButton(
                color: CupertinoColors.systemIndigo,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MovieListScreen(
                        mood: moods[index]['name'],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        moods[index]['icon'],
                        const SizedBox(width: 12),
                        Text(
                          moods[index]['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      moods[index]['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
