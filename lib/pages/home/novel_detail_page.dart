import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:novella_app/routing_tpl.dart';

class NovelDetailPage extends StatelessWidget {
  final Map<String, dynamic> novel;

  const NovelDetailPage({required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(novel['coverPath']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel['title'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${novel['author']}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      novel['genre'],
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    novel['synopsis'],
                    style: TextStyle(
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                        context.push(Routes.reader, extra: novel['pdfPath']);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                    child: Text('Mulai Membaca'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}