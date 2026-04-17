import 'package:logger/logger.dart';

/// Logger de Beedle, taggé par composant.
class Log {
  Log.named(this.name)
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 100,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );

  final String name;
  final Logger _logger;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d('[$name] $message', error: error, stackTrace: stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i('[$name] $message', error: error, stackTrace: stackTrace);
  }

  void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w('[$name] $message', error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e('[$name] $message', error: error, stackTrace: stackTrace);
  }
}
