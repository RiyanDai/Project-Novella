import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novella_app/services/reading_progress_helper.dart';
import 'package:novella_app/services/firestore.dart';
import 'dart:io';
import 'package:novella_app/routing_tpl.dart';

class NovelDetailPage extends StatefulWidget {
  final Map<String, dynamic> novel;

  const NovelDetailPage({required this.novel});

  @override
  _NovelDetailPageState createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  double _userRating = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _userRating = widget.novel['rating']?.toDouble() ?? 0.0;
  }

  void _submitRating(double rating) async {
    final String novelId = widget.novel['id'] as String;
    await _firestoreService.rateNovel(novelId, rating);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terima kasih atas penilaian Anda!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String novelId = widget.novel['id'] as String;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(widget.novel['coverPath']),
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
                    widget.novel['title'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${widget.novel['author']}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.novel['genre'],
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${(widget.novel['rating'] ?? 0.0).toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            '(${widget.novel['ratingCount'] ?? 0})',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Beri Penilaian',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar(
                        rating: _userRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _userRating = rating;
                          });
                          _submitRating(rating);
                        },
                      ),
                    ],
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
                    widget.novel['synopsis'],
                    style: TextStyle(
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: ReadingProgressHelper.instance.getProgress(novelId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final progress = snapshot.data!;
                        return ElevatedButton(
                          onPressed: () {
                            context.push(
                              Routes.reader,
                              extra: {
                                'pdfPath': widget.novel['pdfPath'],
                                'novelId': novelId,
                                'initialPage': progress['current_page'],
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Lanjutkan Membaca (Halaman ${progress['current_page'] + 1})', style: TextStyle(color: Colors.white) 
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed: () {
                          context.push(
                            Routes.reader,
                            extra: {
                              'pdfPath': widget.novel['pdfPath'],
                              'novelId': novelId,
                              'initialPage': 0,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Mulai Membaca', style: TextStyle(color: Colors.white),),
                      );
                    },
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

class RatingBar extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final int starCount;

  const RatingBar({
    required this.rating,
    required this.onRatingChanged,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
          padding: EdgeInsets.symmetric(horizontal: 4),
          constraints: BoxConstraints(),
          splashRadius: 24,
        );
      }),
    );
  }
}