import 'package:flutter/material.dart';
import 'package:gemstore/widgets/gem_dialog.dart';
import 'main.dart';
import 'add_gem_screen.dart';
import 'edit_gem_screen.dart';
import 'auth_screen.dart';
import 'gem_detail_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a0f),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gem Market',
                style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFf0d080))),
            Text('PREMIUM COLLECTION',
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: Color(0xFF4a4a62))),
          ],
        ),
        actions: [
          // Orders button
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen())),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF13131f),
                  border: Border.all(color: const Color(0xFF2a2a3e))),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 15, color: Color(0xFF6b6b7e)),
            ),
          ),
          // Logout button
          GestureDetector(
            onTap: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF13131f),
                  border: Border.all(color: const Color(0xFF2a2a3e))),
              child: const Icon(Icons.power_settings_new_outlined,
                  size: 15, color: Color(0xFF6b6b7e)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF13131f),
                  border: Border.all(color: const Color(0xFF2a2a3e)),
                  borderRadius: BorderRadius.circular(10)),
              child: const TextField(
                style: TextStyle(color: Color(0xFFd8d8e8), fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search gems...',
                  hintStyle: TextStyle(color: Color(0xFF3a3a52)),
                  prefixIcon:
                      Icon(Icons.search, size: 16, color: Color(0xFF4a4a62)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: supabase
                  .from('gems')
                  .stream(primaryKey: ['id'])
                  .order('created_at'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFc9a84c)));
                }
                final gems = snapshot.data!;
                if (gems.isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💎',
                          style: TextStyle(
                              fontSize: 40, color: Color(0xFF2a2a3e))),
                      SizedBox(height: 10),
                      Text('No gems listed yet',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF3a3a52))),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: gems.length,
                  itemBuilder: (context, index) {
                    final gem = gems[index];
                    final isMine =
                        gem['user_id'] == supabase.auth.currentUser!.id;
                    return _GemCard(gem: gem, isMine: isMine);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddGemScreen())),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFb8920e), Color(0xFFf0d080)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFc9a84c).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Icon(Icons.add, color: Color(0xFF0a0a0f), size: 26),
        ),
      ),
    );
  }
}

class _GemCard extends StatelessWidget {
  final Map<String, dynamic> gem;
  final bool isMine;
  const _GemCard({required this.gem, required this.isMine});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => GemDialog(
        icon: '🗑️',
        title: 'Delete Listing?',
        subtitle: 'This gem will be permanently removed from the marketplace.',
        confirmLabel: 'Delete',
        confirmColor: const Color(0xFF3a1a1a),
        confirmTextColor: const Color(0xFFe05050),
      ),
    );
    if (confirmed == true) {
      await supabase.from('gems').delete().match({'id': gem['id']});
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_goldSnackBar('🗑️  Gem listing deleted'));
      }
    }
  }

  Future<void> _navigateEdit(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => EditGemScreen(gem: gem)));
  }

  Future<void> _navigateDetail(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GemDetailScreen(gem: gem)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: const Color(0xFF13131f),
            border: Border.all(color: const Color(0xFF2a2a3e)),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13)),
              child: gem['image_url'] != null
                  ? Image.network(gem['image_url'],
                      width: 82, height: 82, fit: BoxFit.cover)
                  : Container(
                      width: 82,
                      height: 82,
                      color: const Color(0xFF0e0e18),
                      child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Color(0xFF3a3a52), size: 24))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gem['gem_name'] ?? '',
                        style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFe8e8f0))),
                    const SizedBox(height: 3),
                    Text(
                        'Rs. ${(gem['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFc9a84c))),
                    const SizedBox(height: 2),
                    Text('☏  ${gem['contact_no'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF5a5a72))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xFF1e180a)
                                  : const Color(0xFF1e1e2e),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(isMine ? 'My listing' : 'Available',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: isMine
                                      ? const Color(0xFF8a7a3a)
                                      : const Color(0xFF4a4a72))),
                        ),
                        const Spacer(),
                        if (isMine) ...[
                          // Edit button
                          GestureDetector(
                            onTap: () => _navigateEdit(context),
                            child: Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF0e1a0e),
                                  border: Border.all(
                                      color: const Color(0xFF1a3a1a)),
                                  borderRadius: BorderRadius.circular(7)),
                              child: const Icon(Icons.edit_outlined,
                                  size: 12, color: Color(0xFF3a8a3a)),
                            ),
                          ),
                          // Delete button
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1a0a0a),
                                  border: Border.all(
                                      color: const Color(0xFF3a1a1a)),
                                  borderRadius: BorderRadius.circular(7)),
                              child: const Icon(Icons.close,
                                  size: 12, color: Color(0xFFa83232)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

SnackBar _goldSnackBar(String msg) => SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Color(0xFFf0d080),
              fontFamily: 'sans-serif',
              fontSize: 13)),
      backgroundColor: const Color(0xFF13131f),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF2a2a3e))),
    );