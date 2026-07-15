import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

@injectable
class CheckInVisitor implements UseCase<Visitor, CheckInVisitorParams> {
  CheckInVisitor(this._repository);
  final VisitorRepository _repository;

  @override
  Future<Either<Failure, Visitor>> call(CheckInVisitorParams params) => _repository.checkIn(
        name: params.name,
        hostId: params.hostId,
        category: params.category,
      );
}

class CheckInVisitorParams extends Equatable {
  const CheckInVisitorParams({required this.name, required this.hostId, required this.category});

  final String name;
  final String hostId;
  final String category;

  @override
  List<Object?> get props => [name, hostId, category];
}
