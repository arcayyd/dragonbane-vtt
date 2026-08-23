import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/sync/sync_interface.dart';
import '../core/theme.dart';
import '../models/character.dart';

class CharacterSheetView extends StatelessWidget {
  final String characterId;

  const CharacterSheetView({super.key, required this.characterId});

  void _showRollDialog(BuildContext context, String title, int targetValue, Character character, VttSyncService syncService) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text("LANCIO DI DADI", style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prova di: $title", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Valore di Successo: d20 <= $targetValue"),
              const SizedBox(height: 16),
              const Text("Seleziona la modalità del tiro:"),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                syncService.submitRoll(character.name, title, targetValue, rollMode: 'Normale', rollerCharacter: character);
              },
              style: ElevatedButton.styleFrom(backgroundColor: VttTheme.surfaceLight),
              child: const Text("NORMALE"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                syncService.submitRoll(character.name, title, targetValue, rollMode: 'Boon', rollerCharacter: character);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text("AIUTO (BOON)"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                syncService.submitRoll(character.name, title, targetValue, rollMode: 'Bane', rollerCharacter: character);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
              child: const Text("SCIAGURA (BANE)"),
            ),
          ],
        );
      },
    );
  }

  void _toggleCondition(String condKey, Character character, VttSyncService syncService) {
    Character updatedChar;
    switch (condKey) {
      case 'esausto':
        updatedChar = character.copyWith(esausto: !character.esausto);
        break;
      case 'malaticcio':
        updatedChar = character.copyWith(malaticcio: !character.malaticcio);
        break;
      case 'disorientato':
        updatedChar = character.copyWith(disorientato: !character.disorientato);
        break;
      case 'arrabbiato':
        updatedChar = character.copyWith(arrabbiato: !character.arrabbiato);
        break;
      case 'spaventato':
        updatedChar = character.copyWith(spaventato: !character.spaventato);
        break;
      case 'scoraggiato':
        updatedChar = character.copyWith(scoraggiato: !character.scoraggiato);
        break;
      default:
        return;
    }
    syncService.upsertCharacter(updatedChar);
  }

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final room = syncService.currentRoom;
    
    if (room == null) {
      return const Scaffold(body: Center(child: Text("Caricamento Stanza...")));
    }

    final character = room.characters[characterId];
    if (character == null) {
      return const Scaffold(body: Center(child: Text("Scheda personaggio non trovata.")));
    }

    // Security Check: Players cannot edit sheets that are not theirs, unless GM
    final isOwner = room.playerSelections[syncService.currentUserId] == characterId;
    final canEdit = syncService.isGm || isOwner;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: VttTheme.surface,
        title: Text(
          character.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_present, color: VttTheme.accent),
            tooltip: "Visualizza Scheda Ufficiale",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  backgroundColor: VttTheme.background,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("SCHEDA UFFICIALE DRAGONBANE"),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    body: InteractiveViewer(
                      maxScale: 4.0,
                      child: Center(
                        child: Image.asset('assets/images/character_sheet_background.png'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character Overview Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Ancestry/Stirpe: ${character.stirpe}", style: const TextStyle(fontSize: 12, color: VttTheme.textMuted)),
                        Text("Professione: ${character.professione}", style: const TextStyle(fontSize: 12, color: VttTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // HP Widget
                        Column(
                          children: [
                            const Text("PUNTI FERITA (HP)", style: TextStyle(fontSize: 9, color: VttTheme.accent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16, color: VttTheme.primaryLight),
                                  onPressed: canEdit && character.hp > 0 
                                      ? () => syncService.upsertCharacter(character.copyWith(hp: character.hp - 1)) 
                                      : null,
                                ),
                                Text("${character.hp} / ${character.maxHp}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16, color: Colors.green),
                                  onPressed: canEdit && character.hp < character.maxHp 
                                      ? () => syncService.upsertCharacter(character.copyWith(hp: character.hp + 1)) 
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // WP Widget
                        Column(
                          children: [
                            const Text("PUNTI VOLONTÀ (WP)", style: TextStyle(fontSize: 9, color: VttTheme.accent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16, color: VttTheme.primaryLight),
                                  onPressed: canEdit && character.wp > 0 
                                      ? () => syncService.upsertCharacter(character.copyWith(wp: character.wp - 1)) 
                                      : null,
                                ),
                                Text("${character.wp} / ${character.maxWp}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16, color: Colors.green),
                                  onPressed: canEdit && character.wp < character.maxWp 
                                      ? () => syncService.upsertCharacter(character.copyWith(wp: character.wp + 1)) 
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conditions section with Dragonbane mechanics
            const Text("CONDIZIONI (Sciagura al tiro collegato)", style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildConditionChip(context, "Esausto (FOR)", character.esausto, () => _toggleCondition('esausto', character, syncService), canEdit, VttTheme.conditionExhausted),
                _buildConditionChip(context, "Malaticcio (COS)", character.malaticcio, () => _toggleCondition('malaticcio', character, syncService), canEdit, VttTheme.conditionSickly),
                _buildConditionChip(context, "Disorientato (AGI)", character.disorientato, () => _toggleCondition('disorientato', character, syncService), canEdit, VttTheme.conditionDazed),
                _buildConditionChip(context, "Arrabbiato (INT)", character.arrabbiato, () => _toggleCondition('arrabbiato', character, syncService), canEdit, VttTheme.conditionAngry),
                _buildConditionChip(context, "Spaventato (VOL)", character.spaventato, () => _toggleCondition('spaventato', character, syncService), canEdit, VttTheme.conditionScared),
                _buildConditionChip(context, "Scoraggiato (CAR)", character.scoraggiato, () => _toggleCondition('scoraggiato', character, syncService), canEdit, VttTheme.conditionDisheartened),
              ],
            ),
            const SizedBox(height: 20),

            // Attributes Grid with Action Roll Buttons
            const Text("CARATTERISTICHE DI BASE", style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: [
                _buildAttributeCard(context, "FORZA (FOR)", character.forta, character.esausto, () => _showRollDialog(context, "FORZA (FOR)", character.forta, character, syncService), character),
                _buildAttributeCard(context, "COSTITUZIONE (COS)", character.costituzione, character.malaticcio, () => _showRollDialog(context, "COSTITUZIONE (COS)", character.costituzione, character, syncService), character),
                _buildAttributeCard(context, "AGILITÀ (AGI)", character.agilita, character.disorientato, () => _showRollDialog(context, "AGILITÀ (AGI)", character.agilita, character, syncService), character),
                _buildAttributeCard(context, "INTELLIGENZA (INT)", character.intelligenza, character.arrabbiato, () => _showRollDialog(context, "INTELLIGENZA (INT)", character.intelligenza, character, syncService), character),
                _buildAttributeCard(context, "VOLONTÀ (VOL)", character.volonta, character.spaventato, () => _showRollDialog(context, "VOLONTÀ (VOL)", character.volonta, character, syncService), character),
                _buildAttributeCard(context, "CARISMA (CAR)", character.carisma, character.scoraggiato, () => _showRollDialog(context, "CARISMA (CAR)", character.carisma, character, syncService), character),
              ],
            ),
            const SizedBox(height: 20),

            // Skills List
            const Text("ABILITÀ", style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: character.skills.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xff2d2d2d), height: 1),
                itemBuilder: (context, index) {
                  String skillName = character.skills.keys.elementAt(index);
                  int skillVal = character.skills.values.elementAt(index);
                  
                  // Check if this skill is currently hindered by an active condition
                  bool isHindered = false;
                  if (skillName.contains('(FOR)') && character.esausto) isHindered = true;
                  if (skillName.contains('(COS)') && character.malaticcio) isHindered = true;
                  if (skillName.contains('(AGI)') && character.disorientato) isHindered = true;
                  if (skillName.contains('(INT)') && character.arrabbiato) isHindered = true;
                  if (skillName.contains('(VOL)') && character.spaventato) isHindered = true;
                  if (skillName.contains('(CAR)') && character.scoraggiato) isHindered = true;

                  return ListTile(
                    dense: true,
                    title: Text(skillName, style: TextStyle(color: isHindered ? Colors.amber[200] : VttTheme.textLight)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHindered)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                          ),
                        Text(
                          "$skillVal", 
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            color: isHindered ? Colors.amber : VttTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.casino, size: 16, color: VttTheme.accent),
                          onPressed: () => _showRollDialog(context, skillName, skillVal, character, syncService),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip(BuildContext context, String title, bool isActive, VoidCallback onTap, bool canEdit, Color activeColor) {
    return GestureDetector(
      onTap: canEdit ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.3) : VttTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? activeColor : const BorderSide(color: Color(0xff333333)).color,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_box : Icons.check_box_outline_blank,
              size: 14,
              color: isActive ? activeColor : VttTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? VttTheme.textLight : VttTheme.textMuted,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeCard(BuildContext context, String name, int val, bool isHindered, VoidCallback onRoll, Character character) {
    return Card(
      color: isHindered ? const Color(0xff2d1f1f) : VttTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isHindered ? Colors.red[900]! : const BorderSide(color: Color(0xff333333)).color,
          width: isHindered ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onRoll,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.split(" ")[0],
                style: const TextStyle(fontSize: 8, color: VttTheme.textMuted, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$val", 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: isHindered ? Colors.red[300] : VttTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.casino, size: 12, color: isHindered ? Colors.red[300] : VttTheme.accent),
                ],
              ),
              if (isHindered)
                const Text(
                  "SCIAGURA",
                  style: TextStyle(fontSize: 6, color: Colors.amber, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
