import 'package:auth_system/utils/extenstions.dart';
import 'package:relic/relic.dart';

Middleware customLogger({final Logger? logger}) {
  return (final next) {
    final localLogger = logger ?? logMessage;

    return (final req) async {
      final startTime = DateTime.now();
      final watch = Stopwatch()..start();
      try {
        final result = await next(req);
        final msg = switch (result) {
          final Response rc => '${rc.statusCode}',
          final Hijack _ => 'hijacked',
          final WebSocketUpgrade _ => 'connected',
        };

        localLogger(_message(startTime, req, watch.elapsed, msg));
        return result;
      } catch (error, stackTrace) {
        localLogger(
          _errorMessage(startTime, req, watch.elapsed, error),
          type: LoggerType.error,
          stackTrace: stackTrace,
        );

        rethrow;
      }
    };
  };
}

String _formatQuery(final String query) {
  return query == '' ? '' : '?$query';
}

String _message(
  final DateTime requestTime,
  final Request request,
  final Duration elapsedTime,
  final String message,
) {
  final method = request.method.value;
  final url = request.url;
  final body = request.bodyAsJson; /* Throws a Bad state: The 'read' method can only be called once on a Request/Response object */

  return '${requestTime.toIso8601String()} '
      '${elapsedTime.toString().padLeft(15)} '
      '${method.padRight(7)} [$message] ' // 7 - longest standard HTTP method
      '${url.path}${_formatQuery(url.query)}'
      '${body} ${request.headers}';
}

String _errorMessage(
  final DateTime requestTime,
  final Request request,
  final Duration elapsedTime,
  final Object error,
) {
  return _message(requestTime, request, elapsedTime, 'ERROR: $error', );
}
