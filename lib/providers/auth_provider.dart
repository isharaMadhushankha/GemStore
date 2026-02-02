import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSignUpAttempt;
  int _rateLimitSeconds = 0;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  int get rateLimitSeconds => _rateLimitSeconds;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id);
    }
    
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserProfile(session.user.id);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      _currentUser = AppUser.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _rateLimitSeconds = 0;
    notifyListeners();

    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'location': location,
        });

        await _loadUserProfile(response.user!.id);
        _lastSignUpAttempt = DateTime.now();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _lastSignUpAttempt = DateTime.now();
      _errorMessage = _parseAuthError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _parseAuthError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseAuthError(e.toString());
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? location,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('users').update({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
      }).eq('id', _currentUser!.id);

      await _loadUserProfile(_currentUser!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _rateLimitSeconds = 0;
    notifyListeners();
  }

  String _parseAuthError(String error) {
    if (error.contains('over_email_send_rate_limit')) {
      // Extract the wait time from the error message
      final RegExp regExp = RegExp(r'after (\d+) seconds');
      final match = regExp.firstMatch(error);
      
      if (match != null) {
        _rateLimitSeconds = int.tryParse(match.group(1) ?? '0') ?? 60;
        return 'Too many signup attempts. Please wait $_rateLimitSeconds seconds before trying again.';
      }
      
      _rateLimitSeconds = 60; // Default fallback
      return 'Too many signup attempts. Please wait a moment before trying again.';
    }
    
    if (error.contains('AuthApiException')) {
      // Clean up the error message for user display
      final RegExp regExp = RegExp(r'message: ([^,]+)');
      final match = regExp.firstMatch(error);
      
      if (match != null) {
        return match.group(1)?.trim() ?? 'Authentication error occurred';
      }
    }
    
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }
    
    if (error.contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    
    if (error.contains('Password should be at least')) {
      return 'Password should be at least 6 characters long.';
    }
    
    if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    }
    
    // Generic fallback
    return 'An error occurred. Please try again later.';
  }

  bool canRetrySignUp() {
    if (_lastSignUpAttempt == null) return true;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastSignUpAttempt!);
    
    return timeDifference.inSeconds >= _rateLimitSeconds;
  }

  int getRemainingWaitTime() {
    if (_lastSignUpAttempt == null) return 0;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastSignUpAttempt!);
    final remainingSeconds = _rateLimitSeconds - timeDifference.inSeconds;
    
    return remainingSeconds > 0 ? remainingSeconds : 0;
  }
}
