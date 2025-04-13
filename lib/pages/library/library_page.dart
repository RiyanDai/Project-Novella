// class LibraryPage extends StatelessWidget {
//   const LibraryPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "LIBRARY PAGE",
//         style: TextStyle(fontSize: 40),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:novella_app/services/reading_progress_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final ReadingProgressHelper _progressHelper = ReadingProgressHelper.instance;
  Stream<List<Map<String, dynamic>>>? _progressStream;

  @override
  void initState() {
    super.initState();
    // Gunakan stream untuk memantau perubahan
    _progressStream = _progressHelper.watchReadingProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'My Library',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _progressStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reading progress yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start reading to see your progress here',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final progress = snapshot.data![index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('novels')
                            .doc(progress['novel_id'])
                            .get(),
                        builder: (context, novelSnapshot) {
                          if (novelSnapshot.connectionState == ConnectionState.waiting) {
                            return _buildProgressCard(progress, null);
                          }
                          final novel = novelSnapshot.data?.data() as Map<String, dynamic>?;
                          return Dismissible(
                            key: Key(progress['novel_id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            onDismissed: (direction) async {
                              // Delete reading progress using existing helper method
                              await _progressHelper.deleteProgress(progress['novel_id']);
                            },
                            child: _buildProgressCard(progress, novel),
                          );
                        },
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> progress, Map<String, dynamic>? novel) {
    final currentPage = progress['current_page'] as int;
    final totalPages = progress['total_pages'] as int;
    final progressValue = totalPages > 0 ? currentPage / totalPages : 0.0;
    final lastRead = DateTime.parse(progress['last_read']);
    final rating = novel?['rating']?.toDouble() ?? 0.0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (novel != null) {
            context.push('/novel/${progress['novel_id']}', extra: {
              ...novel,
              'id': progress['novel_id'],
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover Image
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: novel != null && novel['coverPath'] != null
                          ? Image.file(
                              File(novel['coverPath']),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[800],
                                    child: Icon(Icons.book, color: Colors.white),
                                  ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: Icon(Icons.book, color: Colors.white),
                            ),
                    ),
                  ),
                  if (rating > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel?['title'] ?? progress['title'] ?? 'Unknown Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      novel?['author'] ?? 'Unknown Author',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Progress Bar
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 8),
                    // Progress Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progressValue * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          'Page ${currentPage + 1} of $totalPages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Last read: ${_getTimeAgo(DateTime.parse(progress['last_read']))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
