import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';

enum CardManagementStatus { initial, loading, loaded, error }

enum ActiveToggle { totalDue, recentSpends }

class CardManagementState extends Equatable {
  const CardManagementState({
    this.status = CardManagementStatus.initial,
    this.sections = const [],
    this.cards = const [],
    this.activeToggle = ActiveToggle.totalDue,
    this.failure,
  });

  final CardManagementStatus status;
  final List<SectionEntity> sections;
  final List<CardInstrumentSection> cards;
  final ActiveToggle activeToggle;
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
