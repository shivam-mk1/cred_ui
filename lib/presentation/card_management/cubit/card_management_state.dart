import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';

enum CardManagementStatus { initial, loading, loaded, error }

enum CardLayoutMode { collapsedStack, expandedList, detail }

enum ActiveToggle { totalDue, recentSpends }

class CardManagementState extends Equatable {
  const CardManagementState({
    this.status = CardManagementStatus.initial,
    this.sections = const [],
    this.cards = const [],
    this.selectedCardIndex = 0,
    this.layoutMode = CardLayoutMode.collapsedStack,
    this.activeToggle = ActiveToggle.totalDue,
    this.isDetailPanelOpen = false,
    this.errorMessage,
    this.failure,
  });

  final CardManagementStatus status;

  final List<SectionEntity> sections;

  final List<CardInstrumentSection> cards;

  final int selectedCardIndex;
  final CardLayoutMode layoutMode;
  final ActiveToggle activeToggle;

  final bool isDetailPanelOpen;

  final String? errorMessage;
  final AppFailure? failure;

  CardInstrumentSection? get selectedCard => cards.isEmpty
      ? null
      : cards[selectedCardIndex.clamp(0, cards.length - 1)];

  factory CardManagementState.initial() => const CardManagementState();

  CardManagementState copyWith({
    CardManagementStatus? status,
    List<SectionEntity>? sections,
    List<CardInstrumentSection>? cards,
    int? selectedCardIndex,
    CardLayoutMode? layoutMode,
    ActiveToggle? activeToggle,
    bool? isDetailPanelOpen,
    String? errorMessage,
    AppFailure? failure,
    bool clearError = false,
  }) {
    return CardManagementState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      cards: cards ?? this.cards,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      layoutMode: layoutMode ?? this.layoutMode,
      activeToggle: activeToggle ?? this.activeToggle,
      isDetailPanelOpen: isDetailPanelOpen ?? this.isDetailPanelOpen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failure: clearError ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        sections,
        cards,
        selectedCardIndex,
        layoutMode,
        activeToggle,
        isDetailPanelOpen,
        errorMessage,
        failure,
      ];
}
