import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:pdf_render/pdf_render.dart'; // Import pdf_render package
import 'PDF_Screen.dart'; // Ensure this import is correct

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<String>> _pdfFilesFuture;
  List<String> _allPdfFiles = ['asset/Unit-1.pdf', 'asset/Rent_payble.pdf', 'asset/Unit-2.pdf'];
  List<String> _filteredPdfFiles = [];
  TextEditingController _searchController = TextEditingController();
  String _sortOption = 'name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    _pdfFilesFuture = _loadPdfFiles();
    _searchController.addListener(_filterPdfFiles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> _loadPdfFiles() async {
    List<String> pdfFiles = _allPdfFiles;

    // Load PDFs from external storage directory if accessible
    try {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        List<FileSystemEntity> files = directory.listSync(recursive: true, followLinks: false);
        List<String> externalPdfFiles = files
            .where((file) => file.path.endsWith('.pdf'))
            .map((file) => file.path)
            .toList();

        if (externalPdfFiles.isNotEmpty) {
          pdfFiles.addAll(externalPdfFiles);
        }
      }
    } catch (e) {
      print("Error accessing external storage: $e");
    }

    _allPdfFiles = pdfFiles;
    _filteredPdfFiles = pdfFiles;
    _sortPdfFiles(); // Sort the files initially
    return pdfFiles;
  }

  void _filterPdfFiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPdfFiles = _allPdfFiles
          .where((file) => file.toLowerCase().contains(query))
          .toList();
      _sortPdfFiles(); // Sort the filtered files
    });
  }

  void _sortPdfFiles() {
    setState(() {
      if (_sortOption == 'name') {
        _filteredPdfFiles.sort((a, b) => a.split('/').last.compareTo(b.split('/').last));
      } else if (_sortOption == 'date') {
        _filteredPdfFiles.sort((a, b) {
          FileStat aStat = FileStat.statSync(a);
          FileStat bStat = FileStat.statSync(b);
          return bStat.modified.compareTo(aStat.modified);
        });
      }
    });
  }

  // Function to get the page count of a PDF using the pdf_render package
  Future<int> _getPdfPageCount(String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);  // Open the PDF file
      return document.pageCount; // Get the page count from the document
    } catch (e) {
      print("Error getting PDF page count: $e");
      return 0; // Return 0 if an error occurs
    }
  }

  void _viewPdf(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewer(filePath: filePath),
      ),
    );
  }

  void _deletePdf(int index) {
    setState(() {
      _filteredPdfFiles.removeAt(index);
    });
  }

  void _sharePdf(String filePath) {
    Share.shareFiles([filePath], text: 'Check out this PDF!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          title: Center(
            child: Text("PDF Reader", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search PDF",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortOption,
                  icon: Icon(Icons.sort, color: Colors.black),
                  dropdownColor: Colors.redAccent,
                  underline: Container(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortOption = newValue!;
                      _sortPdfFiles();
                    });
                  },
                  items: <String>['name', 'date']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase(), style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _pdfFilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading PDF files'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No PDF files found'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredPdfFiles.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<int>(
                        future: _getPdfPageCount(_filteredPdfFiles[index]),
                        builder: (context, pageSnapshot) {
                          String pageCount = "Loading...";
                          if (pageSnapshot.connectionState == ConnectionState.done && pageSnapshot.hasData) {
                            pageCount = "Pages: ${pageSnapshot.data}";
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                              title: Text(
                                _filteredPdfFiles[index].split('/').last,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                pageCount, // Dynamic page number
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Share') {
                                    _sharePdf(_filteredPdfFiles[index]);
                                  } else if (value == 'Delete') {
                                    _deletePdf(index);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'Share',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, color: Colors.black),
                                        SizedBox(width: 8),
                                        Text('Share'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.black),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _viewPdf(_filteredPdfFiles[index]),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
