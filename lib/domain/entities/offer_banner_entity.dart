import 'package:equatable/equatable.dart';
import 'asset_entity.dart';
import 'flipper_config_entity.dart';

class OfferBannerEntity extends Equatable {
  const OfferBannerEntity({this.asset, this.flipperConfig = const []});

  final AssetEntity? asset;
  final List<FlipperConfigEntity> flipperConfig;

  static OfferBannerEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OfferBannerEntity();
    final rawConfig = map['flipper_config'] as List<dynamic>? ?? [];
    return OfferBannerEntity(
      asset: AssetEntity.fromMap(map['asset'] as Map<String, dynamic>?),
      flipperConfig: rawConfig
          .map((e) => FlipperConfigEntity.fromMap(e as Map<String, dynamic>?))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [asset, flipperConfig];
}
