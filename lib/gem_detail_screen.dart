import 'package:flutter/material.dart';
import 'package:gemstore2/utils/snackbar_utils.dart';
import 'package:gemstore2/widgets/gem_dialog.dart';
import 'main.dart';

class GemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> gem;
  const GemDetailScreen({super.key, required this.gem});

  @override
  State<GemDetailScreen> createState() => _GemDetailScreenState();
}

class _GemDetailScreenState extends State<GemDetailScreen> {
  final _messageController = TextEditingController();
  bool _isBooking = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _confirmBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const GemDialog(
        icon: '✦',
        title: 'Confirm Booking?',
        subtitle:
            'Your message will be sent to the seller. They will contact you shortly.',
        confirmLabel: 'Book',
        confirmColor: Color(0xFFc9a84c),
        confirmTextColor: Color(0xFF0a0a0f),
        useGoldGradient: true,
      ),
    );
    if (confirmed != true) return;
    await _placeOrder();
  }

  Future<void> _placeOrder() async {
    setState(() => _isBooking = true);
    try {
      final currentUser = supabase.auth.currentUser!;
      await supabase.from('orders').insert({
        'gem_id': widget.gem['id'],
        'buyer_id': currentUser.id,
        'seller_id': widget.gem['user_id'],
        'gem_name': widget.gem['gem_name'],
        'price': widget.gem['price'],
        'contact_no': widget.gem['contact_no'],
        'image_url': widget.gem['image_url'],
        'message': _messageController.text.trim().isEmpty
            ? 'Hi, I am interested in this gem.'
            : _messageController.text.trim(),
        'status': 'pending',
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('✦  Booking sent to seller!'));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('Error: $e'));
      }
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gem = widget.gem;
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a0f),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF13131f),
                border: Border.all(color: const Color(0xFF2a2a3e))),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Color(0xFFc9a84c)),
          ),
        ),
        title: const Text('Gem Details',
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFf0d080))),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image
                  Stack(
                    children: [
                      gem['image_url'] != null
                          ? Image.network(
                              gem['image_url'],
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 240,
                              width: double.infinity,
                              color: const Color(0xFF0e0e18),
                              child: const Center(
                                  child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFF3a3a52),
                                      size: 40)),
                            ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              border:
                                  Border.all(color: const Color(0xFF2a2a3e)),
                              borderRadius: BorderRadius.circular(7)),
                          child: const Text('Available',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFc9a84c))),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & price
                        Text(gem['gem_name'] ?? '',
                            style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFf0d080))),
                        const SizedBox(height: 6),
                        Text(
                            'Rs. ${(gem['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFc9a84c))),
                        const SizedBox(height: 12),

                        // Tags
                        const Row(children: [
                          _Tag('Ceylon'),
                          SizedBox(width: 6),
                          _Tag('Certified'),
                          SizedBox(width: 6),
                          _Tag('Natural'),
                        ]),
                        const SizedBox(height: 20),

                        // Seller info
                        _SectionLabel('Seller Info'),
                        const SizedBox(height: 8),
                        _InfoRow(
                            icon: Icons.phone_outlined,
                            text: gem['contact_no'] ?? '—'),
                        const SizedBox(height: 20),

                        // Message
                        _SectionLabel('Send a Message'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFF13131f),
                              border:
                                  Border.all(color: const Color(0xFF2a2a3e)),
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('YOUR MESSAGE TO SELLER',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF4a4a62))),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _messageController,
                                maxLines: 3,
                                style: const TextStyle(
                                    color: Color(0xFFd8d8e8), fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Hi, I\'m interested in this gem...',
                                  hintStyle:
                                      TextStyle(color: Color(0xFF3a3a52)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Book button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBook,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFc9a84c),
                    foregroundColor: const Color(0xFF0a0a0f),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isBooking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0a0a0f)))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✦',
                              style: TextStyle(fontSize: 13)),
                          SizedBox(width: 8),
                          Text('Book Now',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFF1e1e2e),
            borderRadius: BorderRadius.circular(5)),
        child: Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF4a4a72))),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 9, letterSpacing: 2, color: Color(0xFF4a4a62))),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Color(0xFF1e1e2e))),
      ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: const Color(0xFF13131f),
            border: Border.all(color: const Color(0xFF2a2a3e)),
            borderRadius: BorderRadius.circular(9)),
        child: Row(children: [
          Icon(icon, size: 14, color: const Color(0xFF6b6b7e)),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFd8d8e8))),
        ]),
      );
}