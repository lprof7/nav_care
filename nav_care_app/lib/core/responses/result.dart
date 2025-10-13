import 'failure.dart';

class Result<T> {
  final T? data;
  final Failure? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(Failure error) =>
      Result._(error: error, isSuccess: false);

  R fold<R>(
      {required R Function(Failure) onFailure,
      required R Function(T) onSuccess}) {
    return isSuccess && data != null
        ? onSuccess(data as T)
        : onFailure(error ?? const Failure.unknown());
  }
}
