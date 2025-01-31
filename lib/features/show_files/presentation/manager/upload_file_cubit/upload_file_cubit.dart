import 'dart:html';

import 'package:equatable/equatable.dart';
import 'package:final_project/features/show_files/data/repository/upload_files_repo/upload_files_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'upload_file_state.dart';

class UploadFileCubit extends Cubit<UploadFileState> {
  final UploadFilesRepo uploadFilesRepo;
  UploadFileCubit(this.uploadFilesRepo) : super(UploadFileInitial());

  Future<void> uploadFile(
      {required String token, required int id, required String filename, filebyte,}) async {
    emit(UploadFileLoading());
    var data = await uploadFilesRepo.uploadFile(
      token: token,
      id: id,
      filename: filename,
      filebyte:filebyte
    );
    data.fold((l) {
      emit(UploadFileFailure(l.eerMessage));
    }, (r) {
      emit(UploadFileSuccess(r));
    });
  }
}
