import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gem.dart';
import '../config/supabase_config.dart';


class GemProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Gem> _gems = [];
  List<Gem> _myGems = [];
  List<String> _favoriteGemIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Gem> get gems => _gems;
  List<Gem> get myGems => _myGems;
  List<Gem> get favoriteGems => _gems.where((g) => g.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGems({String? searchQuery, String? colorFilter}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase
          .from(SupabaseConfig.gemsTable)
          .select()
          .eq('status', 'available')
          .order('created_at', ascending: false);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (colorFilter != null && colorFilter.isNotEmpty) {
        query = query.eq('color', colorFilter);
      }

      final response = await query;
      _gems = (response as List).map((json) => Gem.fromJson(json)).toList();
      
      await _loadFavorites();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyGems() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from(SupabaseConfig.gemsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _myGems = (response as List).map((json) => Gem.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> uploadedUrls = [];

    try {
      for (var file in imageFiles) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final filePath = '${_supabase.auth.currentUser!.id}/$fileName';

        await _supabase.storage
            .from(SupabaseConfig.gemImagesBucket)
            .upload(filePath, file);

        final publicUrl = _supabase.storage
            .from(SupabaseConfig.gemImagesBucket)
            .getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
      }
      return uploadedUrls;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      rethrow;
    }
  }

  Future<bool> createGem({
    required String title,
    String? description,
    required double price,
    String? color,
    double? weight,
    String? model,
    String? location,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    required List<String> imageUrls,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from(SupabaseConfig.gemsTable).insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'price': price,
        'color': color,
        'weight': weight,
        'model': model,
        'location': location,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'images': imageUrls,
        'status': 'available',
      });

      await fetchMyGems();
      await fetchGems();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  

}