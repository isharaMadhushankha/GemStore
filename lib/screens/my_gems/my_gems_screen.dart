import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/gem_provider.dart';
import '../../widgets/gem_card.dart';
import '../gem_detail_screen.dart';
import '../add_gem/add_gem_screen.dart';

class MyGemsScreen extends StatefulWidget {
  const MyGemsScreen({super.key});

  @override
  State<MyGemsScreen> createState() => _MyGemsScreenState();
}

class _MyGemsScreenState extends State<MyGemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GemProvider>(context, listen: false).fetchMyGems();
    });
  }

  void _showDeleteDialog(BuildContext context, String gemId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gem'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final gemProvider = Provider.of<GemProvider>(context, listen: false);
              final success = await gemProvider.deleteGem(gemId);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Gem deleted successfully'
                        : 'Failed to delete gem'),
                    backgroundColor: success
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gemProvider = Provider.of<GemProvider>(context);
    final myGems = gemProvider.myGems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gems'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddGemScreen()),
              );
            },
          ),
        ],
      ),
      body: gemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myGems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No gems listed yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start listing your gems for sale',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddGemScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'List Your First Gem',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => gemProvider.fetchMyGems(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: myGems.length,
                    itemBuilder: (context, index) {
                      final gem = myGems[index];
                      return GestureDetector(
                        onLongPress: () {
                          _showDeleteDialog(context, gem.id, gem.title);
                        },
                        child: GemCard(
                          gem: gem,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GemDetailScreen(gem: gem),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: myGems.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddGemScreen()),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
