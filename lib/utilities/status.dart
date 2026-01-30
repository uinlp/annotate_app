abstract class Status<T> {
  final T? data;
  final dynamic event;
  const Status({this.data, this.event});
}

class IdleStatus extends Status<void> {
  const IdleStatus({super.event});
}

class LoadingStatus extends Status<String> {
  const LoadingStatus({super.data = 'Loading...', super.event});
}

class SuccessStatus<T> extends Status<T> {
  const SuccessStatus({super.data, super.event});
}

class ErrorStatus<T> extends Status<T> {
  const ErrorStatus({required super.data, super.event});
}
