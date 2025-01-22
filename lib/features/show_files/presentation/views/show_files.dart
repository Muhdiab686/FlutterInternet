import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:final_project/core/utils/app_router.dart';
import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/widgets/custom_progress_indicator.dart';
import 'package:final_project/features/show_files/data/repository/get_files_repo/get_files_repo_impl.dart';
import 'package:final_project/features/show_files/data/repository/upload_files_repo/upload_files_repo_impl.dart';
import 'package:final_project/features/show_files/presentation/manager/get_files_cubit/get_files_cubit.dart';
import 'package:final_project/features/show_files/presentation/manager/upload_file_cubit/upload_file_cubit.dart';
import 'package:final_project/features/show_files/presentation/views/widgets/files_body.dart';
import 'package:final_project/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import '../../../myBooks/presentation/views/show_book_files.dart';

class FilesScreen extends StatefulWidget {
  final int id;

  const FilesScreen({super.key, required this.id});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  String filename="";
  var filebyte;// المتغير الذي سيحتوي على الملف المختار
  Future<void> selectFile() async {
    try {
      // Pick the file using FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'], // Allow only .txt and .pdf files
      );

      if (result != null) {
        // For web, the picked file can be accessed using `result.files`
        PlatformFile file = result.files.single;

        // Example: You can read the file's bytes or display its name
        print('Picked file: ${file.name}');
        print('File size: ${file.size} bytes');

        // If you want to allow file downloads:

setState(() {
  filename=file.name;
  filebyte=file.bytes!;

});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picked: ${file.name}')),
        );
      }
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<GetFilesCubit>().getFiles(token: prefs.getString('token')!, id: widget.id);
    return MultiBlocProvider(
        providers: [

          BlocProvider(
            create: (context) =>
                UploadFileCubit(getIt.get<UploadFilesRepoImpl>()),
          )
        ],
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                ),
              ),
              title: Text(
                S.of(context).files,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      AppRouter.kFilesRequest,
                      extra: widget.id,
                    );
                  },

                  icon: const Icon(
                    Icons.upload,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=>FilesBookScreen(id: widget.id,))).then((r){
                      r.read<GetFilesCubit>().getFiles(token: prefs.getString('token')!, id: widget.id);

                    });

                  },
                  icon: const Icon(
                    Icons.check,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      AppRouter.kUsersToInvite,
                      extra: widget.id,
                    );
                  },
                  icon: const Icon(
                    Icons.group_add,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications,
                  ),
                ),
              ],
            ),
            body: FilesBody(
              groupId: widget.id,
            ),
            floatingActionButton:
                BlocConsumer<UploadFileCubit, UploadFileState>(
              listener: (context, state) {
                if (state is UploadFileSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is UploadFileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errMessage)),
                  );
                }
              },
              builder: (context, state) {
                // if (state is UploadFileLoading) {
                //   return const CustomProgressIndicator();
                // }

                return FloatingActionButton(
                  onPressed: () async {
                    if (filename == "") {
                      // إذا لم يتم اختيار ملف، افتح نافذة اختيار الملف
                      await selectFile();
                    } else {
                      // إذا تم اختيار ملف، ارفع الملف
                      context
                          .read<UploadFileCubit>()
                          .uploadFile(
                            token: prefs.getString('token')!,
                            id: widget.id,
                            filename: filename!,
                        filebyte: filebyte
                          ).then((e){
                        context.read<GetFilesRepoImpl>().getFiles(
                            token: prefs.getString('token')!, id: widget.id);
                      });


                      setState(() {
                        filename == ""; // إعادة تعيين الملف بعد الرفع
                      });
                    }
                  },
                  child: Icon(
                      filename == "" ? Icons.add : Icons.cloud_upload),
                );
              },
            )));
  }
}
