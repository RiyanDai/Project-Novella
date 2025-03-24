import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novella_app/services/reading_progress_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:novella_app/routing_tpl.dart';
import 'dart:io';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Progress Membaca Section
          Text(
            'Progress Membaca',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: ReadingProgressHelper.instance.getRecentlyRead(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat membaca',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.map((progress) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('novels')
                        .doc(progress['novel_id'])
                        .get(),
                    builder: (context, novelSnapshot) {
                      if (!novelSnapshot.hasData || !novelSnapshot.data!.exists) {
                        return Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.book, color: Colors.blue),
                            title: Text(
                              progress['title']?.toString() ?? 'Untitled Novel',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Halaman ${progress['current_page'] + 1} dari ${progress['total_pages']} • ${_getTimeAgo(DateTime.parse(progress['last_read']))}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: progress['current_page'] / progress['total_pages'],
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                        );
                      }

                      final novel = novelSnapshot.data!.data() as Map<String, dynamic>;
                      if (novel == null) return SizedBox();

                      final DateTime lastRead = DateTime.parse(progress['last_read']);
                      final timeAgo = _getTimeAgo(lastRead);

                      return Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(novel['coverPath']),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.book, color: Colors.blue);
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            novel['title'] ?? 'Novel tidak tersedia',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Halaman ${progress['current_page'] + 1} dari ${progress['total_pages']} • $timeAgo',
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: progress['current_page'] / progress['total_pages'],
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          onTap: () {
                            if (novel != null) {
                              context.push('/novel/${progress['novel_id']}', extra: {
                                ...novel,
                                'id': progress['novel_id'],
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: 24),

          // Update Terbaru Section
          Text(
            'Update Terbaru',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('novels')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada novel terbaru',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final novel = doc.data() as Map<String, dynamic>;
                  final createdAt = (novel['createdAt'] as Timestamp).toDate();
                  final timeAgo = _getTimeAgo(createdAt);

                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        Icons.new_releases,
                        color: Colors.orange,
                      ),
                      title: Text(
                        'Novel Baru Ditambahkan',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        novel['title'],
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        timeAgo,
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        context.push('/novel/${doc.id}', extra: {
                          ...novel,
                          'id': doc.id,
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: 24),

          // Rekomendasi Section
          Text(
            'Rekomendasi Untukmu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('novels')
                .orderBy('viewCount', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada rekomendasi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final novel = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(novel['coverPath']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.recommend, color: Colors.green);
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        novel['title'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Genre: ${novel['genre']}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () {
                        context.push('/novel/${doc.id}', extra: {
                          ...novel,
                          'id': doc.id,
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}