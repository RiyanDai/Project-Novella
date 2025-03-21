import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../services/database_helper.dart';
import 'novel_editor_page.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final dbHelper = DatabaseHelper.instance;
  List<Novel> _novels = [];

  @override
  void initState() {
    super.initState();
    _loadNovels();
  }

  Future<void> _loadNovels() async {
    final novels = await dbHelper.getAllNovels();
    setState(() {
      _novels = novels;
    });
  }

  void _createNewNovel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Novel Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Judul Novel',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (title) async {
                if (title.isNotEmpty) {
                  final novel = Novel(
                    title: title,
                    author: 'User', // You might want to get this from user profile
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await dbHelper.insertNovel(novel);
                  Navigator.pop(context);
                  _loadNovels();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tulisan Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewNovel,
          ),
        ],
      ),
      body: _novels.isEmpty
          ? Center(
              child: Text('Belum ada novel. Mulai menulis sekarang!'),
            )
          : ListView.builder(
              itemCount: _novels.length,
              itemBuilder: (context, index) {
                final novel = _novels[index];
                return ListTile(
                  title: Text(novel.title),
                  subtitle: Text('Terakhir diubah: ${novel.updatedAt.toString()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovelEditorPage(novel: novel),
                      ),
                    ).then((_) => _loadNovels());
                  },
                );
              },
            ),
    );
  }
}
