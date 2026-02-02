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
}