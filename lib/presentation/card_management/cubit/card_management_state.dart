import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';

/// Lifecycle statuses for card management data loading.
enum CardManagementStatus { initial, loading, loaded, error }

/// Represents the selected mode for the summary tab toggle.
enum ActiveToggle { totalDue, recentSpends }

/// Immutable state container for the [CardManagementCubit].
class CardManagementState extends Equatable {
  const CardManagementState({
    this.status = CardManagementStatus.initial,
    this.sections = const [],
    this.cards = const [],
    this.activeToggle = ActiveToggle.totalDue,
    this.failure,
  });

  /// The current state machine lifecycle status.
  final CardManagementStatus status;

  /// Top-level section template nodes parsed from server payload.
  final List<SectionEntity> sections;

  /// Filtered list of card instrument sections used to build deck widgets.
  final List<CardInstrumentSection> cards;

  /// The active view mode for the statement info toggle.
  final ActiveToggle activeToggle;

  /// Present when [status] is [CardManagementStatus.error], otherwise null.
  final AppFailure? failure;

  factory CardManagementState.initial() => const CardManagementState();

  CardManagementState copyWith({
    CardManagementStatus? status,
    List<SectionEntity>? sections,
    List<CardInstrumentSection>? cards,
    ActiveToggle? activeToggle,
    AppFailure? failure,
    bool clearError = false,
  }) {
    return CardManagementState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      cards: cards ?? this.cards,
      activeToggle: activeToggle ?? this.activeToggle,
      failure: clearError ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        sections,
        cards,
        activeToggle,
        failure,
      ];
}
