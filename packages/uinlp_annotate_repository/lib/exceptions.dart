enum RepositoryExceptionType { unknown }

class RepositoryException implements Exception {
  final String message;
  final RepositoryExceptionType type;

  const RepositoryException({
    required this.message,
    this.type = RepositoryExceptionType.unknown,
  });

  String get description => switch (type) {
    RepositoryExceptionType.unknown => "Unknown error",
  };

  factory RepositoryException.fromCatch(Object exception) {
    if (exception is RepositoryException) {
      return exception;
    }
    return RepositoryException(
      message: exception.toString(),
      type: RepositoryExceptionType.unknown,
    );
  }
}
