import 'dart:io';

import 'package:dio/dio.dart';
import 'package:final_project/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/widgets/custom_error_widget.dart';
import 'package:final_project/core/widgets/custom_progress_indicator.dart';
import 'package:final_project/features/show_files/data/models/check_in_files_model/file_link.dart';
import 'package:final_project/features/show_files/data/repository/check_in_files_repository/check_in_files_repo_impl.dart';
import 'package:final_project/features/show_files/presentation/manager/check_in_files/check_in_files_cubit.dart';
import 'package:final_project/features/show_files/presentation/manager/get_files_cubit/get_files_cubit.dart';
import 'package:final_project/features/show_files/presentation/views/widgets/file_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../myBooks/presentation/views/show_book_files.dart';
import 'download_file.dart';

class FilesList extends StatefulWidget {
  final int groupId;

  const FilesList({super.key, required this.groupId});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  final List<int> selectedFileIds = []; // قائمة لتخزين id الملفات المحددة

  Future<void> _refreshFiles(BuildContext context) async {
    await context.read<GetFilesCubit>().getFiles(
          token: prefs.getString('token')!,
          id: widget.groupId,
        );
  }

  int progress = 0;



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<GetFilesCubit, GetFilesState>(
          builder: (context, state) {
            if (state is GetFilesSuccess) {
              return RefreshIndicator(
                onRefresh: () => _refreshFiles(context),
                child: ListView.builder(
                  itemCount: state.getFilesModel.data!.length,
                  itemBuilder: (context, index) {
                    final file = state.getFilesModel.data![index];
                    final isSelected = selectedFileIds.contains(file.id);
                    return FileListItem(
                      file: file,
                      index: index + 1,
                      isSelected: isSelected,
                      onSelect: (id) {
                        setState(() {
                          if (isSelected) {
                            selectedFileIds.remove(id);
                          } else {
                            selectedFileIds.add(id);
                          }
                        });
                      },
                      id: state.getFilesModel.data![index].id!,
                    );
                  },
                ),
              );
            }
            if (state is GetFilesFailure) {
              return ErrorWidgetWithRetry(errorMessage: state.errMessage);
            } else {
              return const CustomProgressIndicator();
            }
          },
        ),
        if (selectedFileIds.isNotEmpty) // إظهار الزر إذا كانت القائمة غير فارغة
          BlocProvider(
            create: (context) =>
                CheckInFilesCubit(getIt.get<CheckInFilesRepoImpl>()),
            child: BlocConsumer<CheckInFilesCubit, CheckInFilesState>(
                listener: (context, state) {
              if (state is CheckInFilesFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is CheckInFilesSuccess) {


                Navigator.of(context).push(MaterialPageRoute(builder: (_)=>FilesBookScreen(id: widget.groupId,))).then(
                    (r){



                    }
                );
                context.read<GetFilesCubit>().getFiles(token: prefs.getString('token')!, id: widget.groupId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.checkInFilesModel.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }, builder: (context, state) {
              if (progress > 0) {
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    value: progress / 100, // تأكد من تقسيم النسبة على 100
                    minHeight: 10,
                  ),
                );
              }

              return state is CheckInFilesLoading
                  ? const CustomProgressIndicator()
                  : Positioned(
                      bottom: 1,
                      left: 1,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          context.read<CheckInFilesCubit>().checkInFiles(
                                token: prefs.getString('token')!,
                                list: selectedFileIds,
                              );
                        },
                        child: const Icon(Icons.check),
                      ),
                    );
            }),
          ),
      ],
    );
  }
}
