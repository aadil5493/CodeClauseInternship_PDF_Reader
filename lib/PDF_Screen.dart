import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewer extends StatelessWidget {
  final String filePath;

  PdfViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filePath.split('/').last),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {
          print("Document rendered, number of pages: $_pages");
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('Error on page $page: $error');
        },
      ),
    );
  }
}
