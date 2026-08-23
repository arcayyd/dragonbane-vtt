import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/game_room.dart';
import '../../models/map_node.dart';

abstract class VttSyncService extends ChangeNotifier {
  GameRoom? get currentRoom;
  String? get currentUserId;
  bool get isGm;

  // Connection management
  Future<bool> createRoom(String roomCode, String gmName);
  Future<bool> joinRoom(String roomCode, String playerName, {bool joinAsGm = false});
  Future<void> leaveRoom();

  // Character management
  Future<void> upsertCharacter(Character character);
  Future<void> deleteCharacter(String characterId);
  Future<void> selectCharacterForPlayer(String playerId, String characterId);

  // Token management
  Future<void> addToken(VttToken token);
  Future<void> updateTokenPosition(String tokenId, double x, double y);
  Future<void> toggleTokenVisibility(String tokenId);
  Future<void> removeToken(String tokenId);
  Future<void> targetToken(String tokenId, String? playerId);

  // Map management
  Future<void> changeActiveMap(String mapId, {int? sceneIndex});
  Future<void> updateMapNodes(List<MapNode> nodes);
  Future<void> revealHandout(String mapId);
  Future<void> hideHandout(String mapId);

  // GM active NPC for statblock viewing
  String? get activeGmNpcId;
  void setActiveGmNpcId(String? npcId);

  // Dice roll submission
  Future<void> submitRoll(String rollerName, String rollType, int targetValue, {required String rollMode, required Character rollerCharacter});
}
