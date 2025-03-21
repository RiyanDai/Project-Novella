import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/database_helper.dart';

class ChapterEditorPage extends StatefulWidget {
  final Chapter chapter;

  const ChapterEditorPage({super.key, required this.chapter});

  @override
  State<ChapterEditorPage> createState() => _ChapterEditorPageState();
}

class _ChapterEditorPageState extends State<ChapterEditorPage> {
  final dbHelper = DatabaseHelper.instance;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapter.title);
    _contentController = TextEditingController(text: widget.chapter.content);

    // Listen for changes to mark as dirty
    _titleController.addListener(_markAsDirty);
    _contentController.addListener(_markAsDirty);
  }

  void _markAsDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Simpan Perubahan?'),
        content: Text('Ada perubahan yang belum disimpan. Simpan sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Buang'),
          ),
          TextButton(
            onPressed: () async {
              await _saveChapter();
              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveChapter() async {
    final updatedChapter = widget.chapter.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    await dbHelper.updateChapter(updatedChapter);
    setState(() => _isDirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Bab'),
          actions: [
            if (_isDirty)
              IconButton(
                icon: Icon(Icons.save),
                onPressed: _saveChapter,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Judul Bab',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Tulis ceritamu di sini...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
} 