import 'package:injectable/injectable.dart';

/// Same micro-package trigger pattern as `core`'s
/// `core_injectable_init.dart` — needed even now, while this feature
/// has no annotated classes yet (domain layer + stub UI only), so the
/// wiring is already in place once the data/presentation layers land.
@InjectableInit.microPackage()
void configureGatePassDependencies() {}
