import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:novella_app/component/category_sheet.dart';
import 'dart:io';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = '';
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('novels')
          .orderBy('title')
          .limit(10)
          .get();
          
      if (!mounted) return;
      setState(() => _searchResults = snapshot.docs);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      setState(() => _isLoading = true);
      try {
        Query ref = FirebaseFirestore.instance.collection('novels');
        
        if (query.isNotEmpty) {
          ref = ref.where('title', isGreaterThanOrEqualTo: query)
                   .where('title', isLessThan: query + 'z');
        }
        
        if (_selectedGenre.isNotEmpty) {
          ref = ref.where('genre', isEqualTo: _selectedGenre);
        }

        final QuerySnapshot snapshot = await ref.get();
        
        if (!mounted) return;
        setState(() => _searchResults = snapshot.docs);
      } catch (e) {
        print('Error searching: $e');
      } finally {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari novel...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _performSearch,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final selectedGenre = await CategorySheet.show(context);
                    if (selectedGenre != null) {
                      setState(() => _selectedGenre = selectedGenre);
                      _performSearch(_searchController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Kategori",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedGenre.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Chip(
                label: Text(_selectedGenre),
                onDeleted: () {
                  setState(() => _selectedGenre = '');
                  _performSearch(_searchController.text);
                },
              ),
            ),

          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tidak ada novel ditemukan',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final novel = _searchResults[index].data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[900],
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
                      novel['title'] ?? 'Untitled',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          novel['author'] ?? 'Unknown Author',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          novel['genre'] ?? 'No Genre',
                          style: TextStyle(color: Colors.orange[400]),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.push('/novel/${_searchResults[index].id}', extra: {
                        ...novel,
                        'id': _searchResults[index].id,
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
