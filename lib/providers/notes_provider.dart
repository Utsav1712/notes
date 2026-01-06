import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/supabase_service.dart';

class NotesProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<NoteModel> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchNotes() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _supabaseService.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.notes
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _notes =
          (response as List).map((json) => NoteModel.fromJson(json)).toList();

      _applySearch();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNote(String title, String content) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _supabaseService.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      await _supabaseService.notes.insert({
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(String noteId, String title, String content) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final now = DateTime.now();
      await _supabaseService.notes.update({
        'title': title,
        'content': content,
        'updated_at': now.toIso8601String(),
      }).eq('id', noteId);

      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.notes.delete().eq('id', noteId);

      await fetchNotes();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void searchNotes(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
