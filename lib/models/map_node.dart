class MapNode {
  final String id;
  final String name;
  final String description;
  final double xPercent;
  final double yPercent;
  final bool isGmOnly;
  final bool isLocked;
  final String targetSubMap;
  final String subMapId;

  MapNode({
    required this.id,
    required this.name,
    required this.description,
    required this.xPercent,
    required this.yPercent,
    required this.isGmOnly,
    this.isLocked = false,
    required this.targetSubMap,
    this.subMapId = 'overworld',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'xPercent': xPercent,
      'yPercent': yPercent,
      'isGmOnly': isGmOnly,
      'isLocked': isLocked,
      'targetSubMap': targetSubMap,
      'subMapId': subMapId,
    };
  }

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      xPercent: (json['xPercent'] as num).toDouble(),
      yPercent: (json['yPercent'] as num).toDouble(),
      isGmOnly: json['isGmOnly'] ?? false,
      isLocked: json['isLocked'] ?? false,
      targetSubMap: json['targetSubMap'],
      subMapId: json['subMapId'] ?? 'overworld',
    );
  }
}

class VttToken {
  final String tokenId;
  final String characterId; // Link to the Character sheet
  final String name;
  final double x; // x position in local grid pixels/percent (e.g. 0 to 100)
  final double y; // y position in local grid pixels/percent (e.g. 0 to 100)
  final bool isGmOnly; // Hidden from players
  final bool isNpc;
  final String? targetedByPlayerId; // Player ID targeting this token

  VttToken({
    required this.tokenId,
    required this.characterId,
    required this.name,
    required this.x,
    required this.y,
    this.isGmOnly = false,
    this.isNpc = false,
    this.targetedByPlayerId,
  });

  VttToken copyWith({
    String? tokenId,
    String? characterId,
    String? name,
    double? x,
    double? y,
    bool? isGmOnly,
    bool? isNpc,
    String? targetedByPlayerId,
    bool clearTarget = false,
  }) {
    return VttToken(
      tokenId: tokenId ?? this.tokenId,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      isGmOnly: isGmOnly ?? this.isGmOnly,
      isNpc: isNpc ?? this.isNpc,
      targetedByPlayerId: clearTarget ? null : (targetedByPlayerId ?? this.targetedByPlayerId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'characterId': characterId,
      'name': name,
      'x': x,
      'y': y,
      'isGmOnly': isGmOnly,
      'isNpc': isNpc,
      'targetedByPlayerId': targetedByPlayerId,
    };
  }

  factory VttToken.fromJson(Map<String, dynamic> json) {
    return VttToken(
      tokenId: json['tokenId'],
      characterId: json['characterId'],
      name: json['name'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      isGmOnly: json['isGmOnly'] ?? false,
      isNpc: json['isNpc'] ?? false,
      targetedByPlayerId: json['targetedByPlayerId'],
    );
  }
}
