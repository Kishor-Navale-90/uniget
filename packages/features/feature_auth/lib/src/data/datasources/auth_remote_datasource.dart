import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> checkRegistrationEmail(String email);
  Future<void> requestRegistrationOtp(String email);
  Future<void> verifyRegistrationOtp({required String email, required String otp});
  Future<(UserModel, String token)> setPassword({required String password});
  Future<(UserModel, String token)> loginWithPassword({required String email, required String password});

  /// Null if there is no persisted session, or it no longer validates
  /// against Supabase (expired/revoked) — backs `GET /v1/auth/me`.
  Future<(UserModel, String token)?> getCurrentUser();
  Future<void> logout();
}

/// Talks to Supabase directly via `supabase_flutter` (see
/// `supabase/README.md` for the schema/RPCs/Edge Function this maps
/// onto) rather than a hand-rolled REST client — session persistence,
/// refresh, and the `Authorization` header on every Postgrest/Functions
/// call are handled by the SDK itself.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<void> checkRegistrationEmail(String email) async {
    final eligible = await _call(
      () => _supabase.rpc<bool>('is_eligible_for_registration', params: {'p_email': email}),
    );
    if (!eligible) {
      throw ServerException(
        'This email is not registered, or the account is already active.',
        statusCode: 422,
      );
    }
  }

  @override
  Future<void> requestRegistrationOtp(String email) => _call(
        () => _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false),
      );

  @override
  Future<void> verifyRegistrationOtp({required String email, required String otp}) => _call(
        () => _supabase.auth.verifyOTP(email: email, token: otp, type: OtpType.email),
      );

  @override
  Future<(UserModel, String token)> setPassword({required String password}) => _call(() async {
        await _supabase.auth.updateUser(UserAttributes(password: password));
        return _currentUserAndToken();
      });

  @override
  Future<(UserModel, String token)> loginWithPassword({
    required String email,
    required String password,
  }) =>
      _call(() async {
        await _supabase.auth.signInWithPassword(email: email, password: password);
        return _currentUserAndToken();
      });

  @override
  Future<(UserModel, String token)?> getCurrentUser() async {
    if (_supabase.auth.currentSession == null) return null;
    try {
      // Round-trips to GoTrue so a stale/revoked session is caught
      // here rather than silently trusted from local storage.
      await _supabase.auth.getUser();
      return await _currentUserAndToken();
    } on AuthException {
      return null;
    }
  }

  @override
  Future<void> logout() => _call(() => _supabase.auth.signOut());

  Future<(UserModel, String token)> _currentUserAndToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw ServerException('No active session.', statusCode: 401);
    }
    // Deliberately not `.maybeSingle()`: postgrest-dart only swallows a
    // 0-row PGRST116 into `null` by matching the exact substring
    // "Results contain 0 rows" in the error, and some PostgREST
    // versions phrase it differently (e.g. "The result contains 0
    // rows") — reading the raw array and checking emptiness ourselves
    // doesn't depend on that wording at all.
    final rows = await _supabase.rpc<List<dynamic>>('get_my_profile');
    if (rows.isEmpty) {
      throw ServerException('No employee profile found for this account.', statusCode: 404);
    }
    return (UserModel.fromProfile(rows.first as Map<String, dynamic>), session.accessToken);
  }

  Future<T> _call<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on AuthException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? ''));
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
