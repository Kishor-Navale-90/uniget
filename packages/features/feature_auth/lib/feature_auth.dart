/// Public surface of the auth feature package. The app shell only ever
/// imports this barrel — never `src/**` — which is what lets this
/// package's internals be refactored by one team without breaking
/// every other feature that depends on login state.
library feature_auth;

export 'src/domain/entities/user.dart';
export 'src/domain/repositories/auth_repository.dart';
export 'src/presentation/bloc/auth_bloc.dart';
export 'src/presentation/bloc/auth_event.dart';
export 'src/presentation/bloc/auth_state.dart';
export 'src/presentation/pages/login_page.dart';
export 'src/di/auth_injection.dart';
