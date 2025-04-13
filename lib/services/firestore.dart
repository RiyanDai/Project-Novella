import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class FirestoreService {
  final CollectionReference novels = FirebaseFirestore.instance.collection('novels');

  // Add novel
  Future<void> addNovel({
    required String title,
    required String author,
    required String synopsis,
    required String genre,
    required String coverPath,
    required String pdfPath,
  }) async {
    try {
      await novels.add({
        'title': title,
        'author': author,
        'synopsis': synopsis,
        'genre': genre,
        'coverPath': coverPath,
        'pdfPath': pdfPath,
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'likes': 0,
        'status': 'published',
        'rating': 0.0,
        'ratingCount': 0,
      });
    } catch (e) {
      print('Error adding novel: $e');
      throw Exception('Failed to add novel');
    }
  }

  // Get novels stream
  Stream<QuerySnapshot> getNovelsStream() {
    return novels
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get novels by genre
  Stream<QuerySnapshot> getNovelsByGenre(String genre) {
    return novels
        .where('genre', isEqualTo: genre)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Search novels
  Stream<QuerySnapshot> searchNovels(String searchTerm) {
    return novels
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThan: searchTerm + 'z')
        .snapshots();
  }

  // Update novel
  Future<void> updateNovel(
      String docId, {
        String? title,
        String? author,
        String? synopsis,
        String? genre,
        String? coverPath,
        String? pdfPath,
      }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (author != null) updates['author'] = author;
      if (synopsis != null) updates['synopsis'] = synopsis;
      if (genre != null) updates['genre'] = genre;
      if (coverPath != null) updates['coverPath'] = coverPath;
      if (pdfPath != null) updates['pdfPath'] = pdfPath;

      await novels.doc(docId).update(updates);
    } catch (e) {
      print('Error updating novel: $e');
      throw Exception('Failed to update novel');
    }
  }

  // Delete novel
  Future<void> deleteNovel(String docId) async {
    try {
      // Get novel data first to delete files
      final doc = await novels.doc(docId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Delete files if they exist
        if (data['coverPath'] != null) {
          final coverFile = File(data['coverPath']);
          if (await coverFile.exists()) {
            await coverFile.delete();
          }
        }

        if (data['pdfPath'] != null) {
          final pdfFile = File(data['pdfPath']);
          if (await pdfFile.exists()) {
            await pdfFile.delete();
          }
        }
      }

      // Delete document
      await novels.doc(docId).delete();
    } catch (e) {
      print('Error deleting novel: $e');
      throw Exception('Failed to delete novel');
    }
  }

  // Increment view count
  Future<void> incrementViews(String docId) async {
    try {
      await novels.doc(docId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // Toggle like
  Future<void> toggleLike(String docId) async {
    try {
      await novels.doc(docId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Rate a novel
  Future<void> rateNovel(String docId, double rating) async {
    try {
      // Get the current novel data
      final doc = await novels.doc(docId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Calculate new average rating
        final currentRating = data['rating'] ?? 0.0;
        final currentCount = data['ratingCount'] ?? 0;
        
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + rating) / newCount;
        
        // Update the document with new rating
        await novels.doc(docId).update({
          'rating': newRating,
          'ratingCount': newCount,
        });
      }
    } catch (e) {
      print('Error rating novel: $e');
      throw Exception('Failed to rate novel');
    }
  }
}