import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/sync/sync_interface.dart';
import '../core/theme.dart';
import '../models/map_node.dart';
import '../models/npc_data.dart';
import '../models/game_room.dart';

class OverworldMapView extends StatefulWidget {
  const OverworldMapView({super.key});

  @override
  State<OverworldMapView> createState() => _OverworldMapViewState();
}

class _OverworldMapViewState extends State<OverworldMapView> {
  final GlobalKey _mapKey = GlobalKey();
  List<MapNode> _nodes = [];
  String _mapName = "Caricamento Mappa...";
  bool _loading = true;
  final Set<String> _locallyClosedHandouts = {};
  final Map<String, Offset> _npcHandoutOffsets = {};
  double? _inspectX;
  double? _inspectY;

  @override
  void initState() {
    super.initState();
    _loadMapConfiguration();
  }

  Future<void> _loadMapConfiguration() async {
    try {
      final jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/data/overworld_map.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final list = (data['nodes'] as List)
          .map((n) => MapNode.fromJson(Map<String, dynamic>.from(n)))
          .toList();

      setState(() {
        _nodes = list;
        _mapName = data['mapName'] ?? "Mappa del Mondo";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _mapName = "Errore Caricamento Mappa";
        _loading = false;
      });
    }
  }

  void _showNodeDetailDialog(BuildContext context, MapNode node, VttSyncService syncService) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                node.isGmOnly ? Icons.visibility_off : Icons.location_on,
                color: VttTheme.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  node.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.description,
                style: const TextStyle(color: VttTheme.textLight, height: 1.4),
              ),
              if (node.isGmOnly) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VttTheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: VttTheme.primaryLight),
                  ),
                  child: const Text(
                    "NODO SEGRETO - VISIBILE SOLO AL GM",
                    style: TextStyle(fontSize: 10, color: VttTheme.textLight, fontWeight: FontWeight.bold),
                  ),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("CHIUDI", style: TextStyle(color: VttTheme.textMuted)),
            ),
            if (syncService.isGm) ...[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showEditNodeDialog(context, node, syncService);
                },
                child: const Text("MODIFICA PIN", style: TextStyle(color: VttTheme.accent)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  syncService.changeActiveMap(node.targetSubMap);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Mappa attiva impostata su: ${node.name}"),
                      backgroundColor: VttTheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VttTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("IMPOSTA COME ATTIVA"),
              ),
            ] else if (syncService.currentRoom?.activeMapId == node.targetSubMap)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  syncService.changeActiveMap(node.targetSubMap);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VttTheme.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text("ENTRA NELLA LOCALITÀ"),
              )
          ],
        );
      },
    );
  }

  void _showCreateNodeDialog(BuildContext context, double xPercent, double yPercent, VttSyncService syncService) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final mapIdController = TextEditingController(text: "submap_${DateTime.now().millisecondsSinceEpoch}");
    bool isGmOnly = false;
    bool isLocked = false;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: VttTheme.surface,
              title: const Text("CREA NUOVO PIN", style: TextStyle(color: VttTheme.textLight)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "Nome Località",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "Descrizione",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mapIdController,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "ID Mappa di Gioco",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text("Segreto (Invisibile ai giocatori)", style: TextStyle(color: VttTheme.textLight, fontSize: 13)),
                      value: isGmOnly,
                      onChanged: (val) {
                        setStateDialog(() {
                          isGmOnly = val ?? false;
                          if (isGmOnly) {
                            isLocked = false;
                          }
                        });
                      },
                      activeColor: VttTheme.accent,
                      checkColor: Colors.black,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text("Bloccato (Visibile ma non cliccabile)", style: TextStyle(color: VttTheme.textLight, fontSize: 13)),
                      value: isLocked,
                      onChanged: (val) {
                        setStateDialog(() {
                          isLocked = val ?? false;
                          if (isLocked) {
                            isGmOnly = false;
                          }
                        });
                      },
                      activeColor: VttTheme.accent,
                      checkColor: Colors.black,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final desc = descController.text.trim();
                          final mapId = mapIdController.text.trim();
                          if (name.isEmpty || mapId.isEmpty) return;

                          final newNode = MapNode(
                            id: "node_${DateTime.now().millisecondsSinceEpoch}",
                            name: name,
                            description: desc,
                            xPercent: double.parse(xPercent.toStringAsFixed(1)),
                            yPercent: double.parse(yPercent.toStringAsFixed(1)),
                            isGmOnly: isGmOnly,
                            isLocked: isLocked,
                            targetSubMap: mapId,
                          );

                          final currentNodes = syncService.currentRoom?.mapNodes ?? _nodes;
                          final updatedList = List<MapNode>.from(currentNodes)..add(newNode);

                          if (syncService.currentRoom != null) {
                            syncService.updateMapNodes(updatedList);
                          } else {
                            setState(() {
                              _nodes = updatedList;
                            });
                          }

                          setState(() {
                            _inspectX = null;
                            _inspectY = null;
                          });

                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VttTheme.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("CREA PIN", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff444444)),
                          foregroundColor: VttTheme.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ANNULLA"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNodeDialog(BuildContext context, MapNode node, VttSyncService syncService) {
    final nameController = TextEditingController(text: node.name);
    final descController = TextEditingController(text: node.description);
    final mapIdController = TextEditingController(text: node.targetSubMap);
    bool isGmOnly = node.isGmOnly;
    bool isLocked = node.isLocked;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: VttTheme.surface,
              title: Text("MODIFICA PIN: ${node.name.toUpperCase()}", style: const TextStyle(color: VttTheme.textLight, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "Nome Località",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "Descrizione",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mapIdController,
                      style: const TextStyle(color: VttTheme.textLight),
                      decoration: const InputDecoration(
                        labelText: "ID Mappa di Gioco",
                        labelStyle: TextStyle(color: VttTheme.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff444444))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VttTheme.accent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text("Segreto (Invisibile ai giocatori)", style: TextStyle(color: VttTheme.textLight, fontSize: 13)),
                      value: isGmOnly,
                      onChanged: (val) {
                        setStateDialog(() {
                          isGmOnly = val ?? false;
                          if (isGmOnly) {
                            isLocked = false;
                          }
                        });
                      },
                      activeColor: VttTheme.accent,
                      checkColor: Colors.black,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text("Bloccato (Visibile ma non cliccabile)", style: TextStyle(color: VttTheme.textLight, fontSize: 13)),
                      value: isLocked,
                      onChanged: (val) {
                        setStateDialog(() {
                          isLocked = val ?? false;
                          if (isLocked) {
                            isGmOnly = false;
                          }
                        });
                      },
                      activeColor: VttTheme.accent,
                      checkColor: Colors.black,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final desc = descController.text.trim();
                          final mapId = mapIdController.text.trim();
                          if (name.isEmpty || mapId.isEmpty) return;

                          final updatedNode = MapNode(
                            id: node.id,
                            name: name,
                            description: desc,
                            xPercent: node.xPercent,
                            yPercent: node.yPercent,
                            isGmOnly: isGmOnly,
                            isLocked: isLocked,
                            targetSubMap: mapId,
                            subMapId: node.subMapId,
                          );

                          final currentNodes = syncService.currentRoom?.mapNodes ?? _nodes;
                          final index = currentNodes.indexWhere((n) => n.id == node.id);
                          if (index != -1) {
                            final updatedList = List<MapNode>.from(currentNodes);
                            updatedList[index] = updatedNode;

                            if (syncService.currentRoom != null) {
                              syncService.updateMapNodes(updatedList);
                            } else {
                              setState(() {
                                _nodes = updatedList;
                              });
                            }
                          }

                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VttTheme.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("SALVA MODIFICHE", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff444444)),
                          foregroundColor: VttTheme.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ANNULLA"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final currentNodes = syncService.currentRoom?.mapNodes ?? _nodes;
                          final updatedList = List<MapNode>.from(currentNodes)..removeWhere((n) => n.id == node.id);

                          if (syncService.currentRoom != null) {
                            syncService.updateMapNodes(updatedList);
                          } else {
                            setState(() {
                              _nodes = updatedList;
                            });
                          }
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ELIMINA PIN", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);
    final activeMapId = syncService.currentRoom?.activeMapId ?? 'overworld';
    final room = syncService.currentRoom;
    if (room != null) {
      for (final npc in npcList) {
        if (room.revealedHandouts['show_npc_${npc.id}'] != 1) {
          _locallyClosedHandouts.remove(npc.id);
        }
      }
    }
    final nodes = (syncService.currentRoom?.mapNodes.isNotEmpty == true 
        ? syncService.currentRoom!.mapNodes 
        : _nodes).where((n) => n.subMapId == 'overworld').toList();

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: VttTheme.accent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: VttTheme.surface,
        title: Text(
          _mapName.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        actions: [
          if (syncService.isGm) ...[
            IconButton(
              icon: const Icon(Icons.download, color: VttTheme.accent),
              tooltip: "Esporta Configurazione JSON",
              onPressed: () {
                final currentNodes = syncService.currentRoom?.mapNodes.isNotEmpty == true 
                    ? syncService.currentRoom!.mapNodes 
                    : _nodes;
                
                final mapConfig = {
                  "mapName": _mapName,
                  "imageAsset": "assets/maps/mappa_valle.png",
                  "width": 2000,
                  "height": 1556,
                  "nodes": currentNodes.map((n) => n.toJson()).toList(),
                };
                
                final jsonString = const JsonEncoder.withIndent('  ').convert(mapConfig);
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: VttTheme.surface,
                    title: const Text("ESPORTA CONFIGURAZIONE MAPPA", style: TextStyle(color: VttTheme.textLight, fontSize: 16)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Copia il testo qui sotto e incollalo nella chat dell'assistente AI per salvare le posizioni dei pin in modo permanente nel file overworld_map.json!",
                          style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const BorderSide(color: Color(0xff444444)).color),
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
                        style: TextButton.styleFrom(foregroundColor: VttTheme.textMuted),
                        child: const Text("CHIUDI"),
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
                          backgroundColor: VttTheme.accent,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("COPIA NEGLI APPUNTI"),
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: VttTheme.accent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "MODALITÀ GM",
                style: TextStyle(color: VttTheme.accent, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
            children: [
              // 1. Zoomable & Pannable Map Layer (Unconstrained to keep exact aspect ratio)
              InteractiveViewer(
                maxScale: 4.0,
                minScale: 0.1,
                constrained: false, // Prevents stretching based on screen constraints!
                boundaryMargin: const EdgeInsets.all(1500),
                child: Center(
                  child: DragTarget<MapNode>(
                    onAcceptWithDetails: (details) {
                      // Calculate drop coordinate relative to the 2000x1556 Container
                      final RenderBox renderBox = _mapKey.currentContext!.findRenderObject() as RenderBox;
                      final localPos = renderBox.globalToLocal(details.offset);

                      // Calculate percentage coordinates
                      double newX = (localPos.dx / 2000) * 100;
                      double newY = (localPos.dy / 1556) * 100;

                      // Clamp values
                      newX = newX.clamp(0.0, 100.0);
                      newY = newY.clamp(0.0, 100.0);

                      final currentNodes = syncService.currentRoom?.mapNodes.isNotEmpty == true 
                          ? syncService.currentRoom!.mapNodes 
                          : _nodes;
                      final index = currentNodes.indexWhere((n) => n.id == details.data.id);
                      if (index != -1) {
                        final updatedList = List<MapNode>.from(currentNodes);
                        updatedList[index] = MapNode(
                          id: details.data.id,
                          name: details.data.name,
                          description: details.data.description,
                          xPercent: double.parse(newX.toStringAsFixed(1)),
                          yPercent: double.parse(newY.toStringAsFixed(1)),
                          isGmOnly: details.data.isGmOnly,
                          targetSubMap: details.data.targetSubMap,
                          subMapId: details.data.subMapId,
                        );

                        if (syncService.currentRoom != null) {
                          syncService.updateMapNodes(updatedList);
                        } else {
                          setState(() {
                            _nodes = updatedList;
                          });
                        }
                        
                        setState(() {
                          _inspectX = newX;
                          _inspectY = newY;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        key: _mapKey,
                        width: 2000,
                        height: 1556,
                        decoration: const BoxDecoration(
                          color: Color(0xff0d0d0d),
                        ),
                        child: Stack(
                          children: [
                            // Map Image + Tap Listener for GM Coordinates Alignment
                            GestureDetector(
                              onTapUp: (details) {
                                if (syncService.isGm) {
                                  setState(() {
                                    _inspectX = (details.localPosition.dx / 2000) * 100;
                                    _inspectY = (details.localPosition.dy / 1556) * 100;
                                  });
                                }
                              },
                              child: Image.asset(
                                'assets/maps/mappa_valle.png',
                                width: 2000,
                                height: 1556,
                                fit: BoxFit.fill,
                              ),
                            ),

                            // Clickable locations overlay (zooms & pans dynamically with map image)
                            ...nodes.map((node) {
                              // GM-only secret nodes are completely hidden from players
                              if (node.isGmOnly && !syncService.isGm) {
                                return const SizedBox.shrink();
                              }

                              final isActiveNode = activeMapId == node.targetSubMap;
                              final isLocked = node.isLocked;
                              final isClickBlocked = isLocked && !syncService.isGm;

                              Widget nodeWidget = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? const Color(0xff2a2a2a).withOpacity(0.9) // Charcoal gray for locked
                                          : (isActiveNode 
                                              ? VttTheme.primary.withOpacity(0.9) 
                                              : VttTheme.surface.withOpacity(0.9)),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isLocked
                                            ? const Color(0xff4f4f4f) // Medium gray border
                                            : (isActiveNode ? VttTheme.accent : (node.isGmOnly ? Colors.purple : VttTheme.accent)),
                                        width: isActiveNode ? 2.5 : 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isLocked
                                          ? Icons.location_off // Slashed geotag
                                          : (isActiveNode 
                                              ? Icons.location_history 
                                              : (node.isGmOnly ? Icons.visibility_off : Icons.location_on)),
                                      size: 16,
                                      color: isLocked
                                          ? const Color(0xffd32f2f) // Bright warning red
                                          : (isActiveNode ? Colors.white : (node.isGmOnly ? Colors.purple[200] : VttTheme.accent)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(isLocked ? 0.6 : 0.75),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isLocked
                                            ? const Color(0xff333333)
                                            : const Color(0xff444444),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      node.name,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isLocked 
                                            ? const Color(0xffcccccc) 
                                            : (isActiveNode ? VttTheme.accent : VttTheme.textLight),
                                        fontWeight: isActiveNode ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              // If GM Mode is active, wrap node in Draggable
                              if (syncService.isGm) {
                                nodeWidget = Draggable<MapNode>(
                                  data: node,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Opacity(
                                      opacity: 0.8,
                                      child: nodeWidget,
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: nodeWidget,
                                  ),
                                  child: nodeWidget,
                                );
                              }

                              return Positioned(
                                left: (node.xPercent / 100) * 2000 - 20,
                                top: (node.yPercent / 100) * 1556 - 20,
                                child: MouseRegion(
                                  cursor: isClickBlocked ? SystemMouseCursors.basic : SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: isClickBlocked 
                                        ? null 
                                        : () => _showNodeDetailDialog(context, node, syncService),
                                    child: nodeWidget,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. Active Sync Status Indicator (Fixed Screen Overlay)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: VttTheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const BorderSide(color: Color(0xff333333)).color),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Mappa Attiva Sessione: ${activeMapId == 'overworld' ? 'Overworld' : activeMapId.toUpperCase()}",
                        style: const TextStyle(fontSize: 10, color: VttTheme.textLight),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. GM Coordinate Inspector Helper (Fixed Screen Overlay)
              if (syncService.isGm && _inspectX != null && _inspectY != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: VttTheme.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: VttTheme.accent, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "ISPETTORE COORDINATE GM",
                              style: TextStyle(fontSize: 9, color: VttTheme.accent, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _inspectX = null;
                                  _inspectY = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 10, color: VttTheme.textMuted),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\"xPercent\": ${_inspectX!.toStringAsFixed(1)},\n\"yPercent\": ${_inspectY!.toStringAsFixed(1)}",
                          style: const TextStyle(fontSize: 11, color: VttTheme.textLight, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateNodeDialog(context, _inspectX!, _inspectY!, syncService),
                          icon: const Icon(Icons.add_location_alt, size: 12),
                          label: const Text("AGGIUNGI PIN QUI", style: TextStyle(fontSize: 9)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VttTheme.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Trascina i pin per spostarli.",
                          style: TextStyle(fontSize: 8, color: VttTheme.textMuted, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ...npcList.map((npc) {
                final isRevealed = syncService.currentRoom?.revealedHandouts['show_npc_${npc.id}'] == 1;
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
          );
        },
      ),
    ),
    if (syncService.isGm && syncService.activeGmNpcId != null)
      _buildGmStatblocksPanel(context, room!, syncService),
  ],
),
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
            child: activeStaticNpcs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Nessun PNG attivo selezionato dal GM.",
                        style: TextStyle(color: VttTheme.textMuted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...activeStaticNpcs.map((npc) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildStaticNpcStatblockCard(context, npc, room, syncService),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
