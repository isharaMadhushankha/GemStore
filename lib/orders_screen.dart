import 'package:flutter/material.dart';
import 'package:gemstore/widgets/gem_dialog.dart';
import 'package:gemstore/utils/snackbar_utils.dart';
import 'main.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listenForUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _listenForUpdates() {
    final uid = supabase.auth.currentUser!.id;
    supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', uid)
        .listen((orders) {
      for (final order in orders) {
        final status = order['status'];
        final gemName = order['gem_name'] ?? 'Your gem';
        if (status == 'confirmed' && mounted) {
          _showStatusBanner(
              '✦  $gemName booking confirmed!', isConfirm: true);
        } else if (status == 'cancelled' && mounted) {
          _showStatusBanner(
              '✕  $gemName booking was cancelled.', isConfirm: false);
        }
      }
    });
  }

  void _showStatusBanner(String msg, {required bool isConfirm}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
                color: isConfirm
                    ? const Color(0xFF3a8a3a)
                    : const Color(0xFFa83232),
                fontSize: 13)),
        backgroundColor: const Color(0xFF13131f),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: isConfirm
                    ? const Color(0xFF1a3a1a)
                    : const Color(0xFF3a1a1a))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser!.id;
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
            Text('My Orders',
                style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFf0d080))),
            Text('BOOKINGS & REQUESTS',
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: Color(0xFF4a4a62))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: const Color(0xFF13131f),
                  borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    color: const Color(0xFF1f1f30),
                    borderRadius: BorderRadius.circular(8)),
                labelColor: const Color(0xFFf0d080),
                unselectedLabelColor: const Color(0xFF5a5a72),
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Sent'), Tab(text: 'Received')],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sent — buyer view
          _OrdersList(
            stream: supabase
                .from('orders')
                .stream(primaryKey: ['id'])
                .eq('buyer_id', uid)
                .order('created_at'),
            emptyMsg: 'No bookings sent yet',
            isSeller: false,
          ),
          // Received — seller view
          _OrdersList(
            stream: supabase
                .from('orders')
                .stream(primaryKey: ['id'])
                .eq('seller_id', uid)
                .order('created_at'),
            emptyMsg: 'No requests received yet',
            isSeller: true,
          ),
        ],
      ),
    );
  }
}

// ─── Orders List ─────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> stream;
  final String emptyMsg;
  final bool isSeller;

  const _OrdersList({
    required this.stream,
    required this.emptyMsg,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFc9a84c)));
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✦',
                  style:
                      TextStyle(fontSize: 32, color: Color(0xFF2a2a3e))),
              const SizedBox(height: 10),
              Text(emptyMsg,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF3a3a52))),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: orders.length,
          itemBuilder: (context, i) =>
              _OrderCard(order: orders[i], isSeller: isSeller),
        );
      },
    );
  }
}

// ─── Order Card ──────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isSeller;
  const _OrderCard({required this.order, required this.isSeller});

  Future<void> _confirmOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const GemDialog(
        icon: '✦',
        title: 'Confirm Order?',
        subtitle:
            'The buyer will be notified that their booking is confirmed.',
        confirmLabel: 'Confirm',
        confirmColor: Color(0xFFc9a84c),
        confirmTextColor: Color(0xFF0a0a0f),
        useGoldGradient: true,
      ),
    );
    if (confirmed == true) {
      await supabase
          .from('orders')
          .update({'status': 'confirmed'})
          .match({'id': order['id']});
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('✦  Order confirmed'));
      }
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const GemDialog(
        icon: '✕',
        title: 'Cancel Order?',
        subtitle: 'This booking will be cancelled and removed.',
        confirmLabel: 'Cancel Order',
        confirmColor: Color(0xFF3a1a1a),
        confirmTextColor: Color(0xFFe05050),
      ),
    );
    if (confirmed == true) {
      await supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .match({'id': order['id']});
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('🗑️  Order cancelled'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';
    final isCancelled = status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF13131f),
          border: Border.all(
            color: isConfirmed
                ? const Color(0xFF1a3a1a)
                : isCancelled
                    ? const Color(0xFF3a1a1a)
                    : const Color(0xFF2a2a3e),
          ),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: order['image_url'] != null
                    ? Image.network(order['image_url'],
                        width: 46, height: 46, fit: BoxFit.cover)
                    : Container(
                        width: 46,
                        height: 46,
                        color: const Color(0xFF0e0e18),
                        child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF3a3a52),
                            size: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['gem_name'] ?? '',
                        style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            color: Color(0xFFe8e8f0))),
                    const SizedBox(height: 3),
                    Text(
                        'Rs. ${(order['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFc9a84c))),
                  ],
                ),
              ),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: isConfirmed
                        ? const Color(0xFF0e1a0e)
                        : isCancelled
                            ? const Color(0xFF1a0a0a)
                            : const Color(0xFF1e1a0a),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  isConfirmed
                      ? 'Confirmed'
                      : isCancelled
                          ? 'Cancelled'
                          : 'Pending',
                  style: TextStyle(
                      fontSize: 9,
                      color: isConfirmed
                          ? const Color(0xFF3a8a3a)
                          : isCancelled
                              ? const Color(0xFFa83232)
                              : const Color(0xFF8a7a3a)),
                ),
              ),
            ],
          ),

          // ── Buyer message bubble ──────────────────────────────
          if (order['message'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF0e0e18),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💬 ', style: TextStyle(fontSize: 11)),
                  Expanded(
                    child: Text(order['message'],
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5a5a72),
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          ],

          // ── Confirmed banner (buyer sees this) ───────────────
          if (isConfirmed) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF0e1a0e),
                  border: Border.all(color: const Color(0xFF1a3a1a)),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Text('✦ ',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF3a8a3a))),
                  Expanded(
                    child: Text(
                      'Your booking is confirmed! Seller will contact you soon.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3a8a3a),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Cancelled banner (buyer sees this) ───────────────
          if (isCancelled) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF1a0a0a),
                  border: Border.all(color: const Color(0xFF3a1a1a)),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Text('✕ ',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFa83232))),
                  Expanded(
                    child: Text(
                      'This booking was cancelled by the seller.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFa83232),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Seller action buttons (pending only) ─────────────
          if (isSeller && isPending) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF1e1e2e), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => _cancelOrder(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1a0a0a),
                          border: Border.all(
                              color: const Color(0xFF3a1a1a)),
                          borderRadius: BorderRadius.circular(9)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close,
                              size: 12, color: Color(0xFFa83232)),
                          SizedBox(width: 5),
                          Text('Cancel',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFa83232))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Confirm
                Expanded(
                  child: GestureDetector(
                    onTap: () => _confirmOrder(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFb8920e),
                              Color(0xFFf0d080)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(9)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✦',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0a0a0f))),
                          SizedBox(width: 5),
                          Text('Confirm',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0a0a0f))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}