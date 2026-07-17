//@GeneratedMicroModule;FeatureVisitorManagementPackageModule;package:feature_visitor_management/src/di/visitor_injection.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_visitor_management/src/domain/repositories/visitor_repository.dart'
    as _i914;
import 'package:feature_visitor_management/src/domain/usecases/check_in_visitor.dart'
    as _i902;
import 'package:injectable/injectable.dart' as _i526;

class FeatureVisitorManagementPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i902.CheckInVisitor>(
        () => _i902.CheckInVisitor(gh<_i914.VisitorRepository>()));
  }
}
