//@GeneratedMicroModule;FeatureAuthPackageModule;package:feature_auth/src/di/auth_injection.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:core/core.dart' as _i494;
import 'package:feature_auth/src/data/datasources/auth_local_datasource.dart'
    as _i928;
import 'package:feature_auth/src/data/datasources/auth_remote_datasource.dart'
    as _i337;
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart'
    as _i953;
import 'package:feature_auth/src/domain/repositories/auth_repository.dart'
    as _i1063;
import 'package:feature_auth/src/domain/usecases/check_registration_email.dart'
    as _i712;
import 'package:feature_auth/src/domain/usecases/get_current_session.dart'
    as _i480;
import 'package:feature_auth/src/domain/usecases/login_with_password.dart'
    as _i590;
import 'package:feature_auth/src/domain/usecases/request_registration_otp.dart'
    as _i915;
import 'package:feature_auth/src/domain/usecases/set_password.dart' as _i375;
import 'package:feature_auth/src/domain/usecases/verify_registration_otp.dart'
    as _i741;
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart' as _i1014;
import 'package:feature_auth/src/presentation/bloc/login/login_bloc.dart'
    as _i954;
import 'package:feature_auth/src/presentation/bloc/registration/registration_bloc.dart'
    as _i963;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

class FeatureAuthPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i337.AuthRemoteDataSource>(
        () => _i337.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i928.AuthLocalDataSource>(
        () => _i928.AuthLocalDataSourceImpl(gh<_i494.SessionManager>()));
    gh.lazySingleton<_i1063.AuthRepository>(() => _i953.AuthRepositoryImpl(
          gh<_i337.AuthRemoteDataSource>(),
          gh<_i928.AuthLocalDataSource>(),
          gh<_i494.SessionManager>(),
          gh<_i494.NetworkInfo>(),
        ));
    gh.factory<_i915.RequestRegistrationOtp>(
        () => _i915.RequestRegistrationOtp(gh<_i1063.AuthRepository>()));
    gh.factory<_i480.GetCurrentSession>(
        () => _i480.GetCurrentSession(gh<_i1063.AuthRepository>()));
    gh.factory<_i480.Logout>(() => _i480.Logout(gh<_i1063.AuthRepository>()));
    gh.factory<_i712.CheckRegistrationEmail>(
        () => _i712.CheckRegistrationEmail(gh<_i1063.AuthRepository>()));
    gh.factory<_i590.LoginWithPassword>(
        () => _i590.LoginWithPassword(gh<_i1063.AuthRepository>()));
    gh.factory<_i375.SetPassword>(
        () => _i375.SetPassword(gh<_i1063.AuthRepository>()));
    gh.factory<_i741.VerifyRegistrationOtp>(
        () => _i741.VerifyRegistrationOtp(gh<_i1063.AuthRepository>()));
    gh.factory<_i963.RegistrationBloc>(() => _i963.RegistrationBloc(
          gh<_i712.CheckRegistrationEmail>(),
          gh<_i915.RequestRegistrationOtp>(),
          gh<_i741.VerifyRegistrationOtp>(),
          gh<_i375.SetPassword>(),
        ));
    gh.factory<_i1014.AuthBloc>(() => _i1014.AuthBloc(
          gh<_i480.GetCurrentSession>(),
          gh<_i480.Logout>(),
        ));
    gh.factory<_i954.LoginBloc>(
        () => _i954.LoginBloc(gh<_i590.LoginWithPassword>()));
  }
}
