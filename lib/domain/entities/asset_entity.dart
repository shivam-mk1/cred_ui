import 'package:equatable/equatable.dart';

/// Domain entity representing a remote visual asset or image resource.
class AssetEntity extends Equatable {
  const AssetEntity({this.type, this.url});

  /// The asset mime or categorization type supplied by the server.
  final String? type;

  /// Remote URL pointing to the hosted visual resource.
  final String? url;

  /// Whether a valid non-empty URL is present for rendering.
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
