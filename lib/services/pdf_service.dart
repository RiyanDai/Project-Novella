import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/novel.dart';
import '../models/chapter.dart';

class PdfService {
  Future<File> generateNovelPdf(Novel novel, List<Chapter> chapters) async {
    final pdf = pw.Document();

    // Add cover page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                novel.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'oleh',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                novel.author,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Add table of contents
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Daftar Isi',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            ...chapters.map((chapter) => pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    chapter.title,
                    style: pw.TextStyle(fontSize: 12),
                  ),
                )),
          ],
        ),
      ),
    );

    // Add chapters
    for (var chapter in chapters) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                chapter.title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                chapter.content,
                style: pw.TextStyle(
                  fontSize: 12,
                  lineSpacing: 1.5,
                ),
                textAlign: pw.TextAlign.justify,
              ),
            ],
          ),
        ),
      );
    }

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${novel.title.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
} 