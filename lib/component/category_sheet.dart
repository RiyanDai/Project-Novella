import 'package:flutter/material.dart';

class CategorySheet {
  static final List<String> categories = [
    "Roman",
    "Fiksi Remaja",
    "Fiksi Penggemar",
    "Fantasi",
    "Acak",
    "Cerita Pendek",
    "Fiksi Umum",
    "ChickLit",
    "Humor",
    "Getaran",
    "Misteri",
    "Laga",
    "Spiritual",
    "Fiksi Sejarah",
    "Non-Fiksi",
    "Fiksi Ilmiah",
    "Petualangan",
    "Horor",
    "Vampir",
    "Manusia Serigala",
    "Paranormal",
    "Puisi",
    "Klasik"
  ];

  static final Map<String, bool> selectedCategories = {for (var category in categories) category: false};

  static Future<String?> show(BuildContext context) async {
    final List<String> genres = [
      'Romance', 'Fantasy', 'Sci-Fi', 'Mystery', 'Horror',
      'Action', 'Drama', 'Comedy', 'Slice of Life', 'Historical',
    ];

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pilih Kategori',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: Colors.grey[800]),
            Expanded(
              child: ListView.builder(
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      genres[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, genres[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildNewTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
