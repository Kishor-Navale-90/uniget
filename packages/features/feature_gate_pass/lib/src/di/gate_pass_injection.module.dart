//@GeneratedMicroModule;FeatureGatePassPackageModule;package:feature_gate_pass/src/di/gate_pass_injection.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_gate_pass/src/domain/repositories/gate_pass_repository.dart'
    as _i869;
import 'package:feature_gate_pass/src/domain/usecases/create_gate_pass_request.dart'
    as _i209;
import 'package:feature_gate_pass/src/domain/usecases/verify_gate_pass_at_gate.dart'
    as _i118;
import 'package:injectable/injectable.dart' as _i526;

class FeatureGatePassPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i209.CreateGatePassRequest>(
        () => _i209.CreateGatePassRequest(gh<_i869.GatePassRepository>()));
    gh.factory<_i118.VerifyGatePassAtGate>(
        () => _i118.VerifyGatePassAtGate(gh<_i869.GatePassRepository>()));
  }
}
