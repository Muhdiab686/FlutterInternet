import 'package:equatable/equatable.dart';

import 'datum.dart';

class GetBookFilesModel extends Equatable {
  final List<DatumBook>? data;

  const GetBookFilesModel({this.data});

  factory GetBookFilesModel.fromJson(Map<String, dynamic> json) => GetBookFilesModel(
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => DatumBook.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'data': data?.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [data];
}
