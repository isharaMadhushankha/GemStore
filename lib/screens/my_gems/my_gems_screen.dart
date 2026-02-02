import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gem_provider.dart';
import '../../widgets/gem_card.dart';
import '../gem_detail_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gems'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<GemProvider>(context, listen: false).fetchMyGems();
            },
          ),
        ],
      ),
      body: Consumer<GemProvider>(
        builder: (context, gemProvider, child) {
          if (gemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (gemProvider.myGems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No gems listed yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first gem to start selling!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: gemProvider.myGems.length,
            itemBuilder: (context, index) {
              final gem = gemProvider.myGems[index];
              return GemCard(
                gem: gem,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GemDetailScreen(gem: gem),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
