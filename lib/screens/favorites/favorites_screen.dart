import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/gem_provider.dart';
import '../../widgets/gem_card.dart';
import '../gem_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GemProvider>(context, listen: false).fetchGems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gemProvider = Provider.of<GemProvider>(context);
    final favoriteGems = gemProvider.favoriteGems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: gemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteGems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No favorites yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start adding gems to your favorites',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => gemProvider.fetchGems(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: favoriteGems.length,
                    itemBuilder: (context, index) {
                      final gem = favoriteGems[index];
                      return GemCard(
                        gem: gem,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GemDetailScreen(gem: gem),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
