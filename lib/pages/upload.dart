import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:novella_app/services/firestore.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _firestoreService = FirestoreService();

  String? _selectedGenre;
  String? _tempPdfPath;
  String? _tempCoverPath;
  bool _isLoading = false;

  final List<String> _genres = [
    'Romance', 'Fantasy', 'Sci-Fi', 'Mystery', 'Horror',
    'Action', 'Drama', 'Comedy', 'Slice of Life', 'Historical',
  ];



  Future<void> _pickCover() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        // Get app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.${result.files.first.extension}';

        // Copy file to app directory
        File sourceFile = File(result.files.first.path!);
        File destinationFile = File('${appDir.path}/$fileName');
        await sourceFile.copy(destinationFile.path);

        setState(() {
          _tempCoverPath = destinationFile.path;
        });
      }
    } catch (e) {
      print('Error picking cover: $e');
      _showErrorSnackBar('Gagal memilih cover');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        // Get app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Copy file to app directory
        File sourceFile = File(result.files.first.path!);
        File destinationFile = File('${appDir.path}/$fileName');
        await sourceFile.copy(destinationFile.path);

        setState(() {
          _tempPdfPath = destinationFile.path;
        });
      }
    } catch (e) {
      print('Error picking PDF: $e');
      _showErrorSnackBar('Gagal memilih PDF');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tempCoverPath == null) {
      _showErrorSnackBar('Pilih cover novel');
      return;
    }

    if (_tempPdfPath == null) {
      _showErrorSnackBar('Pilih file PDF novel');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.addNovel(
        title: _titleController.text,
        author: _authorController.text,
        synopsis: _synopsisController.text,
        genre: _selectedGenre!,
        coverPath: _tempCoverPath!,
        pdfPath: _tempPdfPath!,
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        _tempCoverPath = null;
        _tempPdfPath = null;
        _selectedGenre = null;
      });
      _titleController.clear();
      _authorController.clear();
      _synopsisController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Novel berhasil dipublikasikan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting form: $e');
      _showErrorSnackBar('Gagal mempublikasikan novel');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tulis Novel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'Bagikan Novelmu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Isi detail novel yang akan kamu bagikan',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Cover Image Section
                  AspectRatio(
                    aspectRatio: 16/9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: InkWell(
                        onTap: _pickCover,
                        child: _tempCoverPath != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_tempCoverPath!),
                            fit: BoxFit.cover,
                          ),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload Cover Novel',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Judul Novel',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.book, color: Colors.grey[400]),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Judul tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 16),

                  // Author Field
                  TextFormField(
                    controller: _authorController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nama Penulis',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama penulis tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 16),

                  // Genre Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.grey[900],
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.category, color: Colors.grey[400]),
                    ),
                    items: _genres.map((String genre) {
                      return DropdownMenuItem(
                        value: genre,
                        child: Text(genre, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGenre = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Pilih genre novel' : null,
                  ),
                  SizedBox(height: 16),

                  // Synopsis Field
                  TextFormField(
                    controller: _synopsisController,
                    style: TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Sinopsis',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: Icon(Icons.description, color: Colors.grey[400]),
                      ),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Sinopsis tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 24),

                  // PDF Upload Section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 32, color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          'Upload File Novel (PDF)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_tempPdfPath != null) ...[
                          SizedBox(height: 8),
                          Text(
                            _tempPdfPath!.split('/').last,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickPdf,
                          icon: Icon(Icons.add, size: 18),
                          label: Text(
                            _tempPdfPath == null ? 'Pilih File' : 'Ganti File',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'Publikasikan Novel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up temporary files
    if (_tempCoverPath != null) {
      File(_tempCoverPath!).delete().catchError((e) => print('Error deleting cover: $e'));
    }
    if (_tempPdfPath != null) {
      File(_tempPdfPath!).delete().catchError((e) => print('Error deleting PDF: $e'));
    }

    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }
}