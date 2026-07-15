import 'package:logger/logger.dart';

/// One logger instance, one format, for the whole app — so log output
/// from any of the 100+ screens/feature packages is consistent and
/// easy to filter in CI or a device console.
final appLogger = Logger(
  printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
);
