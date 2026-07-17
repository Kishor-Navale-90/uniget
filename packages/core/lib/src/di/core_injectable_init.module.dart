//@GeneratedMicroModule;CorePackageModule;package:core/src/di/core_injectable_init.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:core/src/audit/audit_logger.dart' as _i830;
import 'package:core/src/auth/session.dart' as _i98;
import 'package:core/src/database/app_database.dart' as _i904;
import 'package:core/src/di/core_module.dart' as _i748;
import 'package:core/src/network/dio_client.dart' as _i182;
import 'package:core/src/network/interceptors/auth_interceptor.dart' as _i729;
import 'package:core/src/network/interceptors/logging_interceptor.dart'
    as _i614;
import 'package:core/src/network/interceptors/retry_interceptor.dart' as _i123;
import 'package:core/src/network/network_info.dart' as _i272;
import 'package:core/src/notifications/push_notification_service.dart' as _i363;
import 'package:core/src/sync/connectivity_service.dart' as _i615;
import 'package:core/src/sync/sync_engine.dart' as _i906;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

class CorePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final databaseModule = _$DatabaseModule();
    final coreModule = _$CoreModule();
    final notificationModule = _$NotificationModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i904.AppDatabase>(() => databaseModule.database());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => coreModule.secureStorage);
    gh.lazySingleton<_i895.Connectivity>(() => coreModule.connectivity);
    gh.lazySingleton<_i454.SupabaseClient>(() => coreModule.supabaseClient);
    gh.lazySingleton<_i614.LoggingInterceptor>(
        () => _i614.LoggingInterceptor());
    gh.lazySingleton<_i123.RetryInterceptor>(() => _i123.RetryInterceptor());
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => notificationModule.firebaseMessaging);
    gh.lazySingleton<_i363.PushNotificationService>(
        () => _i363.PushNotificationService(gh<_i892.FirebaseMessaging>()));
    gh.lazySingleton<_i98.SessionManager>(
        () => _i98.SessionManager(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i729.AuthInterceptor>(
        () => _i729.AuthInterceptor(gh<_i98.SessionManager>()));
    gh.lazySingleton<_i272.NetworkInfo>(
        () => _i272.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i830.AuditLogger>(
        () => _i830.AuditLogger(gh<_i904.AppDatabase>()));
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio(
          gh<_i729.AuthInterceptor>(),
          gh<_i123.RetryInterceptor>(),
          gh<_i614.LoggingInterceptor>(),
        ));
    gh.lazySingleton<_i615.ConnectivityService>(
        () => _i615.ConnectivityService(gh<_i272.NetworkInfo>()));
    gh.lazySingleton<_i906.SyncEngine>(() => _i906.SyncEngine(
          gh<_i904.AppDatabase>(),
          gh<_i615.ConnectivityService>(),
        ));
  }
}

class _$DatabaseModule extends _i904.DatabaseModule {}

class _$CoreModule extends _i748.CoreModule {}

class _$NotificationModule extends _i363.NotificationModule {}

class _$NetworkModule extends _i182.NetworkModule {}
