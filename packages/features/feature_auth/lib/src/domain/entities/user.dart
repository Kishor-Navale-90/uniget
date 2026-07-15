import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Domain entity — plain Dart, no JSON/DB annotations. The
/// data-layer `UserModel` (in data/models) maps API/DB shapes onto
/// this; nothing outside the auth feature's data layer ever imports
/// UserModel directly.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? departmentId;
  final String? departmentName;

  @override
  List<Object?> get props => [id, name, email, role, departmentId, departmentName];
}
