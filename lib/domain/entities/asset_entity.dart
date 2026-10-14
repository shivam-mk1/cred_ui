import 'package:equatable/equatable.dart';

class AssetEntity extends Equatable {
  const AssetEntity({this.type, this.url});

  final String? type;
  final String? url;

  bool get hasUrl => url != null && url!.isNotEmpty;

  static const empty = AssetEntity();

  static AssetEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AssetEntity();
    return AssetEntity(
      type: map['type'] as String?,
      url: map['url'] as String?,
    );
  }

  @override
  List<Object?> get props => [type, url];
}
