import 'package:equatable/equatable.dart';

import 'visitor_status.dart';

class Visitor extends Equatable {
  const Visitor({
    required this.id,
    required this.name,
    required this.hostName,
    required this.status,
    this.meetingRoom,
    this.category = 'Guest',
    this.idVerified = false,
  });

  final String id;
  final String name;
  final String hostName;
  final VisitorStatus status;
  final String? meetingRoom;
  final String category; // Guest | Vendor | Interviewee | Contractor
  final bool idVerified;

  @override
  List<Object?> get props => [id, name, hostName, status, meetingRoom, category, idVerified];
}
