class Failure {
  final String message;
  final String? code;
  final int? statusCode;
  final FailureType type;

  const Failure._(this.type,
      {required this.message, this.code, this.statusCode});

  const Failure.network({String message = 'Network error', int? statusCode})
      : this._(FailureType.network, message: message, statusCode: statusCode);

  const Failure.server(
      {String message = 'Server error', String? code, int? statusCode})
      : this._(FailureType.server,
            message: message, code: code, statusCode: statusCode);

  const Failure.unauthorized({String message = 'Unauthorized'})
      : this._(FailureType.unauthorized, message: message);

  const Failure.validation({String message = 'Validation error'})
      : this._(FailureType.validation, message: message);

  const Failure.timeout({String message = 'Request timeout'})
      : this._(FailureType.timeout, message: message);

  const Failure.cancelled({String message = 'Request cancelled'})
      : this._(FailureType.cancelled, message: message);

  const Failure.unknown({String message = 'Unknown error'})
      : this._(FailureType.unknown, message: message);
}

enum FailureType {
  network,
  server,
  unauthorized,
  validation,
  timeout,
  cancelled,
  unknown
}
