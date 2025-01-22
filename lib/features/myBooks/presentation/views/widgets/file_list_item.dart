import 'dart:html';

import 'package:final_project/core/utils/app_router.dart';
import 'package:final_project/features/show_files/data/models/get_files_model/datum.dart';
import 'package:final_project/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../show_files/data/models/check_in_files_model/file_link.dart';
import '../../../../show_files/presentation/views/check_out_screen.dart';
import '../../../data/models/get_book_files_model/datum.dart';

class FileBookListItem extends StatelessWidget {
  final DatumBook file;
  final int id;

  final int index;

  const FileBookListItem({
    required this.file,
    required this.index,
    super.key,
    required this.id,
  });

  Future<void> downloadFiles(FileLink fileLink) async {
    try {
      // Create an anchor element
      final anchor = AnchorElement(href: fileLink.downloadUrl)
         // Open the download in a new tab
        ..download ; // Specify the file name for download

      // Trigger the download
      anchor.click();

      // Remove the anchor element after clicking
      anchor.remove();

    } catch (e) {
      print("Error downloading file: $e");
    }

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Text(
                    index.toString() ?? "N/A",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                title: Text(
                  file.name ?? "No Name",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  "${S.of(context).status} ${file.status ?? "Unknown"}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
                trailing: IconButton(
                    onPressed: () {
                      downloadFiles(FileLink(downloadUrl: file.downloadUrl)).then((W){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>CheckOutScreen(id: file.id!)));
                      });

                    },
                    icon: Icon(Icons.download)
                )

            )));
  }
}
