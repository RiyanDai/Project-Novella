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

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                  child: Text(
                'BACAAN SAAT INI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
              Tab(
                  child: Text(
                'ARSIP',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
              Tab(
                  child: Text(
                'BACAAN SAAT INI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ReadingNowTab(),
                Center(child: Text('Arsip Kosong')), // Placeholder for Archive
                Center(child: Text('Daftar Bacaan Kosong')), // Placeholder for Reading List
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReadingNowTab extends StatelessWidget {
  final List<Map<String, String>> books = [
    {'title': 'Elements', 'image': 'assets/a.jpg'},
    {'title': 'Bombshell Blonde', 'image': 'assets/b.jpg'},
    {'title': 'The Mutants', 'image': 'assets/a.jpg'},
    {'title': 'Red City Isolation', 'image': 'assets/b.jpg'},
    {'title': 'Elements', 'image': 'assets/a.jpg'},
    {'title': 'Bombshell Blonde', 'image': 'assets/b.jpg'},
    {'title': 'The Mutants', 'image': 'assets/a.jpg'},
    {'title': 'Red City Isolation', 'image': 'assets/b.jpg'},
    {'title': 'Elements', 'image': 'assets/a.jpg'},
    {'title': 'Bombshell Blonde', 'image': 'assets/b.jpg'},
    {'title': 'The Mutants', 'image': 'assets/a.jpg'},
    {'title': 'Red City Isolation', 'image': 'assets/b.jpg'},
    {'title': 'Elements', 'image': 'assets/a.jpg'},
    {'title': 'Bombshell Blonde', 'image': 'assets/b.jpg'},
    {'title': 'The Mutants', 'image': 'assets/a.jpg'},
    {'title': 'Red City Isolation', 'image': 'assets/b.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tersedia Offline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${books.length} dari 25 cerita", style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return _BookCard(title: books[index]['title']!, image: books[index]['image']!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String image;

  _BookCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
