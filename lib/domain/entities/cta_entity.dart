import 'package:equatable/equatable.dart';
import 'asset_entity.dart';

enum CtaType { deeplink, flow, unknown }

class FlowEntity extends Equatable {
  const FlowEntity({this.type});

  final String? type;

  static FlowEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FlowEntity();
    return FlowEntity(type: map['type'] as String?);
  }

  @override
  List<Object?> get props => [type];
}

class DeeplinkEntity extends Equatable {
  const DeeplinkEntity({this.url});

  final String? url;

  bool get hasUrl => url != null && url!.isNotEmpty;

  static DeeplinkEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DeeplinkEntity();
    return DeeplinkEntity(url: map['url'] as String?);
  }

  @override
  List<Object?> get props => [url];
}

class CtaEntity extends Equatable {
  const CtaEntity({
    required this.type,
    this.title,
    this.asset,
    this.deeplink,
    this.flow,
    this.ctaType,
    this.labelColor,
    this.labelText,
    this.labelAsset,
  });

  final CtaType type;
  final String? title;
  final AssetEntity? asset;
  final DeeplinkEntity? deeplink;
  final FlowEntity? flow;
  final String? ctaType;
  final String? labelColor;
  final String? labelText;
  final AssetEntity? labelAsset;

  static CtaType _parseType(String? raw) => switch (raw?.toLowerCase()) {
        'deeplink' => CtaType.deeplink,
        'flow' => CtaType.flow,
        _ => CtaType.unknown,
      };

  static CtaEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CtaEntity(type: CtaType.unknown);
    return CtaEntity(
      type: _parseType(map['type'] as String?),
      title: map['title'] as String?,
      asset: AssetEntity.fromMap(map['asset'] as Map<String, dynamic>?),
      deeplink:
          DeeplinkEntity.fromMap(map['deeplink'] as Map<String, dynamic>?),
      flow: FlowEntity.fromMap(map['flow'] as Map<String, dynamic>?),
      ctaType: map['cta_type'] as String?,
      labelColor: map['label_color'] as String?,
      labelText: map['label_text'] as String?,
      labelAsset:
          AssetEntity.fromMap(map['label_asset'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [
        type,
        title,
        asset,
        deeplink,
        flow,
        ctaType,
        labelColor,
        labelText,
        labelAsset,
      ];
}
