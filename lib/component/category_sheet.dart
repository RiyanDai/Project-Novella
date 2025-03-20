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

  static void show(BuildContext context, TextEditingController searchController, Function setStateCallback) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Kategori",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: _buildNewTransition,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: Colors.grey[900],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8, left: 8, top: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Telusuri cerita, profil, atau daftar bacaan',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: categories.map((category) {
                          return FilterChip(
                            label: Text(category),
                            selected: selectedCategories[category] ?? false,
                            onSelected: (bool selected) {
                              setDialogState(() {
                                selectedCategories[category] = selected;
                              });
                              setStateCallback(() {});
                            },
                            backgroundColor: Colors.grey[800],
                            selectedColor: Colors.orange,
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
