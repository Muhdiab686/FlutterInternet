import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:final_project/core/utils/app_router.dart';
import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/widgets/custom_progress_indicator.dart';
import 'package:final_project/features/show_files/data/repository/get_files_repo/get_files_repo_impl.dart';
import 'package:final_project/features/show_files/data/repository/upload_files_repo/upload_files_repo_impl.dart';
import 'package:final_project/features/show_files/presentation/manager/get_files_cubit/get_files_cubit.dart';
import 'package:final_project/features/show_files/presentation/manager/upload_file_cubit/upload_file_cubit.dart';

import 'package:final_project/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../manager/get_files_cubit/get_book_files_cubit.dart';
import 'widgets/files_body.dart';

class FilesBookScreen extends StatefulWidget {
  final int id;

  const FilesBookScreen({super.key, required this.id});

  @override
  State<FilesBookScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesBookScreen> {


  @override
  Widget build(BuildContext context) {
    context.read<GetBookFilesCubit>()
      .getFiles(token: prefs.getString('token')!, id: widget.id);
    return Scaffold(
      appBar: AppBar(title: Text("My Booking File"),),
      body: FilesBody(
        groupId: widget.id,
      ),
    );
  }
}
