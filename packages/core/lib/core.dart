/// Barrel file — every feature package imports `package:core/core.dart`
/// and never reaches into `src/` directly. This is the enforced public
/// surface of the core package; keep it curated on purpose.
library core;

export 'src/error/failures.dart';
export 'src/error/exceptions.dart';
export 'src/usecase/usecase.dart';
export 'src/network/network_info.dart';
export 'src/network/dio_client.dart';
export 'src/notifications/push_notification_service.dart';
export 'src/audit/audit_event_table.dart';
export 'src/audit/audit_logger.dart';
export 'src/database/app_database.dart';
export 'src/database/sqlite_connection.dart';
export 'src/sync/sync_engine.dart';
export 'src/sync/sync_task.dart';
export 'src/sync/connectivity_service.dart';
export 'src/di/core_injectable_init.dart';
export 'src/di/core_injectable_init.module.dart';
export 'src/di/core_module.dart';
export 'src/auth/session.dart';
export 'src/routing/route_guard.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/responsive.dart';
export 'src/constants/app_constants.dart';
export 'src/utils/logger.dart';
export 'src/utils/result_extensions.dart';
