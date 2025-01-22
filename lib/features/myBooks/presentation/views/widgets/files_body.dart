
import 'package:flutter/material.dart';

import 'files_list.dart';

class FilesBody extends StatelessWidget {
  final int groupId;
  const FilesBody({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FilesList(
        groupId: groupId,
      ),
    );
  }
}
