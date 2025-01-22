import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/check_in_files_model/file_link.dart';
import '../check_out_screen.dart';

class DownloadFile extends StatefulWidget {
  final List<FileLink> files;

  DownloadFile({super.key, required this.files});

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  Future<void> downloadFiles(FileLink fileLink) async {
    // الحصول على المسار إلى مجلد المستندات
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    final url = fileLink.downloadUrl;
    print(url);
    if (url != null) {
      if (Platform.isWindows) {
        // فتح الرابط في متصفح Windows
        Process.start('cmd', ['/c', 'start', url]);
      } else {
        // بالنسبة لأنظمة أخرى (مثل iOS/Android) استخدم url_launcher
        if (await canLaunch(url)) {
          await launch(url);

        } else {
          print("Could not launch URL: $url");
        }
      }
    } else {
      print("Download URL is null for file ID: ${fileLink.fileId}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Files'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.files.length,
          itemBuilder: (context, index) {
            final file = widget.files[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => downloadFiles(file).then((W){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>CheckOutScreen(id: file.fileId!)));
                }),
                child: Text('Download File ${index + 1}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
