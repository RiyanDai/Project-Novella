import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class NovelReaderPage extends StatefulWidget {
  final String pdfPath;

  const NovelReaderPage({required this.pdfPath});

  @override
  _NovelReaderPageState createState() => _NovelReaderPageState();
}

class _NovelReaderPageState extends State<NovelReaderPage> {
  late PDFViewController _controller;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;

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
            },
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}