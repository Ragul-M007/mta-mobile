import 'package:flutter/material.dart';
import 'package:mta/utilities/strings.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Pdfviewer extends StatefulWidget {
  const Pdfviewer({Key? key}) : super(key: key);

  @override
  State<Pdfviewer> createState() => _PdfviewerState();
}

class _PdfviewerState extends State<Pdfviewer> {
  bool _isLoading = true;
  String? localPath;

  Future<void> loadDocument() async {
    final response = await http.get(Uri.parse(Strings.pdfDoc!));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      localPath = file.path;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0061b0),
        title: Text('MTA Konnect'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: localPath!),
    );
  }
}