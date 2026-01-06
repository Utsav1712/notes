import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final success = await notesProvider.updateNote(
      widget.note.id,
      _titleController.text.trim(),
      _contentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notesProvider.errorMessage ?? 'Failed to update note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final success = await notesProvider.deleteNote(widget.note.id);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notesProvider.errorMessage ?? 'Failed to delete note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Same pastel colors as note cards
    final colors = [
      const Color(0xFFB5EAD7), // Mint green
      const Color(0xFFE0BBE4), // Lavender
      const Color(0xFFFDECB3), // Light yellow
      const Color(0xFFFFDAB9), // Peach
      const Color(0xFFB4E7F5), // Light blue
      const Color(0xFFFFB3BA), // Light pink
    ];
    final colorIndex = widget.note.id.hashCode % colors.length;
    final backgroundColor = colors[colorIndex.abs()];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3748),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit Note' : widget.note.title),
        actions: [
          if (_isEditing)
            Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                return TextButton(
                  onPressed: notesProvider.isLoading ? null : _handleSave,
                  child: notesProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2D3748)),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _titleController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                  contentPadding: EdgeInsets.all(20),
                ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${dateFormat.format(widget.note.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _contentController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start writing...',
                  contentPadding: EdgeInsets.all(20),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.6,
                ),
                maxLines: null,
                minLines: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
