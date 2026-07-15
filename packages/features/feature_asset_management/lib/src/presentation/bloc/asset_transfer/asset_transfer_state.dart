import 'package:equatable/equatable.dart';

enum AssetTransferStatus { idle, submitting, queuedOffline, submitted, failure }

class AssetTransferState extends Equatable {
  const AssetTransferState({this.status = AssetTransferStatus.idle, this.errorMessage});

  final AssetTransferStatus status;
  final String? errorMessage;

  AssetTransferState copyWith({AssetTransferStatus? status, String? errorMessage}) =>
      AssetTransferState(status: status ?? this.status, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}
