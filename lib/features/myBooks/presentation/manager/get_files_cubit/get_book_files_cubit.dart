import 'package:equatable/equatable.dart';
import 'package:final_project/features/show_files/data/models/get_files_model/get_files_model.dart';
import 'package:final_project/features/show_files/data/repository/get_files_repo/get_files_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/get_book_files_model/get_files_model.dart';
import '../../../data/repository/get_book_files_repo/get_book_files_repo.dart';

part 'get_book_files_state.dart';

class GetBookFilesCubit extends Cubit<GetBookFilesState> {
  final GetBookFilesRepo getFilesRepo;
  GetBookFilesCubit(this.getFilesRepo) : super(GetBookFilesInitial());

  Future<void> getFiles({required String token, required int id}) async {
    emit(GetFilesLoading());
    var data = await getFilesRepo.getBookFiles(token: token, id: id);
    data.fold((l) {
      emit(GetBookFilesFailure(l.eerMessage));
    }, (r) {
      emit(GetBookFilesSuccess(r));
    });
  }
}
