import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../services/database_helper.dart';
import '../writing/chapter_editor_page.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/pdf_service.dart';

class NovelEditorPage extends StatefulWidget {
  final Novel novel;

  const NovelEditorPage({super.key, required this.novel});

  @override
  State<NovelEditorPage> createState() => _NovelEditorPageState();
}

class _NovelEditorPageState extends State<NovelEditorPage> {
  final dbHelper = DatabaseHelper.instance;
  final pdfService = PdfService();
  List<Chapter> _chapters = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    if (widget.novel.id == null) return;
    final chapters = await dbHelper.getNovelChapters(widget.novel.id!);
    setState(() {
      _chapters = chapters;
    });
  }

  void _createNewChapter() async {
    if (widget.novel.id == null) return;

    final newChapter = Chapter(
      novelId: widget.novel.id!,
      title: 'Bab ${_chapters.length + 1}',
      content: '',
      chapterNumber: _chapters.length + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final chapter = await dbHelper.insertChapter(newChapter);
    
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterEditorPage(chapter: chapter),
      ),
    );

    _loadChapters();
  }

  Future<void> _exportToPdf() async {
    if (_chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada bab untuk diekspor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pdfFile = await pdfService.generateNovelPdf(widget.novel, _chapters);
      
      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Novel ${widget.novel.title}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novel.title),
        actions: [
          if (_isExporting)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _exportToPdf,
            ),
        ],
      ),
      body: _chapters.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum ada bab. Mulai menulis sekarang!'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createNewChapter,
                    icon: Icon(Icons.add),
                    label: Text('Tambah Bab Baru'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(chapter.title),
                  subtitle: Text(
                    'Terakhir diubah: ${chapter.updatedAt.toString()}',
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterEditorPage(
                          chapter: chapter,
                        ),
                      ),
                    );
                    _loadChapters();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChapter,
        child: Icon(Icons.add),
      ),
    );
  }
} 