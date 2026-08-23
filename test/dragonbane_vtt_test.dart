import 'package:flutter_test/flutter_test.dart';
import 'package:dragonbane_vtt/models/character.dart';
import 'package:dragonbane_vtt/core/sync/mock_sync.dart';

void main() {
  group('Dragonbane VTT Core Models & Rules Tests', () {
    test('Character sheet condition mapping resolves correctly', () {
      final character = Character(
        id: 'test_krag',
        name: 'Krag',
        forta: 14,
        costituzione: 12,
        esausto: true, // Strength condition active
        malaticcio: false,
        hp: 12, maxHp: 12, wp: 10, maxWp: 10,
        skills: {},
      );

      // Verify that Strength (FOR) has a condition-based Bane applied
      expect(character.hasBaneForAttribute('FOR'), isTrue);
      // Verify that Constitution (COS) does NOT have a Bane
      expect(character.hasBaneForAttribute('COS'), isFalse);
    });

    test('WeaponItem serialization and deserialization works', () {
      final weapon = WeaponItem(
        name: 'Spada Lunga',
        attribute: 'FOR',
        damage: '2d6',
        range: 'Mischia',
        durability: 5,
        qualities: 'Tagliente',
      );

      final json = weapon.toJson();
      final parsed = WeaponItem.fromJson(json);

      expect(parsed.name, equals('Spada Lunga'));
      expect(parsed.attribute, equals('FOR'));
      expect(parsed.damage, equals('2d6'));
      expect(parsed.range, equals('Mischia'));
      expect(parsed.durability, equals(5));
      expect(parsed.qualities, equals('Tagliente'));
    });
  });

  group('Sync & Room Operations Simulation', () {
    test('GM creates room and Player joins to receive synced state', () async {
      final gmProvider = MockSyncProvider();
      final playerProvider = MockSyncProvider();

      // 1. GM creates the session
      final roomCreated = await gmProvider.createRoom('TEST1', 'Game Master');
      expect(roomCreated, isTrue);
      expect(gmProvider.isGm, isTrue);
      expect(gmProvider.currentRoom!.roomCode, equals('TEST1'));

      // 2. Player joins the session
      final playerJoined = await playerProvider.joinRoom('TEST1', 'Valeria');
      expect(playerJoined, isTrue);
      expect(playerProvider.isGm, isFalse);
      expect(playerProvider.currentRoom!.roomCode, equals('TEST1'));

      // 3. GM changes active map to 'temple_ruins'
      await gmProvider.changeActiveMap('temple_ruins');

      // 4. Verify that Player's provider state automatically updated to match active map
      expect(playerProvider.currentRoom!.activeMapId, equals('temple_ruins'));

      gmProvider.dispose();
      playerProvider.dispose();
    });
  });
}
