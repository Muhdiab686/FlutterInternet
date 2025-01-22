part of 'get_book_files_cubit.dart';

sealed class GetBookFilesState extends Equatable {
  const GetBookFilesState();

  @override
  List<Object> get props => [];
}

final class GetBookFilesInitial extends GetBookFilesState {}

final class GetBookFilesFailure extends GetBookFilesState {
  final String errMessage;

  const GetBookFilesFailure(this.errMessage);
}

final class GetBookFilesSuccess extends GetBookFilesState {
  final GetBookFilesModel getFilesModel;

  const GetBookFilesSuccess(this.getFilesModel);
}

final class GetFilesLoading extends GetBookFilesState {}
