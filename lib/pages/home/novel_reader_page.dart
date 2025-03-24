import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:novella_app/services/reading_progress_helper.dart';
import 'dart:io';

class NovelReaderPage extends StatefulWidget {
  final String pdfPath;
  final String novelId;
  final String title;
  final int? initialPage;

  const NovelReaderPage({
    required this.pdfPath,
    required this.novelId,
    required this.title,
    this.initialPage,
  });

  @override
  _NovelReaderPageState createState() => _NovelReaderPageState();
}

class _NovelReaderPageState extends State<NovelReaderPage> {
  late PDFViewController _controller;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPage != null) {
      _currentPage = widget.initialPage!;
    }
  }

  void _saveProgress() {
    ReadingProgressHelper.instance.saveProgress(
      widget.novelId,
      widget.title,
      _currentPage,
      _totalPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('${_currentPage + 1} / $_totalPages'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: true,
            pageSnap: true,
            defaultPage: _currentPage,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isLoading = false;
              });
            },
            onViewCreated: (controller) {
              _controller = controller;
            },
            onPageChanged: (page, total) {
              setState(() => _currentPage = page!);
              _saveProgress();
            },
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}