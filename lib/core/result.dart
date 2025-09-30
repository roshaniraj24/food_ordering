import 'package:dartz/dartz.dart';
import 'failures.dart';

typedef Result<T> = Either<Failure, T>;

// Helper functions for common operations
Result<T> success<T>(T data) => Right(data);
Result<T> failure<T>(Failure error) => Left(error);

// Extension methods for easier handling
extension ResultX<T> on Result<T> {
  bool get isSuccess => isRight();
  bool get isFailure => isLeft();
  
  T? get data => fold((l) => null, (r) => r);
  Failure? get error => fold((l) => l, (r) => null);
  
  Result<U> mapSuccess<U>(U Function(T) mapper) {
    return fold(
      (failure) => Left(failure),
      (success) => Right(mapper(success)),
    );
  }
}