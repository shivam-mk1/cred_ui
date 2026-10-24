import 'package:equatable/equatable.dart';

sealed class AppFailure extends Equatable {
  const AppFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NoInternetFailure extends AppFailure {
  const NoInternetFailure([
    super.message = 'No internet connection. Please check your network and try again.',
  ]);
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message = 'Connection timed out. Please try again.',
  ]);
}

final class RateLimitFailure extends AppFailure {
  const RateLimitFailure([
    super.message = 'API rate limit reached (5 requests/window). Please wait a few seconds and retry.',
  ]);
}

final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Server error occurred. Please try again later.',
  ]);
}

final class ParseFailure extends AppFailure {
  const ParseFailure([
    super.message = 'Failed to process server response.',
  ]);
}

final class CancelledFailure extends AppFailure {
  const CancelledFailure([
    super.message = 'Request was cancelled.',
  ]);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
