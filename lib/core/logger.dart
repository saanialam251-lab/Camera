import 'dart:developer' as dev;

/// Lightweight logger  P4
/// Debug mode only for verbose; always log errors.
enum LogLevel { debug, info, warn, error }

class AppLogger {
  static bool verbose = false; // set true in debug overlay

  static void d(String tag, String msg) {
    if (verbose) _log(LogLevel.debug, tag, msg);
  }

  static void i(String tag, String msg) => _log(LogLevel.info, tag, msg);

  static void w(String tag, String msg) => _log(LogLevel.warn, tag, msg);

  static void e(String tag, String msg, [Object? error, StackTrace? stack]) {
    _log(LogLevel.error, tag, msg);
    if (error != null) {
      dev.log('$error', name: tag, error: error, stackTrace: stack);
    }
  }

  static void _log(LogLevel level, String tag, String msg) {
    final prefix = switch (level) {
      LogLevel.debug => 'D',
      LogLevel.info => 'I',
      LogLevel.warn => 'W',
      LogLevel.error => 'E',
    };
    dev.log('[$prefix] $msg', name: tag);
  }
}
