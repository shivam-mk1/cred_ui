import 'package:equatable/equatable.dart';

/// Sealed domain failure representing an error condition in an operation.
///
/// Subtypes categorize errors into typed failure modes for the presentation
/// layer so UI widgets can render specific icons and user guidance without
/// inspecting raw HTTP codes or exception strings.
sealed class AppFailure extends Equatable {
  const AppFailure(this.message);

  /// User-presentable description of the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when the device cannot connect to the server due to network
/// unavailability.
final class NoInternetFailure extends AppFailure {
  const NoInternetFailure([
    super.message = 'No internet connection. Please check your network and try again.',
  ]);
}

/// Emitted when connection, send, receive, or transform duration exceeds
/// configured limits.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message = 'Connection timed out. Please try again.',
  ]);
}

/// Emitted when the server responds with HTTP 429 Too Many Requests.
///
/// The mock API rate-limits callers after 5 requests per rolling time window.
final class RateLimitFailure extends AppFailure {
  const RateLimitFailure([
    super.message = 'API rate limit reached (5 requests/window). Please wait a few seconds and retry.',
  ]);
}

/// Emitted when the server responds with an HTTP 5xx error code.
final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Server error occurred. Please try again later.',
  ]);
}

/// Emitted when the server payload format deviates from expected schema
/// contracts.
final class ParseFailure extends AppFailure {
  const ParseFailure([
    super.message = 'Failed to process server response.',
  ]);
}

/// Emitted when an active request is aborted via cancellation tokens.
///
/// Handled silently by the cubit to avoid presenting spurious errors to the
/// user.
final class CancelledFailure extends AppFailure {
  const CancelledFailure([
    super.message = 'Request was cancelled.',
  ]);
}

/// Emitted when an unclassified exception occurs that does not match typed
/// failure modes.
final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
