import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/character.dart';
import '../../models/game_room.dart';
import '../../models/map_node.dart';
import 'sync_interface.dart';

class MockSyncProvider extends ChangeNotifier implements VttSyncService {
  // Global simulated server database shared across all instances
  static final Map<String, GameRoom> _serverRooms = {};
  static final List<MockSyncProvider> _activeInstances = [];

  GameRoom? _currentRoom;
  String? _currentUserId;
  bool _isGm = false;
  Timer? _syncTimer;
  String? _activeGmNpcId;

  MockSyncProvider() {
    _activeInstances.add(this);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _activeInstances.remove(this);
    super.dispose();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchRoomStateFromServer());
  }

  Future<void> _fetchRoomStateFromServer() async {
    if (_currentRoom == null) return;
    final roomCode = _currentRoom!.roomCode;
    try {
      final response = await http.get(Uri.parse('api/room/$roomCode'));
      if (response.statusCode == 200) {
        final roomJson = jsonDecode(response.body);
        final updatedRoom = GameRoom.fromJson(roomJson);
        
        // Check for state changes to avoid unnecessary notification loops
        if (_currentRoom == null ||
            _currentRoom!.activeMapId != updatedRoom.activeMapId ||
            _currentRoom!.tokens.length != updatedRoom.tokens.length ||
            _currentRoom!.mapNodes.length != updatedRoom.mapNodes.length ||
            jsonEncode(_currentRoom!.tokens) != jsonEncode(updatedRoom.tokens) ||
            jsonEncode(_currentRoom!.mapNodes) != jsonEncode(updatedRoom.mapNodes) ||
            jsonEncode(_currentRoom!.rollLog) != jsonEncode(updatedRoom.rollLog) ||
            jsonEncode(_currentRoom!.revealedHandouts) != jsonEncode(updatedRoom.revealedHandouts)) {
          
          _currentRoom = updatedRoom;
          notifyListeners();
        }
      }
    } catch (e) {
      // Silent error
    }
  }

  static Future<void> _pushRoomToServer(String roomCode) async {
    final room = _serverRooms[roomCode];
    if (room == null) return;
    try {
      await http.post(
        Uri.parse('api/room/$roomCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(room.toJson()),
      );
    } catch (e) {
      // Silent error
    }
  }

  @override
  GameRoom? get currentRoom => _currentRoom;

  @override
  String? get currentUserId => _currentUserId;

  @override
  bool get isGm => _isGm;

  // Broadcast updates to all instances connected to the same room code
  static void _broadcastRoomChange(String roomCode) {
    final updatedRoom = _serverRooms[roomCode];
    if (updatedRoom == null) return;

    for (var instance in _activeInstances) {
      if (instance._currentRoom?.roomCode == roomCode) {
        instance._currentRoom = updatedRoom;
        instance.notifyListeners();
      }
    }
    // Automatically push the new room state to the Python web server
    _pushRoomToServer(roomCode);
  }

  @override
  Future<bool> createRoom(String roomCode, String gmName) async {
    final code = roomCode.toUpperCase().trim();
    if (code.isEmpty) return false;

    // Try loading from the Python sync server first
    try {
      final response = await http.get(Uri.parse('api/room/$code'));
      if (response.statusCode == 200) {
        final roomJson = jsonDecode(response.body);
        final roomFromServer = GameRoom.fromJson(roomJson);
        _serverRooms[code] = roomFromServer;
        _currentRoom = roomFromServer;
        _currentUserId = 'gm_user';
        _isGm = true;
        _startSyncTimer();
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Server offline or room not created yet, proceed locally
    }

    // Initialize default campaign room
    final newRoom = GameRoom(
      roomCode: code,
      activeMapId: 'overworld',
      characters: _createDefaultCharacters(),
      tokens: _createDefaultTokensForMap('overworld'),
      rollLog: [],
      playerSelections: {
        'gm_user': 'gm_profile'
      },
      mapNodes: _createDefaultMapNodes(),
    );

    _serverRooms[code] = newRoom;
    _currentRoom = newRoom;
    _currentUserId = 'gm_user';
    _isGm = true;
    
    // Save to server
    await _pushRoomToServer(code);
    _startSyncTimer();
    notifyListeners();
    return true;
  }

  @override
  Future<bool> joinRoom(String roomCode, String playerName, {bool joinAsGm = false}) async {
    final code = roomCode.toUpperCase().trim();

    // Fetch latest room state from Python server
    try {
      final response = await http.get(Uri.parse('api/room/$code'));
      if (response.statusCode == 200) {
        final roomJson = jsonDecode(response.body);
        final roomFromServer = GameRoom.fromJson(roomJson);
        _serverRooms[code] = roomFromServer;
      }
    } catch (e) {
      // Server offline
    }

    if (!_serverRooms.containsKey(code)) {
      return false; // Room does not exist
    }

    _currentUserId = playerName.toLowerCase().replaceAll(' ', '_');
    _isGm = joinAsGm;

    final room = _serverRooms[code]!;
    Map<String, String> updatedSelections = Map.from(room.playerSelections);
    updatedSelections[_currentUserId!] = joinAsGm ? 'gm_profile' : '';

    final updatedRoom = room.copyWith(playerSelections: updatedSelections);
    _serverRooms[code] = updatedRoom;
    _currentRoom = updatedRoom;
    
    _startSyncTimer();
    _broadcastRoomChange(code);
    return true;
  }

  @override
  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;
    _syncTimer?.cancel();
    _currentRoom = null;
    _currentUserId = null;
    _isGm = false;
    notifyListeners();
  }

  @override
  Future<void> upsertCharacter(Character character) async {
    if (_currentRoom == null) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    // Security Check: Players cannot edit other characters sheets unless GM
    if (!_isGm && _currentRoom!.playerSelections[_currentUserId] != character.id) {
      throw Exception("Unauthorized: Players can only edit their own character sheet.");
    }

    Map<String, Character> updatedChars = Map.from(room.characters);
    updatedChars[character.id] = character;

    final updatedRoom = room.copyWith(characters: updatedChars);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> deleteCharacter(String characterId) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    Map<String, Character> updatedChars = Map.from(room.characters);
    updatedChars.remove(characterId);

    final updatedRoom = room.copyWith(characters: updatedChars);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> selectCharacterForPlayer(String playerId, String characterId) async {
    if (_currentRoom == null) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    Map<String, String> updatedSelections = Map.from(room.playerSelections);
    updatedSelections[playerId] = characterId;

    final updatedRoom = room.copyWith(playerSelections: updatedSelections);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> addToken(VttToken token) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    final index = room.tokens.indexWhere((t) => t.tokenId == token.tokenId);
    List<VttToken> updatedTokens = List.from(room.tokens);
    if (index != -1) {
      updatedTokens[index] = token;
    } else {
      updatedTokens.add(token);
    }

    final updatedRoom = room.copyWith(tokens: updatedTokens);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> updateTokenPosition(String tokenId, double x, double y) async {
    if (_currentRoom == null) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    // Security Check: Players can only move tokens they own/are assigned to, GM can move all
    int tokenIndex = room.tokens.indexWhere((t) => t.tokenId == tokenId);
    if (tokenIndex == -1) return;
    final token = room.tokens[tokenIndex];

    if (!_isGm) {
      final assignedCharId = room.playerSelections[_currentUserId];
      if (assignedCharId != token.characterId) {
        return; // Prevent player from dragging other players' or GM tokens
      }
    }

    List<VttToken> updatedTokens = List.from(room.tokens);
    updatedTokens[tokenIndex] = token.copyWith(x: x, y: y);

    final updatedRoom = room.copyWith(tokens: updatedTokens);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> toggleTokenVisibility(String tokenId) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    int tokenIndex = room.tokens.indexWhere((t) => t.tokenId == tokenId);
    if (tokenIndex == -1) return;
    final token = room.tokens[tokenIndex];

    List<VttToken> updatedTokens = List.from(room.tokens);
    updatedTokens[tokenIndex] = token.copyWith(isGmOnly: !token.isGmOnly);

    final updatedRoom = room.copyWith(tokens: updatedTokens);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> removeToken(String tokenId) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    List<VttToken> updatedTokens = List.from(room.tokens)
      ..removeWhere((t) => t.tokenId == tokenId);

    final updatedRoom = room.copyWith(tokens: updatedTokens);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> targetToken(String tokenId, String? playerId) async {
    if (_currentRoom == null) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    int tokenIndex = room.tokens.indexWhere((t) => t.tokenId == tokenId);
    if (tokenIndex == -1) return;
    final token = room.tokens[tokenIndex];

    List<VttToken> updatedTokens = List.from(room.tokens);
    
    if (playerId == null) {
      // Clear target if currently targeted by this player
      if (token.targetedByPlayerId == _currentUserId) {
        updatedTokens[tokenIndex] = token.copyWith(clearTarget: true);
      }
    } else {
      // Target this token
      updatedTokens[tokenIndex] = token.copyWith(targetedByPlayerId: playerId);
    }

    final updatedRoom = room.copyWith(tokens: updatedTokens);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> changeActiveMap(String mapId, {int? sceneIndex}) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    // Load default tokens for this map, and ensure they have clean targets
    List<VttToken> newTokens = _createDefaultTokensForMap(mapId)
        .map((t) => t.copyWith(clearTarget: true))
        .toList();

    // Reset handout revealed state for this map upon switching or resetting
    Map<String, int> updatedHandouts = Map.from(room.revealedHandouts);
    if (sceneIndex != null) {
      updatedHandouts[mapId] = sceneIndex;
    } else {
      updatedHandouts[mapId] = 0;
    }

    final updatedRoom = room.copyWith(activeMapId: mapId, tokens: newTokens, revealedHandouts: updatedHandouts);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> updateMapNodes(List<MapNode> nodes) async {
    if (_currentRoom == null || !_isGm) return; // GM only
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    final updatedRoom = room.copyWith(mapNodes: nodes);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  // Scene index limits per map — keep in sync with scene_registry.dart
  static const Map<String, int> _sceneMaxIndex = {
    'sentiero_iniziale': 6,
    'outskirt_village': 2,
    'villaggio_orlo': 2,
    'locanda_tre_cervi': 0,
    'locanda_tre_cervi_interno': 0,
    'locanda_tre_cervi_stanze': 0,
    'orlo_piazza': 0,
    'orlo_fucina': 0,
    'orlo_troll': 0,
    'orlo_torre': 0,
    'guglia_troll': 7,
  };

  Future<void> revealHandout(String mapId) async {
    if (_currentRoom == null || !_isGm) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    Map<String, int> updatedHandouts = Map.from(room.revealedHandouts);
    final currentVal = updatedHandouts[mapId] ?? 0;

    final maxVal = _sceneMaxIndex[mapId];
    int newVal;
    if (maxVal != null) {
      newVal = (currentVal + 1).clamp(0, maxVal);
    } else {
      newVal = 1;
    }
    updatedHandouts[mapId] = newVal;

    if (mapId.startsWith('show_npc_')) {
      _activeGmNpcId = mapId.replaceFirst('show_npc_', '');
    }

    if (mapId == 'sentiero_iniziale' && newVal == 6) {
      updatedHandouts['show_cavalcawarg_handout'] = 1;
    }

    final updatedRoom = room.copyWith(revealedHandouts: updatedHandouts);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> hideHandout(String mapId) async {
    if (_currentRoom == null || !_isGm) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    Map<String, int> updatedHandouts = Map.from(room.revealedHandouts);
    final currentVal = updatedHandouts[mapId] ?? 0;

    final maxVal = _sceneMaxIndex[mapId];
    int newVal;
    if (maxVal != null) {
      newVal = (currentVal - 1).clamp(0, maxVal);
    } else {
      newVal = 0;
    }
    updatedHandouts[mapId] = newVal;

    final updatedRoom = room.copyWith(revealedHandouts: updatedHandouts);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  @override
  Future<void> submitRoll(String rollerName, String rollType, int targetValue, {required String rollMode, required Character rollerCharacter}) async {
    if (_currentRoom == null) return;
    final code = _currentRoom!.roomCode;
    final room = _serverRooms[code]!;

    // Resolve active condition modifiers for Dragonbane
    // Find if the rollType belongs to an attribute or a skill associated with one.
    // In Dragonbane, if you are rolls an attribute, or a skill associated with that attribute,
    // and you have the condition for that attribute, you gain a Bane.
    String associatedAttribute = _detectAssociatedAttribute(rollType);
    bool conditionActive = rollerCharacter.hasBaneForAttribute(associatedAttribute);

    // Calculate Net Roll Mode:
    // Boon and Bane cancel each other out.
    // e.g. User asks for Boon, but Condition gives Bane -> Net roll is Normale.
    String netMode = rollMode;
    if (conditionActive) {
      if (rollMode == 'Boon') {
        netMode = 'Normale'; // Cancelled out!
      } else if (rollMode == 'Normale') {
        netMode = 'Bane';
      }
    }

    // Roll the dice
    final random = Random();
    int die1 = random.nextInt(20) + 1;
    int die2 = random.nextInt(20) + 1;
    int finalResult;
    List<int> rolledDice = [];

    if (netMode == 'Boon') {
      rolledDice = [die1, die2];
      finalResult = min(die1, die2);
    } else if (netMode == 'Bane') {
      rolledDice = [die1, die2];
      finalResult = max(die1, die2);
    } else {
      rolledDice = [die1];
      finalResult = die1;
    }

    // Determine Dragonbane roll outcome
    String outcome;
    if (finalResult == 1) {
      outcome = 'Drago (Critico)';
    } else if (finalResult == 20) {
      outcome = 'Demone (Mishap)';
    } else if (finalResult <= targetValue) {
      outcome = 'Successo';
    } else {
      outcome = 'Fallimento';
    }

    final newLog = RollLogEntry(
      id: 'roll_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100)}',
      rollerName: rollerName,
      rollType: rollType,
      targetValue: targetValue,
      diceResults: rolledDice,
      outcome: outcome,
      rollMode: netMode != rollMode ? '$rollMode (Sciagura Condizione applicata)' : rollMode,
      timestamp: DateTime.now(),
    );

    List<RollLogEntry> updatedLog = List.from(room.rollLog)..insert(0, newLog);
    // Limit log size to 50 entries
    if (updatedLog.length > 50) {
      updatedLog = updatedLog.sublist(0, 50);
    }

    final updatedRoom = room.copyWith(rollLog: updatedLog);
    _serverRooms[code] = updatedRoom;
    _broadcastRoomChange(code);
  }

  // Detect attribute abbreviation from roll type string
  String _detectAssociatedAttribute(String rollType) {
    if (rollType.contains('(FOR)')) return 'FOR';
    if (rollType.contains('(COS)')) return 'COS';
    if (rollType.contains('(AGI)')) return 'AGI';
    if (rollType.contains('(INT)')) return 'INT';
    if (rollType.contains('(VOL)')) return 'VOL';
    if (rollType.contains('(CAR)')) return 'CAR';
    
    // Fallback if abbreviation is in the string name itself
    for (var attr in ['FOR', 'COS', 'AGI', 'INT', 'VOL', 'CAR']) {
      if (rollType.toUpperCase().contains(attr)) return attr;
    }
    return 'FOR'; // Default fallback
  }

  // Generate starting characters for testing
  Map<String, Character> _createDefaultCharacters() {
    return {
      'pc_krag': Character(
        id: 'pc_krag',
        name: 'Krag del Picco di Pietra',
        stirpe: 'Nano',
        professione: 'Guerriero',
        debolezza: 'Gola insaziabile',
        forta: 15, costituzione: 14, agilita: 11, intelligenza: 9, volonta: 10, carisma: 11,
        hp: 14, maxHp: 14, wp: 10, maxWp: 10,
        skills: {
          'Artigianato (FOR)': 10, 'Acrobazia (AGI)': 5, 'Consapevolezza (INT)': 8,
          'Spade (FOR)': 14, 'Asce (FOR)': 12, 'Rissa (FOR)': 10, 'Sfuggire (AGI)': 8
        },
        weapons: [
          WeaponItem(name: 'Spada Lunga', attribute: 'FOR', damage: '2d6', range: 'Mischia', qualities: 'Tagliente'),
          WeaponItem(name: 'Ascia da Battaglia', attribute: 'FOR', damage: '2d8', range: 'Mischia', qualities: 'Pesante')
        ],
        inventory: ['Scudo di legno', 'Razionamenti x3', 'Corda di canapa'],
        isNpc: false,
      ),
      'pc_valeria': Character(
        id: 'pc_valeria',
        name: 'Valeria la Silente',
        stirpe: 'Umano',
        professione: 'Ladra',
        debolezza: 'Estremamente avara',
        forta: 10, costituzione: 11, agilita: 15, intelligenza: 13, volonta: 11, carisma: 12,
        hp: 11, maxHp: 11, wp: 11, maxWp: 11,
        skills: {
          'Sgattaiolare (AGI)': 15, 'Sfuggire (AGI)': 12, 'Rapidità di Mano (AGI)': 14,
          'Localizzare (INT)': 10, 'Coltelli (AGI)': 13, 'Archi (AGI)': 10, 'Consapevolezza (INT)': 11
        },
        weapons: [
          WeaponItem(name: 'Daga d\'Acciaio', attribute: 'AGI', damage: '1d6+1', range: 'Mischia', qualities: 'Sottile'),
          WeaponItem(name: 'Arco Corto', attribute: 'AGI', damage: '1d8', range: 'Distanza', qualities: 'Perforante')
        ],
        inventory: ['Attrezzi da scasso', 'Mantello scuro', 'Lanterna cieca'],
        isNpc: false,
      ),
      'npc_goblin': Character(
        id: 'npc_goblin',
        name: 'Goblin della Valle',
        stirpe: 'Goblin',
        professione: 'Scaricatore',
        forta: 8, costituzione: 9, agilita: 13, intelligenza: 8, volonta: 9, carisma: 6,
        hp: 9, maxHp: 9, wp: 9, maxWp: 9,
        skills: {
          'Sgattaiolare (AGI)': 12, 'Coltelli (AGI)': 10, 'Sfuggire (AGI)': 9
        },
        weapons: [
          WeaponItem(name: 'Archetto Rustico', attribute: 'AGI', damage: '1d6', range: 'Distanza')
        ],
        inventory: ['Pietre levigate', 'Dente fortunato'],
        isNpc: true,
        gmNotes: 'Codardo. Scappa se perde più di metà dei punti ferita. Teme il fuoco.',
      ),
      'npc_goblin_ricognitore': Character(
        id: 'npc_goblin_ricognitore',
        name: 'Goblin Ricognitore',
        stirpe: 'Goblin',
        professione: 'Ricognitore',
        forta: 8, costituzione: 9, agilita: 13, intelligenza: 8, volonta: 9, carisma: 6,
        hp: 9, maxHp: 9, wp: 9, maxWp: 9,
        skills: {
          'Consapevolezza (INT)': 10, 'Sfuggire (AGI)': 10, 'Sgattaiolare (AGI)': 12
        },
        weapons: [
          WeaponItem(name: 'Arco Corto', attribute: 'AGI', damage: '1d10', range: 'Distanza'),
          WeaponItem(name: 'Spada Corta', attribute: 'AGI', damage: '1d10', range: 'Mischia'),
        ],
        inventory: ['Pelle di lupo', 'Marchio di Maladûk'],
        isNpc: true,
        gmNotes: 'Marchio nero di Maladûk sulla spalla destra. Danno Bonus: AGI +D4. Armatura: Cuoio (1).',
      ),
      'npc_cavalcawarg': Character(
        id: 'npc_cavalcawarg',
        name: 'Il Cavalcawarg',
        stirpe: 'Goblin & Warg',
        professione: 'Comandante',
        forta: 14, costituzione: 13, agilita: 12, intelligenza: 8, volonta: 10, carisma: 10,
        hp: 24, maxHp: 24, wp: 10, maxWp: 10,
        skills: {
          'Consapevolezza (INT)': 10, 'Sfuggire (AGI)': 10
        },
        weapons: [
          WeaponItem(name: 'Scimitarra Seghettata', attribute: 'FOR', damage: '3d6', range: 'Mischia'),
          WeaponItem(name: 'Lancia Lunga', attribute: 'FOR', damage: '3d8', range: 'Mischia'),
        ],
        inventory: ['Warg Sanguinario', 'Simbolo di Sathmog'],
        isNpc: true,
        gmNotes: 'Ferocia: 2. Taglia: Normale. Conta come mostro. Attacchi mostruosi D6.',
      ),
    };
  }

  // Generate starting tokens for testing
  List<VttToken> _createDefaultTokensForMap(String mapId) {
    // Standard player tokens present in all maps
    final playerTokens = [
      VttToken(tokenId: 'token_krag', characterId: 'pc_krag', name: 'Krag', x: 25.0, y: 55.0, isNpc: false),
      VttToken(tokenId: 'token_valeria', characterId: 'pc_valeria', name: 'Valeria', x: 28.0, y: 60.0, isNpc: false),
    ];

    if (mapId == 'sentiero_iniziale') {
      return [
        VttToken(
          tokenId: 'token_goblin_r1',
          characterId: 'npc_goblin_ricognitore',
          name: 'Goblin Ricognitore 1',
          x: 45.60935661884122,
          y: 73.28973206208484,
          isNpc: true,
          isGmOnly: true,
        ),
        VttToken(
          tokenId: 'token_goblin_r2',
          characterId: 'npc_goblin_ricognitore',
          name: 'Goblin Ricognitore 2',
          x: 41.19378760762299,
          y: 73.04903516133533,
          isNpc: true,
          isGmOnly: true,
        ),
        VttToken(
          tokenId: 'token_goblin_r3',
          characterId: 'npc_goblin_ricognitore',
          name: 'Goblin Ricognitore 3',
          x: 38.31734007421409,
          y: 42.707081687752826,
          isNpc: true,
          isGmOnly: true,
        ),
        VttToken(
          tokenId: 'token_cavalcawarg_r4',
          characterId: 'npc_cavalcawarg',
          name: 'Cavalcawarg',
          x: 56.31779062688136,
          y: 36.25430183483885,
          isNpc: true,
          isGmOnly: true,
        ),
      ];
    } else if (mapId == 'outskirt_village' || mapId == 'villaggio_orlo') {
      return [
        ...playerTokens,
        VttToken(
          tokenId: "token_goblin1",
          characterId: "npc_goblin",
          name: "Goblin Sentinella",
          x: 65.0,
          y: 45.0,
          isGmOnly: false,
          isNpc: true,
        ),
        VttToken(
          tokenId: "token_goblin_boss",
          characterId: "npc_goblin",
          name: "Goblin Capo (Nascosto)",
          x: 75.0,
          y: 35.0,
          isGmOnly: true,
          isNpc: true,
        ),
      ];
    } else {
      return playerTokens;
    }
  }

  List<MapNode> _createDefaultMapNodes() {
    return [
      MapNode(
        id: "outskirt",
        name: "Orlo",
        description: "",
        xPercent: 54.9,
        yPercent: 59.0,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "villaggio_orlo",
      ),
      MapNode(
        id: "tempio_ruine",
        name: "Foresta di Ferro",
        description: "",
        xPercent: 26.6,
        yPercent: 46.9,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "foresta_ferro",
      ),
      MapNode(
        id: "forte_ghiaccio",
        name: "Paludi Infestate",
        description: "",
        xPercent: 75.8,
        yPercent: 56.6,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "paludi_infestate",
      ),
      MapNode(
        id: "palude_morte",
        name: "Passo di Drakmar",
        description: "",
        xPercent: 49.9,
        yPercent: 68.5,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "passo_drakmar",
      ),
      MapNode(
        id: "tomba_segreta",
        name: "Boscomagno",
        description: "",
        xPercent: 51.7,
        yPercent: 36.3,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "bosco_magno",
      ),
      MapNode(
        id: "node_1783167020493",
        name: "Lago Specchiato",
        description: "",
        xPercent: 38.4,
        yPercent: 28.5,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "lago_specchiato",
      ),
      MapNode(
        id: "node_1783167048858",
        name: "Picchi Zanna del Drago",
        description: "",
        xPercent: 26.8,
        yPercent: 17.2,
        isGmOnly: false,
        isLocked: true,
        targetSubMap: "picchi_zanna_drago",
      ),
      MapNode(
        id: "node_1783168064041",
        name: "Forte Malus",
        description: "",
        xPercent: 24.1,
        yPercent: 27.5,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "forte_malus",
      ),
      MapNode(
        id: "node_1783168101643",
        name: "Guglia del Troll",
        description: "",
        xPercent: 20.7,
        yPercent: 36.7,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "guglia_troll",
      ),
      MapNode(
        id: "node_1783168124194",
        name: "Caverna dell'Oracolo",
        description: "",
        xPercent: 19.6,
        yPercent: 62.0,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "caverna_oracolo",
      ),
      MapNode(
        id: "node_1783168161987",
        name: "Cripta del Cavaliere",
        description: "",
        xPercent: 37.6,
        yPercent: 55.8,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "cripta_cavaliere",
      ),
      MapNode(
        id: "node_1783168208959",
        name: "Breccia Bucaprofonda",
        description: "",
        xPercent: 34.5,
        yPercent: 64.1,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "breccia_bucaprofonda",
      ),
      MapNode(
        id: "node_1783168273158",
        name: "Sentiero",
        description: "",
        xPercent: 48.3,
        yPercent: 78.2,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "sentiero_iniziale",
      ),
      MapNode(
        id: "node_1783168303755",
        name: "Isola della Nebbia",
        description: "",
        xPercent: 42.2,
        yPercent: 27.1,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "isola_nebbia",
      ),
      MapNode(
        id: "node_1783168345046",
        name: "Tempio della Fiamma Purpurea",
        description: "",
        xPercent: 56.2,
        yPercent: 35.0,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "tempio_fiamma_purpurea",
      ),
      MapNode(
        id: "node_1783168369070",
        name: "Villaggio del Giorno Prima",
        description: "",
        xPercent: 71.4,
        yPercent: 34.0,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "villaggio_giorno_prima",
      ),
      MapNode(
        id: "node_1783168410386",
        name: "Torre dei Sospiri",
        description: "",
        xPercent: 78.8,
        yPercent: 49.2,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "torre_sospiri",
      ),
      MapNode(
        id: "node_1783168450873",
        name: "Locanda Fine Strada",
        description: "",
        xPercent: 69.2,
        yPercent: 55.5,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "locanda_fine_strada",
      ),
      MapNode(
        id: "node_1783168485335",
        name: "Caverna degli Occhi Morti",
        description: "",
        xPercent: 66.9,
        yPercent: 77.0,
        isGmOnly: true,
        isLocked: false,
        targetSubMap: "caverna_occhi_morti",
      ),
      // Nodi di Orlo
      MapNode(
        id: "pin_villaggio_orlo_0",
        name: "Cancello Sud",
        description: "Il cancello principale di Orlo.",
        xPercent: 39.3,
        yPercent: 37.6,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_1",
        name: "Torre Guardia Sud-Est",
        description: "La torre dove si trovava Hardy.",
        xPercent: 65.6,
        yPercent: 72.6,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_2",
        name: "Torrione Nord",
        description: "Il torrione del cancello nord.",
        xPercent: 55.8,
        yPercent: 25.8,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_3",
        name: "Piazza del Villaggio",
        description: "La piazza con la statua rovinata.",
        xPercent: 50.9,
        yPercent: 32.6,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "orlo_piazza",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_4",
        name: "Locanda Ai Tre Cervi",
        description: "La locanda del villaggio.",
        xPercent: 50.2,
        yPercent: 41.8,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "locanda_tre_cervi",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_5",
        name: "Negozio di Mastro Ulvar",
        description: "Il negozio generale del villaggio.",
        xPercent: 49.0,
        yPercent: 25.7,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_6",
        name: "Fucina",
        description: "La fucina di Okald e Badinor.",
        xPercent: 45.9,
        yPercent: 30.4,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "orlo_fucina",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_7",
        name: "Casa di Vagnhild",
        description: "La casa della capovillaggio Vagnhild.",
        xPercent: 50.4,
        yPercent: 85.2,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_8",
        name: "Pozzo",
        description: "Il pozzo comune.",
        xPercent: 56.2,
        yPercent: 46.6,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_9",
        name: "Formazioni Rocciose",
        description: "Rocce cristalline e grotta.",
        xPercent: 48.1,
        yPercent: 51.5,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
      MapNode(
        id: "pin_villaggio_orlo_10",
        name: "Edificio Misterioso",
        description: "Edificio evitato dagli abitanti.",
        xPercent: 54.5,
        yPercent: 55.6,
        isGmOnly: false,
        isLocked: false,
        targetSubMap: "",
        subMapId: "villaggio_orlo",
      ),
    ];
  }

  @override
  String? get activeGmNpcId => _activeGmNpcId;

  @override
  void setActiveGmNpcId(String? npcId) {
    _activeGmNpcId = npcId;
    notifyListeners();
  }
}
