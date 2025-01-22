import 'dart:html';

import 'package:dartz/dartz.dart';
import 'package:final_project/core/errors/failures.dart';

abstract class CheckOutRepo {
  Future<Either<Failure, String>> checkout({
    required String token,
    required filename,
    required filebyte,

    required int id,
  });
}
