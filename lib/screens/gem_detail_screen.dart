import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/gem.dart';
import '../providers/gem_provider.dart';
import '../providers/auth_provider.dart';

class GemDetailScreen extends StatefulWidget {
  final Gem gem;

  const GemDetailScreen({super.key, required this.gem});

  @override
  State<GemDetailScreen> createState() => _GemDetailScreenState();
}

class _GemDetailScreenState extends State<GemDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  void _contactSeller() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Seller',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            if (widget.gem.contactName != null)
              _buildContactItem(
                Icons.person,
                'Name',
                widget.gem.contactName!,
              ),
            
            if (widget.gem.contactPhone != null)
              _buildContactItem(
                Icons.phone,
                'Phone',
                widget.gem.contactPhone!,
                onTap: () => _launchUrl('tel:${widget.gem.contactPhone}'),
              ),
            
            if (widget.gem.contactEmail != null)
              _buildContactItem(
                Icons.email,
                'Email',
                widget.gem.contactEmail!,
                onTap: () => _launchUrl('mailto:${widget.gem.contactEmail}'),
              ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final authProvider = Provider.of<AuthProvider>(context);
    final gemProvider = Provider.of<GemProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.gem.images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: widget.gem.images.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: widget.gem.images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.diamond, size: 80),
                              ),
                            );
                          },
                        ),
                        
                        // Image Indicator
                        if (widget.gem.images.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.gem.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.diamond, size: 80, color: Colors.grey),
                      ),
                    ),
            ),
            actions: [
              if (authProvider.isAuthenticated)
                IconButton(
                  icon: Icon(
                    widget.gem.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.gem.isFavorite ? AppTheme.secondaryColor : null,
                  ),
                  onPressed: () {
                    gemProvider.toggleFavorite(widget.gem.id);
                  },
                ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.gem.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    currencyFormat.format(widget.gem.price),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Properties Grid
                  _buildPropertiesGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  if (widget.gem.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.gem.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Location
                  if (widget.gem.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, 
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          widget.gem.location!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Contact Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _contactSeller,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text(
                        'Contact Seller',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesGrid() {
    final properties = <Map<String, dynamic>>[];
    
    if (widget.gem.color != null) {
      properties.add({'label': 'Color', 'value': widget.gem.color});
    }
    if (widget.gem.weight != null) {
      properties.add({'label': 'Weight', 'value': '${widget.gem.weight} ct'});
    }
    if (widget.gem.model != null) {
      properties.add({'label': 'Model', 'value': widget.gem.model});
    }
    properties.add({
      'label': 'Status',
      'value': widget.gem.status.toUpperCase(),
    });
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: properties.map((prop) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prop['label'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                prop['value'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
