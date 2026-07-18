import 'package:core/core.dart';

import '../../domain/entities/user.dart';

/// Maps the API's JSON shape onto the domain entity. Kept separate
/// from `AppUser` on purpose: if the backend renames a field or wraps
/// the response differently, only this file changes — domain and
/// presentation code are untouched.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
  });

  /// Parses the row shape returned by Supabase's `get_my_profile` RPC
  /// (see `supabase/migrations/20260717000003_profile_rpc.sql`) —
  /// snake_case column names, unlike the REST mock contract's
  /// camelCase, since this comes straight from Postgres rather than a
  /// hand-written JSON response.
  factory UserModel.fromProfile(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.byName(json['role'] as String),
        departmentId: json['department_id'] as String?,
        departmentName: json['department_name'] as String?,
      );

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? departmentId;
  final String? departmentName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'departmentId': departmentId,
        'departmentName': departmentName,
      };

  AppUser toEntity() => AppUser(
        id: id,
        name: name,
        email: email,
        role: role,
        departmentId: departmentId,
        departmentName: departmentName,
      );
}
