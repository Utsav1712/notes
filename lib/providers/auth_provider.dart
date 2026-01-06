import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

enum AuthState { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _supabaseService.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && session.user.emailConfirmedAt != null) {
        // Only authenticate if email is verified
        _currentUser = session.user;
        _state = AuthState.authenticated;
      } else {
        _currentUser = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });

    // Check current session
    final session = _supabaseService.auth.currentSession;
    if (session != null && session.user.emailConfirmedAt != null) {
      // Only authenticate if email is verified
      _currentUser = session.user;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Don't auto-login, user needs to verify email first
        _currentUser = null;
        _state = AuthState.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign up failed. Please try again.';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already registered')) {
        _errorMessage =
            'This email is already registered. Please verify your email or try logging in.';
      } else {
        _errorMessage = e.message;
      }
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Check if email is verified
        if (response.user!.emailConfirmedAt == null) {
          _errorMessage =
              'Please verify your email first. Check your inbox for the verification link.';
          _currentUser = null;
          _state = AuthState.error;
          // Sign out the user since they're not verified
          await _supabaseService.auth.signOut();
          notifyListeners();
          return false;
        }

        _currentUser = response.user;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed. Please check your credentials.';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid email or password') ||
          e.message.toLowerCase().contains('email not confirmed')) {
        _errorMessage =
            'You have not created an account. Please sign up first.';
      } else {
        _errorMessage = e.message;
      }
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
      _currentUser = null;
      _state = AuthState.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
