
import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/widgets/custom_error_widget.dart';
import 'package:final_project/core/widgets/custom_progress_indicator.dart';
import 'package:final_project/features/show_files/data/models/check_in_files_model/file_link.dart';
import 'package:final_project/features/show_files/data/repository/check_in_files_repository/check_in_files_repo_impl.dart';
import 'package:final_project/features/show_files/presentation/manager/check_in_files/check_in_files_cubit.dart';
import 'package:final_project/features/show_files/presentation/manager/get_files_cubit/get_files_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../manager/get_files_cubit/get_book_files_cubit.dart';
import 'file_list_item.dart';

class FilesList extends StatefulWidget {
  final int groupId;

  const FilesList({super.key, required this.groupId});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {



  int progress = 0;



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<GetBookFilesCubit, GetBookFilesState>(
          builder: (context, state) {
            if (state is GetBookFilesSuccess) {
              return ListView.builder(
                itemCount: state.getFilesModel.data!.length,
                itemBuilder: (context, index) {
                  final file = state.getFilesModel.data![index];

                  return FileBookListItem(
                    file: file,
                    index: index + 1,

                    id: state.getFilesModel.data![index].id!,
                  );
                },
              );
            }
            if (state is GetBookFilesFailure) {
              return ErrorWidgetWithRetry(errorMessage: state.errMessage);
            } else {
              return const CustomProgressIndicator();
            }
          },
        ),


      ],
    );
  }
}
