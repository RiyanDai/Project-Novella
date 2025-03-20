import 'package:flutter/material.dart';
import 'package:novella_app/component/category_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // InkWell(
          //   child: Align(
          //       alignment: Alignment.topRight,
          //       child: IntrinsicWidth(
          //         child: Container(
          //           color: Colors.orange[400],
          //           height: 20.0,
          //           child: Text(
          //             "Pilih Kategori",
          //             style: TextStyle(color: Colors.black),
          //           ),
          //         ),
          //       )),
          //   onTap: () => CategorySheet.show(context, _searchController, setState),
          // ),
          Container(
            // margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () => CategorySheet.show(context, _searchController, setState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "Pilih Kategori",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          BookCard(
            rank: "4",
            title: "Pipe Dream",
            author: "Sweet_girl77",
            imageUrl: "assets/b.jpg",
            views: "61,3 Rb",
            chapters: "38",
            tags: ["artis", "bos", "ceo"],
          ),
          BookCard(
            rank: "1",
            title: "Beranak Dalam Kubur",
            author: "AmbaRiyan",
            imageUrl: "assets/a.jpg",
            views: "100 Rb",
            chapters: "69",
            tags: ["horror"],
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String rank;
  final String title;
  final String author;
  final String imageUrl;
  final String views;
  final String chapters;
  final List<String> tags;

  const BookCard({
    super.key,
    required this.rank,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.views,
    required this.chapters,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),

          // Book Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$rank $title",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  author,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),

                // Views & Chapters
                Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(views, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    const Icon(Icons.list, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(chapters, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 5),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      );
                    }).toList(),
                    const Text(
                      "+ selanjutnya",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
