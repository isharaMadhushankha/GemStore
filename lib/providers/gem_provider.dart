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
  

}