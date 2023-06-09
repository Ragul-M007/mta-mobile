import 'package:flutter/material.dart';
import 'package:mta/utilities/strings.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';


class Pdfviewer extends StatefulWidget {
  const Pdfviewer({ Key? key }) : super(key: key);

  @override
  State<Pdfviewer> createState() => _PdfviewerState();
}

class _PdfviewerState extends State<Pdfviewer> {


   bool _isLoading = true;
  PDFDocument? document;
  
   loadDocument() async {
     
    document = await PDFDocument.fromURL(Strings.pdfDoc!);

    setState(() => _isLoading = false);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDocument();
  }
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0061b0),
        title: Text('MTA Konnect'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: document!)),
    );
  }
}