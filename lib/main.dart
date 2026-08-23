import 'dart:math';
import 'models/character.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/sync/mock_sync.dart';
import 'core/sync/sync_interface.dart';
import 'core/theme.dart';
import 'views/character_sheet_view.dart';
import 'views/gm_dashboard_view.dart';
import 'views/login_room_view.dart';
import 'views/overworld_map_view.dart';
import 'views/sub_map_view.dart';
import 'models/npc_data.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    ChangeNotifierProvider<VttSyncService>(
      create: (_) => MockSyncProvider(),
      child: const DragonbaneVttApp(),
    ),
  );
}

class DragonbaneVttApp extends StatelessWidget {
  const DragonbaneVttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dragonbane VTT',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: VttTheme.primary,
        scaffoldBackgroundColor: VttTheme.background,
        colorScheme: const ColorScheme.dark(
          primary: VttTheme.primary,
          secondary: VttTheme.accent,
          surface: VttTheme.surface,
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final room = syncService.currentRoom;

    // Phase 1: Login / Join room if not inside a session
    if (room == null) {
      return const LoginRoomView();
    }

    final activeMapId = room.activeMapId;
    final isGm = syncService.isGm;
    final playerCharId = room.playerSelections[syncService.currentUserId];

    // Determine current layout based on navigation tabs
    Widget mainScreen;
    
    // TAB 0: Active Map (Synced automatically across all devices)
    if (_currentTabIndex == 0) {
      if (activeMapId == 'overworld') {
        mainScreen = const OverworldMapView();
      } else {
        mainScreen = SubMapView(subMapId: activeMapId);
      }
    } 
    // TAB 1: NPC Manager / Inspect Sheets
    else if (_currentTabIndex == 1) {
      if (isGm) {
        mainScreen = const CharacterSheetView(characterId: 'pc_krag');
      } else {
        if (playerCharId != null && playerCharId.isNotEmpty) {
          mainScreen = CharacterSheetView(characterId: playerCharId);
        } else {
          mainScreen = const PlayerCharacterSelector();
        }
      }
    } 
    // TAB 2: Dice & Roll Log Registry (Consolidated feed)
    else if (_currentTabIndex == 2) {
      mainScreen = const DiceLogHistoryView();
    } 
    // TAB 3: GM Admin controls panel
    else {
      mainScreen = const GmDashboardView();
    }

    // Build responsive mobile navigation
    return Scaffold(
      body: mainScreen,
      bottomNavigationBar: isGm
          ? BottomNavigationBar(
              currentIndex: _currentTabIndex >= 4 ? 0 : _currentTabIndex,
              onTap: (index) {
                if (index == 1) {
                  _showNpcSelectorBottomSheet(context, syncService);
                  return;
                }
                if (index == 2) {
                  _showEventSelectorBottomSheet(context, syncService);
                  return;
                }
                if (index == 0 && room.activeMapId != 'overworld') {
                  syncService.changeActiveMap('overworld');
                }
                setState(() {
                  _currentTabIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: VttTheme.surface,
              selectedItemColor: VttTheme.accent,
              unselectedItemColor: VttTheme.textMuted,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mappa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Mostra NPC',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: 'Eventi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings),
                  label: 'Pannello GM',
                ),
              ],
            )
          : null,
      floatingActionButton: isGm
          ? FloatingActionButton.small(
              onPressed: () {
                // Show quick roll dice popup from anywhere in VTT
                showDiceQuickRollDialog(context, syncService);
              },
              backgroundColor: VttTheme.primary,
              child: const Icon(Icons.casino, color: Colors.white),
            )
          : null,
    );
  }

  void showDiceQuickRollDialog(BuildContext context, VttSyncService syncService) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("TIRO RAPIDO D20"),
          content: const Text("Lancia un d20 generico senza parametri di scheda."),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // General d20 roll
                final random = javaRandom();
                final res = random.nextInt(20) + 1;
                final outcome = res == 1 ? "Drago" : (res == 20 ? "Demone" : (res <= 10 ? "Successo (Soglia 10)" : "Fallimento"));
                
                final room = syncService.currentRoom;
                if (room != null) {
                  // We simulate a raw submission
                  syncService.submitRoll(
                    syncService.isGm ? "Game Master" : "Giocatore",
                    "D20 Generico",
                    10,
                    rollMode: "Normale",
                    rollerCharacter: Character(id: 'temp', name: 'Generico', hp: 10, maxHp: 10, wp: 10, maxWp: 10, skills: {}),
                  );
                }
              },
              child: const Text("LANCIA"),
            ),
          ],
        );
      },
    );
  }

  void _showNpcSelectorBottomSheet(BuildContext context, VttSyncService syncService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff181411),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: VttTheme.accent, width: 1.5),
      ),
      builder: (context) {
        String activeCategory = 'orlo';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredNpcs = npcList.where((n) => n.category == activeCategory).toList();

            return Container(
              padding: const EdgeInsets.all(16),
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "MOSTRA NPC AI GIOCATORI",
                        style: GoogleFonts.cinzel(
                          color: VttTheme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: VttTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              activeCategory = 'orlo';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeCategory == 'orlo' ? VttTheme.primary : const Color(0xff2d221a),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            "ORLO",
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              activeCategory = 'viaggi';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeCategory == 'viaggi' ? VttTheme.primary : const Color(0xff2d221a),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            "VIAGGI",
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              activeCategory = 'pg';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeCategory == 'pg' ? VttTheme.primary : const Color(0xff2d221a),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            "PG GIOCANTI",
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xff4a3b32), height: 1),
                  const SizedBox(height: 12),

                  // NPC Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filteredNpcs.length,
                      itemBuilder: (context, index) {
                        final npc = filteredNpcs[index];
                        final isRevealed = syncService.currentRoom?.revealedHandouts['show_npc_${npc.id}'] == 1;

                        return InkWell(
                          onTap: () {
                            syncService.setActiveGmNpcId(npc.id);
                            syncService.revealHandout('show_npc_${npc.id}');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Handout di ${npc.name} mostrato a tutti! Statblock attivo."),
                                backgroundColor: Colors.green[800],
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff2d221a),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isRevealed ? Colors.green : const Color(0xff4a3b32),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(npc.imageAsset),
                                  radius: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  npc.name.toUpperCase(),
                                  style: GoogleFonts.cinzel(
                                    color: isRevealed ? Colors.green[200] : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEventSelectorBottomSheet(BuildContext context, VttSyncService syncService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1a1512),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: VttTheme.accent, width: 1.5),
      ),
      builder: (context) {
        String activeMainCategory = 'cittadini'; // 'cittadini' | 'viaggio'
        String activeTravelSubCategory = 'attorno_orlo'; // 'falo' | 'attorno_orlo'

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SELEZIONA EVENTO ATTIVO",
                        style: GoogleFonts.cinzel(
                          color: VttTheme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: VttTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Categorie Principali: Eventi Cittadini | Viaggio
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              activeMainCategory = 'cittadini';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeMainCategory == 'cittadini' ? VttTheme.primary : const Color(0xff2d221a),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            "EVENTI CITTADINI",
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              activeMainCategory = 'viaggio';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeMainCategory == 'viaggio' ? VttTheme.primary : const Color(0xff2d221a),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            "VIAGGIO",
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activeMainCategory == 'viaggio') ...[
                    const SizedBox(height: 10),
                    // Sotto-categorie Viaggio: Falò | Attorno a Orlo
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                activeTravelSubCategory = 'falo';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: activeTravelSubCategory == 'falo' ? VttTheme.accent.withOpacity(0.2) : Colors.transparent,
                              side: BorderSide(color: activeTravelSubCategory == 'falo' ? VttTheme.accent : const Color(0xff4a3b32)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              "FALÒ",
                              style: GoogleFonts.cinzel(
                                color: activeTravelSubCategory == 'falo' ? VttTheme.accent : VttTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                activeTravelSubCategory = 'attorno_orlo';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: activeTravelSubCategory == 'attorno_orlo' ? VttTheme.accent.withOpacity(0.2) : Colors.transparent,
                              side: BorderSide(color: activeTravelSubCategory == 'attorno_orlo' ? VttTheme.accent : const Color(0xff4a3b32)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              "ATTORNO A ORLO",
                              style: GoogleFonts.cinzel(
                                color: activeTravelSubCategory == 'attorno_orlo' ? VttTheme.accent : VttTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xff4a3b32), height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: activeMainCategory == 'cittadini'
                        ? GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            children: [
                              InkWell(
                                onTap: () {
                                  syncService.changeActiveMap('orlo_troll');
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Spostamento alla scena 'Troll nel Fienile' avvenuto per tutti!"),
                                      backgroundColor: Colors.green[800],
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff2d221a),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: syncService.currentRoom?.activeMapId == 'orlo_troll' ? Colors.green : const Color(0xff4a3b32),
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/orlo_troll.jpg'),
                                        radius: 26,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Troll nel Fienile".toUpperCase(),
                                        style: GoogleFonts.cinzel(
                                          color: syncService.currentRoom?.activeMapId == 'orlo_troll' ? Colors.green[200] : Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : (activeTravelSubCategory == 'attorno_orlo'
                            ? GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.85,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      syncService.changeActiveMap('orlo_torre');
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Spostamento alla scena 'Torre di Zirazzia' avvenuto per tutti!"),
                                          backgroundColor: Colors.green[800],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff2d221a),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: syncService.currentRoom?.activeMapId == 'orlo_torre' ? Colors.green : const Color(0xff4a3b32),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage: AssetImage('assets/images/orlo_torre.jpg'),
                                            radius: 26,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Torre di Zirazzia".toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: syncService.currentRoom?.activeMapId == 'orlo_torre' ? Colors.green[200] : Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      syncService.changeActiveMap('cultisti_impiccati');
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Spostamento alla scena 'Cultisti Impiccati' avvenuto per tutti!"),
                                          backgroundColor: Colors.green[800],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff2d221a),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: syncService.currentRoom?.activeMapId == 'cultisti_impiccati' ? Colors.green : const Color(0xff4a3b32),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage: AssetImage('assets/images/cultisti_impiccati.jpg'),
                                            radius: 26,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Cultisti Impiccati".toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: syncService.currentRoom?.activeMapId == 'cultisti_impiccati' ? Colors.green[200] : Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      syncService.changeActiveMap('cavaliere_drago');
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Spostamento alla scena 'Cavaliere del Drago' avvenuto per tutti!"),
                                          backgroundColor: Colors.green[800],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff2d221a),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: syncService.currentRoom?.activeMapId == 'cavaliere_drago' ? Colors.green : const Color(0xff4a3b32),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage: AssetImage('assets/images/cavaliere_drago.jpg'),
                                            radius: 26,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Cavaliere del Drago".toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: syncService.currentRoom?.activeMapId == 'cavaliere_drago' ? Colors.green[200] : Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text(
                                  "Nessun evento Falò configurato.",
                                  style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                                ),
                              )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Player selection viewport if no Character is assigned
class PlayerCharacterSelector extends StatelessWidget {
  const PlayerCharacterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final room = syncService.currentRoom!;
    // List characters that are player characters (not NPCs)
    final pcs = room.characters.values.where((c) => !c.isNpc).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("SELEZIONA IL TUO PERSONAGGIO")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Scegli una scheda personaggio per iniziare la sessione nella valle.",
              style: TextStyle(color: VttTheme.textLight),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pcs.length,
                itemBuilder: (context, index) {
                  final pc = pcs[index];
                  return Card(
                    child: ListTile(
                      title: Text(pc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${pc.stirpe} ${pc.professione} | HP: ${pc.maxHp}"),
                      trailing: const Icon(Icons.arrow_forward, color: VttTheme.accent),
                      onTap: () {
                        syncService.selectCharacterForPlayer(syncService.currentUserId!, pc.id);
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Active Dice Roll Logs Feed Panel
class DiceLogHistoryView extends StatelessWidget {
  const DiceLogHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final room = syncService.currentRoom;

    if (room == null) return const Center(child: Text("Nessun log."));

    return Scaffold(
      appBar: AppBar(
        title: const Text("REGISTRO DEI TIRI SULLA VALLE"),
        backgroundColor: VttTheme.surface,
      ),
      body: room.rollLog.isEmpty
          ? const Center(
              child: Text(
                "Nessun tiro effettuato in questa sessione. Lancia dei dadi dalla scheda!",
                style: TextStyle(color: VttTheme.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: room.rollLog.length,
              itemBuilder: (context, index) {
                final roll = room.rollLog[index];
                final isDragon = roll.outcome.contains("Drago");
                final isDemon = roll.outcome.contains("Demone");
                final isSuccess = roll.outcome == "Successo";

                Color outcomeColor = VttTheme.textLight;
                if (isDragon) outcomeColor = VttTheme.accent;
                if (isDemon) outcomeColor = VttTheme.conditionExhausted;
                if (isSuccess && !isDragon) outcomeColor = Colors.greenAccent;

                return Card(
                  color: isDragon 
                      ? const Color(0xff2d2d1e) 
                      : (isDemon ? const Color(0xff2d1e1e) : VttTheme.surface),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              roll.rollerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: VttTheme.accent),
                            ),
                            Text(
                              "${roll.timestamp.hour.toString().padLeft(2, '0')}:${roll.timestamp.minute.toString().padLeft(2, '0')}:${roll.timestamp.second.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 10, color: VttTheme.textMuted),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tiro: ${roll.rollType}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Risultato: ${roll.diceResults.join(' & ')} [Soglia: ${roll.targetValue}]",
                              style: const TextStyle(fontSize: 12, color: VttTheme.textLight),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: outcomeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: outcomeColor, width: 0.5),
                              ),
                              child: Text(
                                roll.outcome.toUpperCase(),
                                style: TextStyle(fontSize: 10, color: outcomeColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (roll.rollMode != "Normale") ...[
                          const SizedBox(height: 4),
                          Text(
                            "Modalità: ${roll.rollMode}",
                            style: const TextStyle(fontSize: 9, color: VttTheme.textMuted, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Dummy Random Provider
class javaRandom {
  final _random = java_random_engine();
  int nextInt(int max) => _random.nextInt(max);
}

class java_random_engine {
  final _r = java_math_rand();
  int nextInt(int max) => _r.nextInt(max);
}

class java_math_rand {
  final _rand = Random();
  int nextInt(int max) => _rand.nextInt(max);
}
