import 'character.dart';
import 'map_node.dart';

class GameRoom {
  final String roomCode;
  final String activeMapId; // 'overworld' or sub-map ID
  final Map<String, Character> characters; // Character ID -> Character sheet
  final List<VttToken> tokens; // Active tokens on current submap
  final List<RollLogEntry> rollLog; // Chat history of dice rolls
  final Map<String, String> playerSelections; // PlayerId -> CharacterId
  final List<MapNode> mapNodes; // Dynamic coordinates of map locations
  final Map<String, int> revealedHandouts; // MapId -> scene index (0 = pass handout, 1 = lost man, 2 = map)
  
  GameRoom({
    required this.roomCode,
    this.activeMapId = 'overworld',
    this.characters = const {},
    this.tokens = const [],
    this.rollLog = const [],
    this.playerSelections = const {},
    this.mapNodes = const [],
    this.revealedHandouts = const {},
  });

  GameRoom copyWith({
    String? roomCode,
    String? activeMapId,
    Map<String, Character>? characters,
    List<VttToken>? tokens,
    List<RollLogEntry>? rollLog,
    Map<String, String>? playerSelections,
    List<MapNode>? mapNodes,
    Map<String, int>? revealedHandouts,
  }) {
    return GameRoom(
      roomCode: roomCode ?? this.roomCode,
      activeMapId: activeMapId ?? this.activeMapId,
      characters: characters ?? this.characters,
      tokens: tokens ?? this.tokens,
      rollLog: rollLog ?? this.rollLog,
      playerSelections: playerSelections ?? this.playerSelections,
      mapNodes: mapNodes ?? this.mapNodes,
      revealedHandouts: revealedHandouts ?? this.revealedHandouts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'activeMapId': activeMapId,
      'characters': characters.map((k, v) => MapEntry(k, v.toJson())),
      'tokens': tokens.map((t) => t.toJson()).toList(),
      'rollLog': rollLog.map((r) => r.toJson()).toList(),
      'playerSelections': playerSelections,
      'mapNodes': mapNodes.map((n) => n.toJson()).toList(),
      'revealedHandouts': revealedHandouts,
    };
  }

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    var rawChars = json['characters'] as Map? ?? {};
    Map<String, Character> charsMap = {};
    rawChars.forEach((k, v) {
      charsMap[k.toString()] = Character.fromJson(Map<String, dynamic>.from(v));
    });

    Map<String, int> handoutsMap = {};
    var rawHandouts = json['revealedHandouts'] as Map? ?? {};
    rawHandouts.forEach((k, v) {
      if (v is bool) {
        handoutsMap[k.toString()] = v ? 2 : 0;
      } else if (v is num) {
        handoutsMap[k.toString()] = v.toInt();
      } else {
        handoutsMap[k.toString()] = 0;
      }
    });

    return GameRoom(
      roomCode: json['roomCode'],
      activeMapId: json['activeMapId'] ?? 'overworld',
      characters: charsMap,
      tokens: (json['tokens'] as List? ?? [])
          .map((t) => VttToken.fromJson(Map<String, dynamic>.from(t)))
          .toList(),
      rollLog: (json['rollLog'] as List? ?? [])
          .map((r) => RollLogEntry.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
      playerSelections: Map<String, String>.from(json['playerSelections'] ?? {}),
      mapNodes: (json['mapNodes'] as List? ?? [])
          .map((n) => MapNode.fromJson(Map<String, dynamic>.from(n)))
          .toList(),
      revealedHandouts: handoutsMap,
    );
  }
}

class RollLogEntry {
  final String id;
  final String rollerName;
  final String rollType; // e.g. "Abilità: Acrobazia" or "Caratteristica: FOR"
  final int targetValue;
  final List<int> diceResults; // List of d20 results
  final String outcome; // "Successo", "Drago", "Demone", "Fallimento"
  final String rollMode; // "Normale", "Boon (Aiuto)", "Bane (Sciagura)"
  final DateTime timestamp;

  RollLogEntry({
    required this.id,
    required this.rollerName,
    required this.rollType,
    required this.targetValue,
    required this.diceResults,
    required this.outcome,
    required this.rollMode,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rollerName': rollerName,
      'rollType': rollType,
      'targetValue': targetValue,
      'diceResults': diceResults,
      'outcome': outcome,
      'rollMode': rollMode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RollLogEntry.fromJson(Map<String, dynamic> json) {
    return RollLogEntry(
      id: json['id'],
      rollerName: json['rollerName'],
      rollType: json['rollType'],
      targetValue: json['targetValue'] ?? 10,
      diceResults: List<int>.from(json['diceResults'] ?? []),
      outcome: json['outcome'],
      rollMode: json['rollMode'] ?? 'Normale',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
