import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/widgets/custom_progress_indicator.dart';
import 'package:final_project/features/myBooks/presentation/views/show_book_files.dart';
import 'package:final_project/features/show_files/data/repository/check_out_file_repository/check_out_repo_impl.dart';
import 'package:final_project/features/show_files/data/repository/check_out_without_file_repository/check_out_without_file_repo_impl.dart';
import 'package:final_project/features/show_files/presentation/manager/check_out_cubit/check_out_cubit.dart';
import 'package:final_project/features/show_files/presentation/manager/check_out_without_file/check_out_without_file_cubit.dart';
import 'package:final_project/features/show_files/presentation/views/show_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/get_files_cubit/get_files_cubit.dart';

class CheckOutScreen extends StatefulWidget {
  final int id;
  const CheckOutScreen({super.key, required this.id});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
String filename="";
var filebyte;// المتغير الذي سيحتوي على الملف المختار

  Future<void> selectFile() async {
    try {
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
          filebyte=file.bytes!;
          filename=file.name;

        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckOutCubit(getIt.get<CheckOutRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Checkout Screen"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // معلومات عن الملف المختار
              if (filename != "") ...[
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: const Text(
                      "Selected File",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                     filename,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          filename == "" ;
                        });
                      },
                    ),
                  ),
                ),
              ] else
                const Center(
                  child: Text(
                    "No file selected",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),
              // زر اختيار الملف
              ElevatedButton.icon(
                onPressed: () => selectFile(),
                icon: const Icon(Icons.file_open),
                label: const Text("Select File"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              // زر رفع الملف
              BlocConsumer<CheckOutCubit, CheckOutState>(
                listener: (context, state) {
                  if (state is CheckOutFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  if (state is CheckOutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),

                    );
                  }
                },
                builder: (context, state) {
                  if (state is CheckOutLoading) {
                    return const CustomProgressIndicator();
                  } else {
                    return ElevatedButton.icon(
                      onPressed: filename == ""
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Uploading file...")),
                              );
                              context.read<CheckOutCubit>().checkout(
                                    token: prefs.getString('token')!,
                                    filename: filename!,
                                    filebyte:filebyte ,
                                    id: widget.id,
                                  );
                            },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Upload File"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // زر متابعة بدون ملف
              BlocProvider(
                create: (context) => CheckOutWithoutFileCubit(
                    getIt.get<CheckOutWithoutFileRepoImpl>()),
                child: BlocConsumer<CheckOutWithoutFileCubit,
                    CheckOutWithoutFileState>(
                  listener: (context, state) {
                    if (state is CheckOutWithoutFileFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    if (state is CheckOutWithoutFileSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CheckOutWithoutFileLoading) {
                      return const CustomProgressIndicator();
                    } else {
                      return ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<CheckOutWithoutFileCubit>()
                              .checkoutWithoutFile(
                                  token: prefs.getString('token')!,
                                  id: widget.id).then((W){

                                      Navigator.of(context).pop();



                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Checkout Without File"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
