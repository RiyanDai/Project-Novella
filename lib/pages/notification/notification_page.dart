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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
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
                .collection('notifications')
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
                  final notification = doc.data() as Map<String, dynamic>;
                  final createdAt = (notification['createdAt'] as Timestamp).toDate();
                  final timeAgo = _getTimeAgo(createdAt);

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    onDismissed: (direction) {
                      FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(doc.id)
                          .delete();
                    },
                    child: Card(
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
                          notification['novelTitle'],
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          timeAgo,
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          context.push('/novel/${notification['novelId']}', extra: {
                            'id': notification['novelId'],
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: 24),

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