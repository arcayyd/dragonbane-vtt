import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sync/sync_interface.dart';
import '../core/theme.dart';
import '../models/character.dart';
import '../models/map_node.dart';
import '../models/game_room.dart';
import '../models/npc_data.dart';
import '../scenes/vtt_scene_widgets.dart';
import '../scenes/scene_engine.dart';
import '../scenes/scene_registry.dart';
import '../scenes/scene_models.dart';

class SubMapView extends StatefulWidget {
  final String subMapId;

  const SubMapView({super.key, required this.subMapId});

  @override
  State<SubMapView> createState() => _SubMapViewState();
}

class _SubMapViewState extends State<SubMapView> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isDraggingToken = false;
  late TransformationController _transformationController;
  final Set<String> _locallyClosedHandouts = {};
  final Map<String, Offset> _npcHandoutOffsets = {};
  bool _wasHandoutShowing = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _fitMapToScreen() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    
    final double mapWidth = widget.subMapId == 'sentiero_iniziale' ? 1200.0 : 1000.0;
    final double mapHeight = widget.subMapId == 'sentiero_iniziale' ? 896.0 : 1000.0;

    double scaleX = size.width / mapWidth;
    double scaleY = size.height / mapHeight;
    double scale = (scaleX < scaleY ? scaleX : scaleY) * 0.95;
    
    scale = scale.clamp(0.2, 1.0);

    final double dx = (size.width - mapWidth * scale) / 2;
    final double dy = (size.height - mapHeight * scale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  String _getSubMapName(String id, VttSyncService syncService) {
    switch (id) {
      case 'outskirt_village':
      case 'villaggio_orlo':
        return "Villaggio di Orlo (Mappa Locale)";
      case 'temple_ruins': return "Tempio delle Nebbie (Mappa Tattica)";
      case 'frost_fortress': return "Forte di Ghiaccio (Mappa Tattica)";
      case 'death_swamp': return "Palude della Morte (Mappa Locale)";
      case 'secret_tomb': return "Tomba della Custodia (Sotterraneo GM)";
      case 'sentiero_iniziale': return "Sentiero: Passo di Drakmar (Mappa Tattica)";
      case 'locanda_tre_cervi': return "Locanda Ai Tre Cervi";
      case 'locanda_tre_cervi_interno': return "Locanda: Sala Comune";
      case 'locanda_tre_cervi_stanze': return "Locanda: Camere da Letto";
      case 'orlo_piazza': return "Piazza del Villaggio";
      case 'orlo_fucina': return "Fucina";
      case 'orlo_troll': return "Troll nel Fienile";
      case 'orlo_torre': return syncService.isGm ? "Torre di Zirazzia" : "Torre Antica";
      case 'guglia_troll': return "Guglia del Troll";
      case 'cultisti_impiccati': return "Cultisti Impiccati";
      case 'cavaliere_drago': return "Cavaliere del Drago";
      case 'foresta': return "Foresta";
      case 'orlo_negozio': return "Negozio di Mastro Ulvar";
      case 'orlo_tempio': return "Area del Tempio";
      case 'orlo_capanno_dranath': return "Capanno di Dranath";
      case 'orlo_mulino_halfling': return "Mulino e Panetteria Halfling";
      case 'npc_quasimodo': return "Quasimodo";
      case 'npc_sgherri_quasimodo': return "Sgherri di Quasimodo";
      default: return "Località Locale";
    }
  }

  void _showTokenMenu(BuildContext context, VttToken token, VttSyncService syncService) {
    final room = syncService.currentRoom;
    if (room == null) return;
    
    final char = room.characters[token.characterId];
    if (char == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: VttTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: VttTheme.accent, width: 1),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: token.isNpc ? VttTheme.primary : VttTheme.accent,
                      child: Text(
                        token.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(token.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            token.isNpc 
                                ? "Creatura / NPC (PF: ${char.hp}/${char.maxHp})" 
                                : "Personaggio Giocatore (PF: ${char.hp}/${char.maxHp})",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xff333333), height: 24),
                
                // NPC Statblock (GM Only)
                if (syncService.isGm && token.isNpc) ...[
                  const Text("NOTE SEGRETE GM:", style: TextStyle(fontWeight: FontWeight.bold, color: VttTheme.accent, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    char.gmNotes.isEmpty ? "Nessuna nota aggiuntiva." : char.gmNotes,
                    style: const TextStyle(fontSize: 12, color: VttTheme.textLight, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Caratteristiche: FOR ${char.forta} | COS ${char.costituzione} | AGI ${char.agilita} | INT ${char.intelligenza} | VOL ${char.volonta} | CAR ${char.carisma}",
                    style: const TextStyle(fontSize: 10, color: VttTheme.textMuted),
                  ),
                  const Divider(color: Color(0xff333333), height: 24),
                ],

                // Action controls
                if (syncService.isGm) ...[
                  ListTile(
                    leading: const Icon(Icons.edit, color: VttTheme.accent),
                    title: const Text("Modifica dettagli token / statistiche"),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showEditTokenDialog(context, token, syncService);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      token.isGmOnly ? Icons.visibility : Icons.visibility_off,
                      color: VttTheme.accent,
                    ),
                    title: Text(token.isGmOnly ? "Rendi visibile ai giocatori" : "Nascondi ai giocatori"),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      syncService.toggleTokenVisibility(token.tokenId);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: VttTheme.conditionExhausted),
                    title: const Text("Rimuovi token dalla mappa", style: TextStyle(color: VttTheme.conditionExhausted)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      syncService.removeToken(token.tokenId);
                    },
                  ),
                ] else ...[
                  // Player options: Target NPC
                  if (token.isNpc)
                    ListTile(
                      leading: Icon(
                        token.targetedByPlayerId == syncService.currentUserId 
                            ? Icons.gps_off 
                            : Icons.gps_fixed,
                        color: VttTheme.primaryLight,
                      ),
                      title: Text(
                        token.targetedByPlayerId == syncService.currentUserId 
                            ? "Rimuovi Bersaglio" 
                            : "Prendi come Bersaglio per attacco/incantesimo",
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        if (token.targetedByPlayerId == syncService.currentUserId) {
                          syncService.targetToken(token.tokenId, null);
                        } else {
                          syncService.targetToken(token.tokenId, syncService.currentUserId);
                        }
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTokenDialog(BuildContext context, VttToken token, VttSyncService syncService) {
    final room = syncService.currentRoom;
    if (room == null) return;
    
    final char = room.characters[token.characterId];
    if (char == null) return;

    final nameController = TextEditingController(text: token.name);
    final hpController = TextEditingController(text: char.hp.toString());
    final maxHpController = TextEditingController(text: char.maxHp.toString());
    bool isGmOnly = token.isGmOnly;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: VttTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: VttTheme.accent, width: 1.5),
              ),
              title: Text(
                "MODIFICA TOKEN E STATS",
                style: GoogleFonts.cinzel(color: VttTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome sul Token",
                        labelStyle: TextStyle(color: VttTheme.accent, fontSize: 12),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Punti Ferita (PF)",
                              labelStyle: TextStyle(color: VttTheme.accent, fontSize: 12),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: maxHpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "PF Massimi",
                              labelStyle: TextStyle(color: VttTheme.accent, fontSize: 12),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Invisibile per i Giocatori (GM)", style: TextStyle(color: Colors.white, fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                      activeColor: VttTheme.accent,
                      value: isGmOnly,
                      onChanged: (val) {
                        setDialogState(() {
                          isGmOnly = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("ANNULLA", style: TextStyle(color: VttTheme.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    final newHp = int.tryParse(hpController.text) ?? char.hp;
                    final newMaxHp = int.tryParse(maxHpController.text) ?? char.maxHp;

                    if (newName.isNotEmpty) {
                      final updatedChar = char.copyWith(hp: newHp, maxHp: newMaxHp);
                      syncService.upsertCharacter(updatedChar);

                      final updatedToken = token.copyWith(name: newName, isGmOnly: isGmOnly);
                      syncService.addToken(updatedToken);
                    }
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VttTheme.primary),
                  child: const Text("SALVA", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTokenDialog(BuildContext context, VttSyncService syncService, {double x = 50.0, double y = 50.0}) {
    final room = syncService.currentRoom;
    if (room == null) return;

    final characterList = room.characters.values.toList();
    if (characterList.isEmpty) return;

    String selectedCharId = characterList[0].id;
    final nameController = TextEditingController(text: characterList[0].name);
    bool isGmOnly = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: VttTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: VttTheme.accent, width: 1.5),
              ),
              title: Text(
                "AGGIUNGI NUOVO TOKEN",
                style: GoogleFonts.cinzel(color: VttTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: VttTheme.surface,
                      decoration: const InputDecoration(
                        labelText: "Seleziona Scheda Personaggio/PNG",
                        labelStyle: TextStyle(color: VttTheme.accent, fontSize: 12),
                      ),
                      value: selectedCharId,
                      items: characterList.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCharId = val;
                            final selectedChar = room.characters[val];
                            if (selectedChar != null) {
                              nameController.text = selectedChar.name;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome sul Token",
                        labelStyle: TextStyle(color: VttTheme.accent, fontSize: 12),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Invisibile per i Giocatori (GM)", style: TextStyle(color: Colors.white, fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                      activeColor: VttTheme.accent,
                      value: isGmOnly,
                      onChanged: (val) {
                        setDialogState(() {
                          isGmOnly = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("ANNULLA", style: TextStyle(color: VttTheme.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final tokenName = nameController.text.trim();
                    if (tokenName.isNotEmpty) {
                      final selectedChar = room.characters[selectedCharId];
                      final isNpc = selectedChar?.isNpc ?? true;

                      final newToken = VttToken(
                        tokenId: 'token_${DateTime.now().millisecondsSinceEpoch}',
                        characterId: selectedCharId,
                        name: tokenName,
                        x: x,
                        y: y,
                        isNpc: isNpc,
                        isGmOnly: isGmOnly,
                      );
                      syncService.addToken(newToken);
                    }
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VttTheme.primary),
                  child: const Text("AGGIUNGI", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Roll handles for monster and NPC attacks
  void _rollMonsterAction(BuildContext context, String monsterName, int roll, VttSyncService syncService) {
    final random = Random();
    String attackName = "";
    String attackDesc = "";
    String rollResultText = "";
    
    int rollDice(int count, int sides) {
      int sum = 0;
      for (int i = 0; i < count; i++) {
        sum += random.nextInt(sides) + 1;
      }
      return sum;
    }

    switch (roll) {
      case 1:
        attackName = "Balzo!";
        final dmg = rollDice(2, 8);
        attackDesc = "Il feroce warg balza addosso a un personaggio e lo sbatte violentemente a terra.";
        rollResultText = "Danno Contundente: 2D8 = $dmg | Bersaglio buttato a terra (prono).";
        break;
      case 2:
        attackName = "Colpo dall'Alto!";
        final dmg = rollDice(3, 6);
        attackDesc = "Il warg salta oltre un personaggio, mentre il suo cavaliere agita la sua scimitarra seghettata dall'alto.";
        rollResultText = "Danno Tagliente: 3D6 = $dmg.";
        break;
      case 3:
        attackName = "Ululato Famelico!";
        attackDesc = "Il warg alza la testa al cielo e ulula affamato.";
        rollResultText = "Tutti i personaggi entro 10m devono eseguire un tiro di VOLONTÀ per resistere alla paura.";
        break;
      case 4:
        attackName = "Grido di Battaglia!";
        attackDesc = "Il cavaliere incita i suoi subordinati.";
        rollResultText = "I ricognitori rimasti ottengono un FAVORE a tutti i loro attacchi fino al prossimo turno del cavalcawarg.";
        break;
      case 5:
        attackName = "Morso di Warg!";
        final dmg = rollDice(2, 10);
        final dist = rollDice(2, 4);
        attackDesc = "Il warg stringe una vittima tra le fauci sbavanti e la scuote.";
        rollResultText = "Danno Perforante: 2D10 = $dmg | Vittima scagliata a $dist metri e caduta prona.";
        break;
      case 6:
        attackName = "Carica con la Lancia!";
        final dmg = rollDice(3, 8);
        attackDesc = "Il cavalcawarg cerca di infilzare un personaggio caricandolo con la sua lancia.";
        rollResultText = "Danno Perforante: 3D8 = $dmg (può essere parato).";
        break;
    }
    
    syncService.submitRoll(
      monsterName,
      "Attacco Mostruoso [D6 = $roll]: $attackName\n$attackDesc\n\nRISULTATO: $rollResultText",
      0,
      rollMode: 'normal',
      rollerCharacter: syncService.currentRoom!.characters['npc_cavalcawarg']!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tirato Attacco Mostruoso $roll: $attackName"),
        backgroundColor: VttTheme.primary,
      ),
    );
  }

  void _rollNpcWeapon(BuildContext context, String npcName, String weaponName, int skillLevel, int damageSides, Character character, VttSyncService syncService) {
    final random = Random();
    final d20 = random.nextInt(20) + 1;
    
    bool isSuccess = d20 <= skillLevel && d20 < 20;
    bool isDragon = d20 == 1;
    bool isDemon = d20 == 20;
    
    String outcome = "";
    int damage = 0;
    
    if (isDragon) {
      outcome = "DRAGO! (Successo Critico!)";
      damage = (random.nextInt(damageSides) + 1) + (random.nextInt(damageSides) + 1);
    } else if (isDemon) {
      outcome = "DEMONE! (Fallimento Critico!)";
    } else if (isSuccess) {
      outcome = "SUCCESSO!";
      damage = random.nextInt(damageSides) + 1;
    } else {
      outcome = "FALLIMENTO!";
    }
    
    String detail = "Tiro d20: $d20 vs Abilità $skillLevel -> $outcome";
    if (isSuccess || isDragon) {
      detail += "\nDanno: ${isDragon ? '2' : '1'}D$damageSides = $damage";
    }
    
    syncService.submitRoll(
      npcName,
      "Attacco con $weaponName\n$detail",
      skillLevel,
      rollMode: 'normal',
      rollerCharacter: character,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Attacco con $weaponName: $outcome (d20=$d20)"),
        backgroundColor: isSuccess || isDragon ? Colors.green[800] : Colors.red[900],
      ),
    );
  }

  TableRow _buildMonsterAttackTableRow(BuildContext context, String monsterName, int roll, String name, String desc, VttSyncService syncService) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xff2d231a), width: 0.5)),
      ),
      children: [
        TableCell(
          child: InkWell(
            onTap: () => _rollMonsterAction(context, monsterName, roll, syncService),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Center(
                child: Text(
                  "$roll",
                  style: const TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: InkWell(
            onTap: () => _rollMonsterAction(context, monsterName, roll, syncService),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8.5),
              ),
            ),
          ),
        ),
        TableCell(
          child: InkWell(
            onTap: () => _rollMonsterAction(context, monsterName, roll, syncService),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      desc,
                      style: const TextStyle(color: VttTheme.textMuted, fontSize: 8.5),
                    ),
                  ),
                  const Icon(Icons.casino, size: 9, color: VttTheme.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDragonBox({required String title, required String subtitle, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xff251f1a),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xff8a1c1c), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xff8a1c1c),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          color: const Color(0xffefebe4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xffd4af37),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.shield, size: 14, color: Color(0xffefebe4)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(String keyword, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xff60a358), fontSize: 11)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 10, color: Color(0xffefebe4), height: 1.3),
                children: [
                  TextSpan(
                    text: "$keyword ",
                    style: const TextStyle(color: Color(0xff60a358), fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretItem(String keyword, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xffe57373), fontSize: 11)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 10, color: Color(0xffefebe4), height: 1.3),
                children: [
                  TextSpan(
                    text: "$keyword ",
                    style: const TextStyle(
                      color: Color(0xffe57373),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoldItem(String keyword, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: VttTheme.accent, fontSize: 11)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 10, color: Color(0xffefebe4), height: 1.3),
                children: [
                  TextSpan(
                    text: "$keyword ",
                    style: const TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNpcStatblockCard(BuildContext context, String characterId, GameRoom room, VttSyncService syncService) {
    final char = room.characters[characterId];
    if (char == null) return const SizedBox.shrink();

    final isWarg = characterId == 'npc_cavalcawarg';

    return _buildDragonBox(
      title: char.name,
      subtitle: "Stirpe: ${char.stirpe} | Ruolo: ${char.professione}",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP Tracker inside sidebar card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: VttTheme.conditionExhausted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Punti Ferita: ${char.hp} / ${char.maxHp}",
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 14, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final newHp = (char.hp - 1).clamp(0, char.maxHp);
                      syncService.upsertCharacter(char.copyWith(hp: newHp));
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, size: 14, color: Colors.green),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final newHp = (char.hp + 1).clamp(0, char.maxHp);
                      syncService.upsertCharacter(char.copyWith(hp: newHp));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Stat values grid (Tablebox style)
          Table(
            border: TableBorder.all(color: const Color(0xff4a3b32), width: 0.5),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xff2d221a)),
                children: [
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("FOR", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("COS", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("AGI", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("INT", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("VOL", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text("CAR", style: TextStyle(fontSize: 8, color: VttTheme.accent, fontWeight: FontWeight.bold))))),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Color(0xff181411)),
                children: [
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.forta}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.costituzione}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.agilita}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.intelligenza}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.volonta}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                  TableCell(child: Padding(padding: const EdgeInsets.all(4), child: Center(child: Text("${char.carisma}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Movement and Armor info (formatted as lists)
          _buildColorItem("Movimento:", "${isWarg ? '20' : '10'} metri"),
          _buildColorItem("Armatura:", isWarg ? "Nessuna" : "Cuoio (Valore: 1)"),
          const Divider(color: Color(0xff4a3b32), height: 16),

          // Skills
          const Text(
            "ABILITÀ DI COMBATTIMENTO:",
            style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: char.skills.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xff2d221a),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xff4a3b32), width: 0.5),
                ),
                child: Text(
                  "${e.key}: ${e.value}",
                  style: const TextStyle(color: Color(0xffefebe4), fontSize: 9),
                ),
              );
            }).toList(),
          ),
          const Divider(color: Color(0xff4a3b32), height: 16),

          // Weapons & Attacks
          const Text(
            "ATTACCHI E ARMI (Clicca per lanciare):",
            style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
          ),
          const SizedBox(height: 6),

          // Weapon buttons
          ...char.weapons.map((w) {
            final skillLevel = char.skills.entries
                .firstWhere((e) => e.key.split(" ")[0].toLowerCase().contains(w.name.split(" ")[0].toLowerCase()), orElse: () => MapEntry(isWarg ? 'Spade (FOR)' : 'Archi (AGI)', isWarg ? 12 : 10))
                .value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () {
                  _rollNpcWeapon(
                    context,
                    char.name,
                    w.name,
                    skillLevel,
                    w.damage.contains('10') ? 10 : 8,
                    char,
                    syncService,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xff181411),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xff8a1c1c), width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🗡️  ${w.name} (Gr. $skillLevel)",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Danno: ${w.damage}  ➔",
                        style: const TextStyle(color: VttTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Special Monster Attacks Table (Warg Rider only!) styled as Tablebox!
          if (isWarg) ...[
            const Divider(color: Color(0xff4a3b32), height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ATTACCHI MOSTRUOSI (D6):",
                  style: TextStyle(color: Color(0xffe57373), fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
                ),
                ElevatedButton(
                  onPressed: () {
                    final random = Random();
                    final roll = random.nextInt(6) + 1;
                    _rollMonsterAction(context, char.name, roll, syncService);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    backgroundColor: const Color(0xff8a1c1c),
                    minimumSize: Size.zero,
                  ),
                  child: const Text("TIRA ATTACCO D6", style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Interactive TableBox!
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff181411),
                border: Border.all(color: const Color(0xff4a3b32), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(24),
                  1: FixedColumnWidth(90),
                  2: FlexColumnWidth(),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color(0xff2d221a),
                      border: Border(bottom: BorderSide(color: Color(0xff8a1c1c), width: 1.5)),
                    ),
                    children: [
                      Padding(padding: EdgeInsets.all(6), child: Center(child: Text("D6", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VttTheme.accent)))),
                      Padding(padding: EdgeInsets.all(6), child: Text("NOME", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VttTheme.accent))),
                      Padding(padding: EdgeInsets.all(6), child: Text("DESCRIZIONE & DANNO", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: VttTheme.accent))),
                    ],
                  ),
                  _buildMonsterAttackTableRow(context, char.name, 1, "Balzo!", "2D8 contundenti + atterramento", syncService),
                  _buildMonsterAttackTableRow(context, char.name, 2, "Colpo dall'Alto!", "3D6 taglienti", syncService),
                  _buildMonsterAttackTableRow(context, char.name, 3, "Ululato Famelico!", "Tiro VOL per resistere alla paura", syncService),
                  _buildMonsterAttackTableRow(context, char.name, 4, "Grido di Battaglia!", "Favore agli attacchi dei ricognitori", syncService),
                  _buildMonsterAttackTableRow(context, char.name, 5, "Morso di Warg!", "2D10 perforanti + spinta e prono", syncService),
                  _buildMonsterAttackTableRow(context, char.name, 6, "Carica con Lancia!", "3D8 perforanti (parabile)", syncService),
                ],
              ),
            ),
          ],

          // Secret Details (SecretItem notes)
          const Divider(color: Color(0xff4a3b32), height: 16),
          if (isWarg) ...[
            _buildSecretItem("Tratti Speciali:", "Ferocia 2, Taglia Normale. Conta come mostro."),
            _buildSecretItem("Cavalcature:", "Il Warg sanguinario morde con ferocia inaudita. Il cavaliere coordina gli attacchi."),
          ] else ...[
            _buildSecretItem("Comportamento:", "Codardo. Fugge se i PF scendono sotto la metà."),
            _buildSecretItem("Segnale:", "Porta il marchio nero di Maladûk sulla spalla destra."),
          ],
        ],
      ),
    );
  }

  Widget _buildStaticNpcStatblockCard(BuildContext context, NpcData npc, GameRoom room, VttSyncService syncService) {
    return _buildDragonBox(
      title: npc.name,
      subtitle: npc.category == 'orlo' ? "PNG DI ORLO" : "PNG DI VIAGGIO",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "STATISTICHE DI GIOCO",
                style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final isCurrentlyRevealed = room.revealedHandouts['show_npc_${npc.id}'] == 1;
                  if (isCurrentlyRevealed) {
                    syncService.hideHandout('show_npc_${npc.id}');
                  } else {
                    syncService.revealHandout('show_npc_${npc.id}');
                  }
                },
                icon: Icon(
                  room.revealedHandouts['show_npc_${npc.id}'] == 1 ? Icons.visibility_off : Icons.visibility,
                  size: 10,
                  color: Colors.white,
                ),
                label: Text(
                  room.revealedHandouts['show_npc_${npc.id}'] == 1 ? "NASCONDI AI GIOCATORI" : "MOSTRA AI GIOCATORI",
                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  backgroundColor: room.revealedHandouts['show_npc_${npc.id}'] == 1 ? const Color(0xff8a1c1c) : Colors.green[800],
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            npc.description,
            style: const TextStyle(color: Color(0xffefebe4), fontSize: 10, height: 1.4),
          ),
          const Divider(color: Color(0xff4a3b32), height: 16),
          if (npc.stats.isNotEmpty) ...[
            ...npc.stats.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
            const Divider(color: Color(0xff4a3b32), height: 16),
          ],
          if (npc.skills.isNotEmpty) ...[
            const Text(
              "ABILITÀ:",
              style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              npc.skills.join(", "),
              style: const TextStyle(color: Color(0xffefebe4), fontSize: 9),
            ),
            const Divider(color: Color(0xff4a3b32), height: 16),
          ],
          if (npc.weapons.isNotEmpty) ...[
            const Text(
              "ARMI:",
              style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            ...npc.weapons.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                "🗡️  $w",
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )),
            const Divider(color: Color(0xff4a3b32), height: 16),
          ],
          if (npc.abilities.isNotEmpty) ...[
            const Text(
              "CAPACITÀ SPECIALI:",
              style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              npc.abilities.join(", "),
              style: const TextStyle(color: Color(0xffefebe4), fontSize: 9, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGmStatblocksPanel(BuildContext context, GameRoom room, VttSyncService syncService) {
    final npcCharacterIds = room.tokens
        .where((t) => t.isNpc)
        .map((t) => t.characterId)
        .toSet()
        .toList();

    final List<NpcData> activeStaticNpcs = [];
    final activeGmNpcId = syncService.activeGmNpcId;
    
    // Inseriamo in cima l'NPC selezionato dal GM
    if (activeGmNpcId != null) {
      final selectedNpc = npcList.firstWhere((n) => n.id == activeGmNpcId, orElse: () => npcList.first);
      activeStaticNpcs.add(selectedNpc);
    }
    
    // E poi tutti gli altri rivelati
    for (final npc in npcList) {
      if (room.revealedHandouts['show_npc_${npc.id}'] == 1 && npc.id != activeGmNpcId) {
        activeStaticNpcs.add(npc);
      }
    }

    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: Color(0xff181818),
        border: Border(
          left: BorderSide(color: Color(0xff2d2d2d), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: VttTheme.surfaceLight,
            child: const Row(
              children: [
                Icon(Icons.menu_book, color: VttTheme.accent, size: 16),
                SizedBox(width: 8),
                Text(
                  "SCHEDE MOSTRI & PNG",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (npcCharacterIds.isEmpty && activeStaticNpcs.isEmpty)
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Nessuna scheda PNG per questa località.",
                        style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (activeStaticNpcs.isNotEmpty) ...[
                        ...activeStaticNpcs.map((npc) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildStaticNpcStatblockCard(context, npc, room, syncService),
                            )),
                        if (npcCharacterIds.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: Color(0xff3d332a), thickness: 1.5),
                          ),
                        ],
                      ],
                      ...npcCharacterIds.map((charId) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildNpcStatblockCard(context, charId, room, syncService),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final room = syncService.currentRoom;

    if (room != null) {
      for (final npc in npcList) {
        if (room.revealedHandouts['show_npc_${npc.id}'] != 1) {
          _locallyClosedHandouts.remove(npc.id);
        }
      }
    }

    if (room == null) {
      return const Scaffold(body: Center(child: Text("Nessuna sessione attiva.")));
    }

    final int sceneIndex = room.revealedHandouts[widget.subMapId] ?? 0;

    // Filter tokens by Player vs GM permissions, adjusting visibility based on scene index
    final displayTokens = room.tokens.map((t) {
      if (widget.subMapId == 'sentiero_iniziale') {
        bool effectiveIsGmOnly = t.isGmOnly;
        // At sceneIndex >= 5 (Scene 6): Goblins visible
        if (sceneIndex >= 5 && t.tokenId.startsWith('token_goblin')) {
          effectiveIsGmOnly = false;
        }
        // At sceneIndex >= 6 (Scene 7): Warg Rider visible
        if (sceneIndex >= 6 && t.tokenId.startsWith('token_cavalcawarg')) {
          effectiveIsGmOnly = false;
        }
        return t.copyWith(isGmOnly: effectiveIsGmOnly);
      }
      return t;
    }).where((t) {
      if (syncService.isGm) return true; // GM sees everything
      return !t.isGmOnly; // Players only see visible ones
    }).toList();

    final double mapWidth = widget.subMapId == 'sentiero_iniziale' ? 1200.0 : 1000.0;
    final double mapHeight = widget.subMapId == 'sentiero_iniziale' ? 896.0 : 1000.0;

    // 1. Build the map canvas layout widget (can be zoomed & panned)
    Widget mapLayout = LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            maxScale: 4.0,
            minScale: 0.2,
            panEnabled: !_isDraggingToken,
            scaleEnabled: !_isDraggingToken,
            constrained: false, // Zoom and pan a fixed size canvas
            child: DragTarget<VttToken>(
              onAcceptWithDetails: (details) {
                final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localOffset = renderBox.globalToLocal(details.offset);
                  
                  // Adjust for token center (22 pixels)
                  double newX = ((localOffset.dx + 22) / mapWidth) * 100;
                  double newY = ((localOffset.dy + 22) / mapHeight) * 100;
                  
                  newX = newX.clamp(0.0, 95.0);
                  newY = newY.clamp(0.0, 95.0);
                  
                  syncService.updateTokenPosition(details.data.tokenId, newX, newY);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  key: _canvasKey,
                  width: mapWidth,
                  height: mapHeight,
                  color: const Color(0xff141414),
                  child: Stack(
                    children: [
                      // Immersive tactical grid representing sub-map combat layout with tap-to-create token support
                      GestureDetector(
                        onTapUp: (details) {
                          if (syncService.isGm) {
                            final double tapX = (details.localPosition.dx / mapWidth) * 100;
                            final double tapY = (details.localPosition.dy / mapHeight) * 100;
                            _showAddTokenDialog(context, syncService, x: tapX, y: tapY);
                          }
                        },
                        child: widget.subMapId == 'sentiero_iniziale'
                            ? Image.asset(
                                'assets/images/sentiero_tattico.png',
                                width: mapWidth,
                                height: mapHeight,
                                fit: BoxFit.fill,
                              )
                            : CustomPaint(
                                size: Size(mapWidth, mapHeight),
                                painter: TacticalGridPainter(isTomb: widget.subMapId == 'secret_tomb'),
                                child: Container(
                                  width: mapWidth,
                                  height: mapHeight,
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  child: Text(
                                    "GRIGLIA DI COMBATTIMENTO",
                                    style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      color: VttTheme.accent.withAlpha(10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // Tactical grid overlaid on top of the sentiero map to ensure quadretti show nicely
                      if (widget.subMapId == 'sentiero_iniziale')
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: TacticalGridPainter(isTomb: false, overlayMode: true),
                            ),
                          ),
                        ),

                      // Tactical tokens (PCs & NPCs) layer with Drag-and-Drop
                      ...displayTokens.map((token) {
                        final isMyToken = token.characterId == room.playerSelections[syncService.currentUserId];
                        final canDrag = syncService.isGm || isMyToken;

                        Widget tokenWidget = GestureDetector(
                          onTap: () => _showTokenMenu(context, token, syncService),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ring marker based on NPC vs Player
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: token.isGmOnly 
                                      ? Colors.purple.withOpacity(0.3) 
                                      : (token.isNpc ? VttTheme.primary.withOpacity(0.4) : VttTheme.accent.withOpacity(0.4)),
                                  border: Border.all(
                                    color: token.isGmOnly 
                                        ? Colors.purple 
                                        : (token.isNpc ? VttTheme.primaryLight : VttTheme.accent),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    token.name.substring(0, token.name.length >= 2 ? 2 : 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                              // GM Hidden Badge Icon
                              if (token.isGmOnly)
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(Icons.visibility_off, size: 14, color: Colors.purple),
                                ),

                              // Player Target reticle overlay
                              if (token.targetedByPlayerId != null)
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.redAccent, width: 2, style: BorderStyle.solid),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                      child: Text(
                                        token.targetedByPlayerId!.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        // If user is GM or owns the token, let them drag it around
                        if (canDrag) {
                          tokenWidget = Draggable<VttToken>(
                            data: token,
                            onDragStarted: () {
                              setState(() {
                                _isDraggingToken = true;
                              });
                            },
                            onDragEnd: (details) {
                              setState(() {
                                _isDraggingToken = false;
                              });
                            },
                            onDraggableCanceled: (velocity, offset) {
                              setState(() {
                                _isDraggingToken = false;
                              });
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.8,
                                child: tokenWidget,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: tokenWidget,
                            ),
                            child: tokenWidget,
                          );
                        }

                        // Place token at saved sync coordinates
                        return Positioned(
                          left: (token.x / 100) * mapWidth - 22,
                          top: (token.y / 100) * mapHeight - 22,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              tokenWidget,
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  token.name,
                                  style: TextStyle(
                                    fontSize: 9, 
                                    color: isMyToken ? VttTheme.accent : VttTheme.textLight,
                                    fontWeight: isMyToken ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // 2. Wrap body with split layout for GMs
    Widget bodyWidget = mapLayout;
    final sceneConfig = sceneRegistry[widget.subMapId];
    final currentScene = sceneConfig?.sceneAt(sceneIndex);
    final int maxSceneIndex = (sceneConfig?.scenes.length ?? 1) - 1;
    final showHandout = currentScene?.showCinematic == true && currentScene?.subMapAsset == null;

    if (_wasHandoutShowing && !showHandout) {
      _transformationController.value = Matrix4.identity();
      _wasHandoutShowing = false;
    } else if (!showHandout) {
      _wasHandoutShowing = false;
    } else {
      _wasHandoutShowing = true;
    }

    if (showHandout) {
      final effectiveOverlay = currentScene?.overlay ?? sceneConfig!.defaultOverlay;
      final backgroundAsset = currentScene?.backgroundAsset ?? sceneConfig!.defaultBackground;

      final handoutPane = Container(
        color: const Color(0xff0b0908),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image (from registry)
            Image.asset(backgroundAsset, fit: BoxFit.cover),

            // Animated overlay (from registry)
            Positioned.fill(
              child: switch (effectiveOverlay) {
                SceneOverlay.smoke => const AnimatedSmokeOverlay(),
                SceneOverlay.sunlight => const AnimatedSunlightOverlay(),
                SceneOverlay.none => const SizedBox.shrink(),
              },
            ),

            // Handout card for this scene (delegated to engine)
            SceneEngine.buildHandoutLayer(
              scene: currentScene,
              isGm: syncService.isGm,
              syncService: syncService,
              room: room,
              subMapId: widget.subMapId,
            ),

            // Cinematic gradient bars
            Positioned(
              top: 0, left: 0, right: 0, height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Scene navigation controls (Directional or GM Actions or GM Previous/Next)
            if (currentScene != null &&
                (currentScene.directions.isNotEmpty || (syncService.isGm && currentScene.gmActions.isNotEmpty)))
              directionalSceneControls(
                directions: currentScene.directions,
                gmActions: currentScene.gmActions,
                isGm: syncService.isGm,
                onSelectDirection: (targetIndex, {actionLabel}) {
                  if (syncService.isGm) {
                    if (actionLabel != null && actionLabel.toLowerCase().contains("arpie")) {
                      if (room.revealedHandouts['show_arpie_handout'] == 1) {
                        syncService.hideHandout('show_arpie_handout');
                      } else {
                        syncService.revealHandout('show_arpie_handout');
                      }
                    } else if (actionLabel != null && actionLabel.toLowerCase().contains("harga")) {
                      if (room.revealedHandouts['show_harga_handout'] == 1) {
                        syncService.hideHandout('show_harga_handout');
                      } else {
                        syncService.revealHandout('show_harga_handout');
                      }
                    } else if (actionLabel != null && actionLabel.toLowerCase().contains("ambrosius")) {
                      if (room.revealedHandouts['show_ambrosius_handout'] == 1) {
                        syncService.hideHandout('show_ambrosius_handout');
                      } else {
                        syncService.revealHandout('show_ambrosius_handout');
                      }
                    } else {
                      syncService.changeActiveMap(widget.subMapId, sceneIndex: targetIndex);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solo il GM può cambiare la scena attiva.")),
                    );
                  }
                },
              )
            else if (syncService.isGm)
              gmSceneControls(
                sceneIndex: sceneIndex,
                onPrev: () => syncService.hideHandout(widget.subMapId),
                onNext: () => syncService.revealHandout(widget.subMapId),
                hasNext: sceneIndex < maxSceneIndex,
              ),
          ],
        ),
      );

      if (syncService.isGm) {
        bodyWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: handoutPane),
            _buildGmIntroNotesPanel(context, sceneIndex),
          ],
        );
      } else {
        bodyWidget = handoutPane;
      }
    } else if (currentScene?.subMapAsset != null) {
      // Sub-location map with clickable pins (e.g. Orlo village map)
      final subMap = SceneEngine.buildSubLocationMap(
        scene: currentScene!,
        isGm: syncService.isGm,
        syncService: syncService,
        subMapId: widget.subMapId,
      );
      if (syncService.isGm) {
        bodyWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: subMap),
            _buildGmStatblocksPanel(context, room, syncService),
          ],
        );
      } else {
        bodyWidget = subMap;
      }
    } else {
      if (syncService.isGm) {
        bodyWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: mapLayout),
            _buildGmStatblocksPanel(context, room, syncService),
          ],
        );
      }
    }

    return Scaffold(
      appBar: (showHandout && !syncService.isGm) ? null : AppBar(
        backgroundColor: VttTheme.surface,
        leading: (syncService.isGm && widget.subMapId != 'villaggio_orlo' && widget.subMapId != 'overworld')
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: VttTheme.accent),
                tooltip: "Torna alla Mappa del Villaggio",
                onPressed: () {
                  syncService.changeActiveMap('villaggio_orlo', sceneIndex: 2);
                },
              )
            : null,
        title: Text(
          _getSubMapName(widget.subMapId, syncService).toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen, color: VttTheme.accent),
            tooltip: "Schermo Intero (Browser)",
            onPressed: () {
              if (kIsWeb) {
                try {
                  js.context.callMethod('eval', [
                    "if (!document.fullscreenElement) { "
                    "  document.documentElement.requestFullscreen(); "
                    "} else { "
                    "  if (document.exitFullscreen) { document.exitFullscreen(); } "
                    "}"
                  ]);
                } catch (e) {
                  // Silent
                }
              }
            },
          ),
          if (syncService.isGm) ...[
            if (sceneIndex > 0)
              TextButton.icon(
                icon: const Icon(Icons.history, color: VttTheme.accent, size: 18),
                label: Text(
                  "SCENA PREC.",
                  style: GoogleFonts.cinzel(
                    color: VttTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () {
                  syncService.hideHandout(widget.subMapId);
                },
              ),
            if (sceneIndex < maxSceneIndex)
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward, color: Color(0xffdfc48c), size: 18),
                label: Text(
                  "PROSSIMA SCENA",
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffdfc48c),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () {
                  syncService.revealHandout(widget.subMapId);
                },
              ),
            if (sceneIndex >= 3)
              TextButton.icon(
                icon: Icon(
                  Icons.psychology,
                  color: room.revealedHandouts['show_maladuk_symbol'] == 1
                      ? Colors.green
                      : VttTheme.accent,
                  size: 18,
                ),
                label: Text(
                  room.revealedHandouts['show_maladuk_symbol'] == 1
                      ? "CHIUDI SIMBOLO"
                      : "SIMBOLO MALADÛK",
                  style: GoogleFonts.cinzel(
                    color: room.revealedHandouts['show_maladuk_symbol'] == 1
                        ? Colors.green
                        : VttTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () {
                  if (room.revealedHandouts['show_maladuk_symbol'] == 1) {
                    syncService.hideHandout('show_maladuk_symbol');
                  } else {
                    syncService.revealHandout('show_maladuk_symbol');
                  }
                },
              ),
            if (sceneIndex >= 6)
              TextButton.icon(
                icon: Icon(
                  Icons.pets,
                  color: room.revealedHandouts['show_cavalcawarg_handout'] == 1
                      ? Colors.green
                      : VttTheme.accent,
                  size: 18,
                ),
                label: Text(
                  room.revealedHandouts['show_cavalcawarg_handout'] == 1
                      ? "CHIUDI CAVALCAWARG"
                      : "IL CAVALCAWARG",
                  style: GoogleFonts.cinzel(
                    color: room.revealedHandouts['show_cavalcawarg_handout'] == 1
                        ? Colors.green
                        : VttTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () {
                  if (room.revealedHandouts['show_cavalcawarg_handout'] == 1) {
                    syncService.hideHandout('show_cavalcawarg_handout');
                  } else {
                    syncService.revealHandout('show_cavalcawarg_handout');
                  }
                },
              ),
            TextButton.icon(
              icon: const Icon(Icons.download, color: VttTheme.accent, size: 16),
              label: Text(
                "ESPORTA MOSTRI",
                style: GoogleFonts.cinzel(
                  color: VttTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: () {
                final nonPlayerTokens = room.tokens.where((t) => t.isNpc).toList();
                final tokensJson = nonPlayerTokens.map((t) => t.toJson()).toList();
                final jsonString = const JsonEncoder.withIndent('  ').convert(tokensJson);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: VttTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: VttTheme.accent, width: 1.5),
                    ),
                    title: Text(
                      "ESPORTA CONFIGURAZIONE TOKEN",
                      style: GoogleFonts.cinzel(color: VttTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Copia il testo qui sotto per salvare le posizioni dei token in modo permanente nel file mock_sync.dart!",
                          style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xff444444)),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              jsonString,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: VttTheme.textLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("CHIUDI", style: TextStyle(color: VttTheme.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: jsonString));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Configurazione JSON copiata negli appunti!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VttTheme.primary,
                        ),
                        child: const Text("COPIA NEGLI APPUNTI", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (currentScene?.subMapAsset != null)
              TextButton.icon(
                icon: const Icon(Icons.edit_note, color: VttTheme.accent, size: 18),
                label: Text(
                  "EDITA BOLLINI",
                  style: GoogleFonts.cinzel(
                    color: VttTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: () {
                  _showEditPinsJsonDialog(context, room, syncService, widget.subMapId);
                },
              ),
            TextButton.icon(
              icon: const Icon(Icons.restart_alt, color: VttTheme.accent, size: 16),
              label: Text(
                "RIPRISTINA MAPPA",
                style: GoogleFonts.cinzel(
                  color: VttTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: VttTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: VttTheme.accent, width: 1.5),
                    ),
                    title: Text(
                      "RIPRISTINA LOCALITÀ?",
                      style: GoogleFonts.cinzel(color: VttTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      "Questa azione ripristinerà la mappa tattica corrente alla configurazione iniziale (token, posizioni, nemici di default). Procedere?",
                      style: TextStyle(color: VttTheme.textLight),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("ANNULLA", style: TextStyle(color: VttTheme.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          syncService.changeActiveMap(widget.subMapId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mappa ripristinata alla configurazione iniziale!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8a1c1c),
                        ),
                        child: const Text("RIPRISTINA", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: VttTheme.accent),
              tooltip: "Aggiungi Token alla Mappa",
              onPressed: () => _showAddTokenDialog(context, syncService),
            ),
          ],
          if (widget.subMapId == 'locanda_tre_cervi' || widget.subMapId == 'locanda_tre_cervi_interno' || widget.subMapId == 'locanda_tre_cervi_stanze' || widget.subMapId == 'orlo_piazza' || widget.subMapId == 'orlo_fucina' || widget.subMapId == 'orlo_troll' || widget.subMapId == 'orlo_torre') ...[
            TextButton.icon(
              icon: const Icon(Icons.holiday_village, color: VttTheme.accent, size: 16),
              label: Text(
                "TORNA A ORLO",
                style: GoogleFonts.cinzel(
                  color: VttTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: () {
                if (syncService.isGm) {
                  syncService.changeActiveMap('villaggio_orlo', sceneIndex: 2);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                  );
                }
              },
            ),
            if (widget.subMapId != 'locanda_tre_cervi' && (widget.subMapId == 'locanda_tre_cervi_interno' || widget.subMapId == 'locanda_tre_cervi_stanze'))
              TextButton.icon(
                icon: const Icon(Icons.store, color: VttTheme.accent, size: 16),
                label: Text(
                  "ESTERNO",
                  style: GoogleFonts.cinzel(
                    color: VttTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: () {
                  if (syncService.isGm) {
                    syncService.changeActiveMap('locanda_tre_cervi');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                    );
                  }
                },
              ),
            if (widget.subMapId != 'locanda_tre_cervi_interno' && (widget.subMapId == 'locanda_tre_cervi' || widget.subMapId == 'locanda_tre_cervi_stanze'))
              TextButton.icon(
                icon: const Icon(Icons.fireplace, color: VttTheme.accent, size: 16),
                label: Text(
                  "INTERNO",
                  style: GoogleFonts.cinzel(
                    color: VttTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: () {
                  if (syncService.isGm) {
                    syncService.changeActiveMap('locanda_tre_cervi_interno');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                    );
                  }
                },
              ),
            if (widget.subMapId != 'locanda_tre_cervi_stanze' && (widget.subMapId == 'locanda_tre_cervi' || widget.subMapId == 'locanda_tre_cervi_interno'))
              TextButton.icon(
                icon: const Icon(Icons.bed, color: VttTheme.accent, size: 16),
                label: Text(
                  "STANZE",
                  style: GoogleFonts.cinzel(
                    color: VttTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: () {
                  if (syncService.isGm) {
                    syncService.changeActiveMap('locanda_tre_cervi_stanze');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                    );
                  }
                },
              ),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7a1515),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xffdfc48c), width: 1),
              ),
            ),
            icon: const Icon(Icons.public, color: Color(0xffdfc48c), size: 16),
            label: Text(
              "MAPPA DELLA VALLE",
              style: GoogleFonts.cinzel(
                color: const Color(0xffdfc48c),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (syncService.isGm) {
                syncService.changeActiveMap('overworld');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ritorno alla Mappa della Valle per tutti!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          bodyWidget,
          if (room.revealedHandouts['show_maladuk_symbol'] == 1) ...[
            // Dim background overlay
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                width: 480,
                height: 540,
                decoration: BoxDecoration(
                  color: const Color(0xff141210),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdfc48c), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ]
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24), // to balance the close button
                        Expanded(
                          child: Text(
                            "UNO STRANO TATUAGGIO",
                            style: GoogleFonts.cinzel(
                              color: const Color(0xffdfc48c),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (syncService.isGm)
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 20),
                            tooltip: "Chiudi Handout",
                            onPressed: () {
                              syncService.hideHandout('show_maladuk_symbol');
                            },
                          )
                        else
                          const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xff3d332a), height: 12, thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/simbolo_maladuk.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (room.revealedHandouts['show_cavalcawarg_handout'] == 1) ...[
            // Dim background overlay
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                width: 480,
                height: 540,
                decoration: BoxDecoration(
                  color: const Color(0xff141210),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdfc48c), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            "IL CAVALCAWARG",
                            style: GoogleFonts.cinzel(
                              color: const Color(0xffdfc48c),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (syncService.isGm)
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 20),
                            tooltip: "Chiudi Handout",
                            onPressed: () {
                              syncService.hideHandout('show_cavalcawarg_handout');
                            },
                          )
                        else
                          const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xff3d332a), height: 12, thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/cavalcawarg_handout.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (room.revealedHandouts['show_arpie_handout'] == 1) ...[
            // Dim background overlay
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                width: 680,
                height: 520,
                decoration: BoxDecoration(
                  color: const Color(0xff141210),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdfc48c), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ]
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            "LE ARPIE DELLA GUGLIA",
                            style: GoogleFonts.cinzel(
                              color: const Color(0xffdfc48c),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 24),
                          tooltip: "Chiudi Handout",
                          onPressed: () {
                            if (syncService.isGm) {
                              syncService.hideHandout('show_arpie_handout');
                            } else {
                              setState(() {
                                room.revealedHandouts['show_arpie_handout'] = 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xff3d332a), height: 12, thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/arpie_handout.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (room.revealedHandouts['show_harga_handout'] == 1) ...[
            // Dim background overlay
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                width: 520,
                height: 620,
                decoration: BoxDecoration(
                  color: const Color(0xff141210),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdfc48c), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ]
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            "HARGA LA TROLL",
                            style: GoogleFonts.cinzel(
                              color: const Color(0xffdfc48c),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 24),
                          tooltip: "Chiudi Handout",
                          onPressed: () {
                            if (syncService.isGm) {
                              syncService.hideHandout('show_harga_handout');
                            } else {
                              setState(() {
                                room.revealedHandouts['show_harga_handout'] = 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xff3d332a), height: 12, thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/harga_handout.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (room.revealedHandouts['show_ambrosius_handout'] == 1) ...[
            // Dim background overlay
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            Center(
              child: Container(
                width: 520,
                height: 540,
                decoration: BoxDecoration(
                  color: const Color(0xff141210),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffdfc48c), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ]
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            "AMBROSIUS IL ROSPO",
                            style: GoogleFonts.cinzel(
                              color: const Color(0xffdfc48c),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 24),
                          tooltip: "Chiudi Handout",
                          onPressed: () {
                            if (syncService.isGm) {
                              syncService.hideHandout('show_ambrosius_handout');
                            } else {
                              setState(() {
                                room.revealedHandouts['show_ambrosius_handout'] = 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xff3d332a), height: 12, thickness: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/ambrosius_handout.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ...npcList.map((npc) {
            final isRevealed = room.revealedHandouts['show_npc_${npc.id}'] == 1;
            if (!isRevealed || _locallyClosedHandouts.contains(npc.id)) return const SizedBox.shrink();
            final offset = _npcHandoutOffsets[npc.id] ?? const Offset(80, 80);
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _npcHandoutOffsets[npc.id] = offset + details.delta;
                  });
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 300,
                    height: 360,
                    decoration: BoxDecoration(
                      color: const Color(0xff141210),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffdfc48c), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: Text(
                                npc.name.toUpperCase(),
                                style: GoogleFonts.cinzel(
                                  color: const Color(0xffdfc48c),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xff8a1c1c), size: 16),
                              tooltip: "Chiudi Handout",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (syncService.isGm) {
                                  syncService.hideHandout('show_npc_${npc.id}');
                                } else {
                                  setState(() {
                                    _locallyClosedHandouts.add(npc.id);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Divider(color: Color(0xff3d332a), height: 8, thickness: 1),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              npc.imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).where((widget) => widget is! SizedBox).toList(),
        ],
      ),
    );
  }

  Widget _buildGmIntroNotesPanel(BuildContext context, int sceneIndex) {
    final syncService = Provider.of<VttSyncService>(context, listen: false);
    final room = syncService.currentRoom;
    final List<Widget> extraWidgets = [];
    if (room != null) {
      final List<NpcData> activeStaticNpcs = [];
      final activeGmNpcId = syncService.activeGmNpcId;
      if (activeGmNpcId != null) {
        final selectedNpc = npcList.firstWhere((n) => n.id == activeGmNpcId, orElse: () => npcList.first);
        activeStaticNpcs.add(selectedNpc);
      }
      for (final npc in npcList) {
        if (room.revealedHandouts['show_npc_${npc.id}'] == 1 && npc.id != activeGmNpcId) {
          activeStaticNpcs.add(npc);
        }
      }
      
      for (final npc in activeStaticNpcs) {
        extraWidgets.add(_buildStaticNpcStatblockCard(context, npc, room, syncService));
      }

      if (room.revealedHandouts['show_arpie_handout'] == 1) {
        extraWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff181513),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffdfc48c), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "STATBLOCK - ARPIE DELLA GUGLIA",
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffdfc48c),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/arpie_statblock.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Le arpie annidate in cima alla torre sono le tre sorelle Cardo, Aculeo e Spina, astute creature che usano la loro casa come punto di vedetta per cercare prede. Vivono al sicuro tra i cespugli di rose, lavandosi allegramente nella pozza di acqua piovana e profumandosi con il nettare dei fiori. Sono immuni al loro odore. Hanno le statistiche delle arpie (Manuale Base, pag. 85). Se due di loro vengono uccise, l’ultima si ritira sul punto più alto della torre e potrebbe attaccare ancora.",
                  style: TextStyle(
                    color: Color(0xffe5dcc6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (room.revealedHandouts['show_harga_handout'] == 1) {
        extraWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff181513),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffdfc48c), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "STATBLOCK - HARGA LA TROLL",
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffdfc48c),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/harga_statblock.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Harga non vuole combattere ma, se attaccata, si difende. Offre, invece, un patto ai personaggi. Ci sono grandi tesori in una cripta sotto la torre e dice di poterli condurre là in cambio di un piccolo favore. Uno stormo di arpie stridenti ha fatto il nido sul tetto, e Harga vuole che il gruppo lo scacci o lo uccida. Le arpie hanno rubato la chiave della cripta. Se i personaggi la recuperano, Harga promette di mostrare loro la strada per il tesoro.\n\n"
                  "✦ Sopra la Luna, Sotto la Terra: Durante la conversazione, Harga mormora un ’antico verso “Sopra la luna, sotto la terra, cadono le stelle” che i personaggi potrebbero aver già sentito (incontro casuale #8). Se le chiedono cosa significhi, agita una mano dicendo che è solo un vecchio verso che le è rimasto in testa.\n\n"
                  "✦ Conseguenze: Se i personaggi uccidono o scacciano almeno la metà delle arpie sul tetto (#6) e trovano la chiave nel nido, Harga mantiene la parola e li conduce al portello nel Salone (#2). Se hanno ucciso Ambrosius, Harga diventa un po’ scontrosa ma non sembra troppo preoccupata. Ciò che lei sa ma non dice è che nella Cripta (#8) c’è una trappola: ci sono dei pericolosi non-morti là sotto, e serve ingegno per uscirne. Harga spera che i personaggi muoiano nella cripta, così da tornare più tardi a recuperare tutti i tesori.\n\n"
                  "✦ Combattimento? I personaggi potrebbero semplicemente uccidere Harga. In questo caso diventa molto più difficile trovare la cripta e uscirne vivi.",
                  style: TextStyle(
                    color: Color(0xffe5dcc6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (room.revealedHandouts['show_ambrosius_handout'] == 1) {
        extraWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff181513),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffdfc48c), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "STATBLOCK - AMBROSIUS IL ROSPO",
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffdfc48c),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/ambrosius_statblock.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return SceneEngine.buildGmPanel(
      config: sceneRegistry[widget.subMapId],
      sceneIndex: sceneIndex,
      extraWidgets: extraWidgets,
    );
  }

  void _showEditPinsJsonDialog(
    BuildContext context,
    GameRoom room,
    VttSyncService syncService,
    String subMapId,
  ) {
    final subMapNodes = room.mapNodes.where((n) => n.subMapId == subMapId).toList();
    
    final jsonList = subMapNodes.map((n) => {
      'id': n.id,
      'name': n.name,
      'description': n.description,
      'xPercent': n.xPercent,
      'yPercent': n.yPercent,
      'isGmOnly': n.isGmOnly,
      'isLocked': n.isLocked,
      'targetSubMap': n.targetSubMap,
    }).toList();
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
    final textController = TextEditingController(text: jsonString);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: VttTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: VttTheme.accent, width: 1.5),
          ),
          title: Text(
            "EDITA JSON PIN MAPPA",
            style: GoogleFonts.cinzel(color: VttTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 550,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Modifica direttamente il JSON qui sotto dei bollini numerici. Assicurati che il formato sia corretto prima di salvare.",
                  style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: VttTheme.textLight),
                    decoration: const InputDecoration(
                      fillColor: Colors.black,
                      filled: true,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("ANNULLA", style: TextStyle(color: VttTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  final text = textController.text.trim();
                  final List<dynamic> decoded = jsonDecode(text);
                  
                  final List<MapNode> newNodes = [];
                  for (final item in decoded) {
                    final mapItem = Map<String, dynamic>.from(item);
                    newNodes.add(MapNode(
                      id: mapItem['id'] ?? "node_${DateTime.now().millisecondsSinceEpoch}_${newNodes.length}",
                      name: mapItem['name'] ?? "Bollino",
                      description: mapItem['description'] ?? "",
                      xPercent: (mapItem['xPercent'] as num).toDouble(),
                      yPercent: (mapItem['yPercent'] as num).toDouble(),
                      isGmOnly: mapItem['isGmOnly'] ?? false,
                      isLocked: mapItem['isLocked'] ?? false,
                      targetSubMap: mapItem['targetSubMap'] ?? "",
                      subMapId: subMapId,
                    ));
                  }

                  final otherNodes = room.mapNodes.where((n) => n.subMapId != subMapId).toList();
                  final combinedList = [...otherNodes, ...newNodes];

                  syncService.updateMapNodes(combinedList);
                  Navigator.of(ctx).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bollini della mappa aggiornati con successo!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  showDialog(
                    context: ctx,
                    builder: (errCtx) => AlertDialog(
                      backgroundColor: VttTheme.surface,
                      title: const Text("ERRORE DI SINTASSI JSON", style: TextStyle(color: Colors.red)),
                      content: Text("Impossibile salvare il JSON: $e", style: const TextStyle(color: VttTheme.textLight)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(errCtx).pop(),
                          child: const Text("OK", style: TextStyle(color: VttTheme.accent)),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VttTheme.primary,
              ),
              child: const Text("SALVA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class TacticalGridPainter extends CustomPainter {
  final bool isTomb;
  final bool overlayMode;

  TacticalGridPainter({required this.isTomb, this.overlayMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = overlayMode
          ? const Color(0xff4a3621).withOpacity(0.12)
          : (isTomb ? const Color(0xff3a1f1f) : const Color(0xff2d2d2d))
      ..strokeWidth = overlayMode ? 0.35 : 0.5;

    double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedSunlightOverlay extends StatefulWidget {
  const AnimatedSunlightOverlay({Key? key}) : super(key: key);

  @override
  State<AnimatedSunlightOverlay> createState() => _AnimatedSunlightOverlayState();
}

class _AnimatedSunlightOverlayState extends State<AnimatedSunlightOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SunlightPainter(_controller.value),
        );
      },
    );
  }
}

class SunlightPainter extends CustomPainter {
  final double animationValue;

  SunlightPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final paintRay = Paint()..style = PaintingStyle.fill;

    void drawRay(double startX, double beamWidth, double angleOffset, double opacity) {
      final path = Path();
      path.moveTo(startX, 0);
      path.lineTo(startX + beamWidth, 0);
      path.lineTo(startX + beamWidth * 2.5 + angleOffset, height);
      path.lineTo(startX + angleOffset, height);
      path.close();

      paintRay.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xfffff4d6).withOpacity(opacity),
          const Color(0xffdfc48c).withOpacity(opacity * 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

      canvas.drawPath(path, paintRay);
    }

    // Gentle pulsing opacity based on sine wave
    double pulse = 0.75 + 0.25 * Math_sin(animationValue * 6.283185307179586);

    // Draw three warm golden sunlight beams drifting slightly with angleOffset
    double drift = Math_sin(animationValue * 6.283185307179586) * (width * 0.03);
    drawRay(width * 0.18 + drift, width * 0.14, width * 0.35, 0.08 * pulse);
    drawRay(width * 0.40 + drift, width * 0.09, width * 0.25, 0.06 * pulse);
    drawRay(width * 0.55 + drift, width * 0.16, width * 0.45, 0.05 * pulse);
  }

  double Math_sin(double x) {
    x = x % 6.283185307179586;
    if (x < 0) x += 6.283185307179586;
    if (x > 3.141592653589793) {
      return -Math_sin(x - 3.141592653589793);
    }
    double temp = x * (3.141592653589793 - x);
    return (16.0 * temp) / (5.0 * 9.869604401089358 - 4.0 * temp);
  }

  @override
  bool shouldRepaint(covariant SunlightPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class AnimatedSmokeOverlay extends StatefulWidget {
  const AnimatedSmokeOverlay({Key? key}) : super(key: key);

  @override
  State<AnimatedSmokeOverlay> createState() => _AnimatedSmokeOverlayState();
}

class _AnimatedSmokeOverlayState extends State<AnimatedSmokeOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SmokeParticle> _particles = [];
  final double _emitterX1 = 0.43; // Relative to screen width
  final double _emitterY1 = 0.42; // Relative to screen height
  final double _emitterX2 = 0.48; // Relative to screen width
  final double _emitterY2 = 0.43; // Relative to screen height
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    if (!mounted) return;
    
    // 1. Move and update existing particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.age += 0.016; // roughly 60fps tick
      if (p.age >= p.lifeTime) {
        _particles.removeAt(i);
      } else {
        // drift upwards (decrease y) and slightly rightward (wind)
        p.y -= p.speedY;
        p.x += p.speedX;
        // grow in size
        p.radius += p.growthRate;
      }
    }

    // 2. Periodically spawn new particles
    if (_particles.length < 35 && _random.nextDouble() < 0.18) {
      final isFirstChimney = _random.nextBool();
      final double startX = isFirstChimney ? _emitterX1 : _emitterX2;
      final double startY = isFirstChimney ? _emitterY1 : _emitterY2;

      _particles.add(_SmokeParticle(
        relativeX: startX + (_random.nextDouble() - 0.5) * 0.02,
        relativeY: startY + (_random.nextDouble() - 0.5) * 0.02,
        speedX: 0.05 + _random.nextDouble() * 0.12, // drifting rightward
        speedY: 0.25 + _random.nextDouble() * 0.35, // moving upward
        radius: 4.0 + _random.nextDouble() * 4.0,
        growthRate: 0.08 + _random.nextDouble() * 0.12,
        lifeTime: 2.5 + _random.nextDouble() * 1.5,
        opacityMultiplier: 0.18 + _random.nextDouble() * 0.12,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: SmokePainter(_particles),
            ),
            CustomPaint(
              painter: SwayingWheatPainter(_controller.value),
            ),
          ],
        );
      },
    );
  }
}

class _SmokeParticle {
  double relativeX;
  double relativeY;
  // Actual coordinates in pixels (calculated during draw based on parent size)
  double x = 0;
  double y = 0;
  
  final double speedX;
  final double speedY;
  double radius;
  final double growthRate;
  final double lifeTime;
  double age = 0.0;
  final double opacityMultiplier;

  _SmokeParticle({
    required this.relativeX,
    required this.relativeY,
    required this.speedX,
    required this.speedY,
    required this.radius,
    required this.growthRate,
    required this.lifeTime,
    required this.opacityMultiplier,
  });
}

class SmokePainter extends CustomPainter {
  final List<_SmokeParticle> particles;

  SmokePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paintSmoke = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Calculate screen pixel coordinates from relative coordinates if not initialized
      if (p.x == 0 && p.y == 0) {
        p.x = p.relativeX * size.width;
        p.y = p.relativeY * size.height;
      }

      // Life progress (0 to 1)
      final progress = p.age / p.lifeTime;
      // Fade out towards the end
      final opacity = (1.0 - progress) * p.opacityMultiplier;

      if (opacity <= 0) continue;

      paintSmoke.color = const Color(0xff5c554e).withOpacity(opacity);

      canvas.drawCircle(Offset(p.x, p.y), p.radius, paintSmoke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SwayingWheatPainter extends CustomPainter {
  final double animationValue;

  SwayingWheatPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // We draw wheat stalks only at the bottom left and right parts of the screen
    final paintStalk = Paint()
      ..color = const Color(0xffdfc48c).withOpacity(0.18) // delicate warm gold outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintSeed = Paint()
      ..color = const Color(0xffdfc48c).withOpacity(0.24) // warm gold seeds
      ..style = PaintingStyle.fill;

    // Wind offset using a smooth sine wave
    final double wind = sin(animationValue * 2 * 3.141592653589793) * 6.0;

    // Left wheat field (X coordinates from 0 to 22% of screen width)
    int leftCount = 18;
    for (int i = 0; i < leftCount; i++) {
      final double progress = i / leftCount;
      final double startX = width * 0.24 * progress;
      final double stalkHeight = 70.0 + sin(i * 1.7) * 25.0;
      final double startY = height;
      final double endX = startX + wind + (i % 3) * 3.0;
      final double endY = height - stalkHeight;

      // Draw bending stalk path
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + wind * 0.4,
        startY - stalkHeight * 0.5,
        endX,
        endY,
      );
      canvas.drawPath(path, paintStalk);

      // Draw small grain kernels at the tip of the stalk
      canvas.drawCircle(Offset(endX, endY), 2.5, paintSeed);
      canvas.drawCircle(Offset(endX - 3.5, endY + 5), 2.0, paintSeed);
      canvas.drawCircle(Offset(endX + 3.5, endY + 7), 2.0, paintSeed);
      canvas.drawCircle(Offset(endX - 2.5, endY + 11), 1.8, paintSeed);
      canvas.drawCircle(Offset(endX + 2.5, endY + 13), 1.8, paintSeed);
    }

    // Right wheat field (X coordinates from 78% to 100% of screen width)
    int rightCount = 18;
    for (int i = 0; i < rightCount; i++) {
      final double progress = i / rightCount;
      final double startX = width - (width * 0.24 * progress);
      final double stalkHeight = 70.0 + sin(i * 2.1) * 25.0;
      final double startY = height;
      final double endX = startX + wind - (i % 3) * 3.0;
      final double endY = height - stalkHeight;

      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + wind * 0.4,
        startY - stalkHeight * 0.5,
        endX,
        endY,
      );
      canvas.drawPath(path, paintStalk);

      canvas.drawCircle(Offset(endX, endY), 2.5, paintSeed);
      canvas.drawCircle(Offset(endX - 3.5, endY + 5), 2.0, paintSeed);
      canvas.drawCircle(Offset(endX + 3.5, endY + 7), 2.0, paintSeed);
      canvas.drawCircle(Offset(endX - 2.5, endY + 11), 1.8, paintSeed);
      canvas.drawCircle(Offset(endX + 2.5, endY + 13), 1.8, paintSeed);
    }
  }

  @override
  bool shouldRepaint(covariant SwayingWheatPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
