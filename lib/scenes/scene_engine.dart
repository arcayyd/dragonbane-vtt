// scene_engine.dart
// Reads SceneConfig/SceneData objects and builds Flutter widgets automatically.
// This file never needs editing when adding new scenes/locations.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sync/sync_interface.dart';
import '../models/game_room.dart';
import 'scene_models.dart';
import 'vtt_scene_widgets.dart';
import '../models/map_node.dart';

class SceneEngine {
  SceneEngine._(); // static-only class

  // -------------------------------------------------------------------------
  // PUBLIC: Handout layer (shown over the cinematic background, to players)
  // -------------------------------------------------------------------------
  static Widget buildHandoutLayer({
    required SceneData? scene,
    required bool isGm,
    required VttSyncService syncService,
    required GameRoom room,
    required String subMapId,
  }) {
    if (scene == null) return const SizedBox.shrink();

    final handout = scene.handout;
    final toggle = scene.gmToggle;
    final introText = scene.introText;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Intro text overlay (bottom center card, e.g. "Tanto tempo fa...")
        if (introText != null)
          _buildIntroTextCard(introText),

        // Handout image card
        if (handout != null)
          _buildHandoutCard(
            handout: handout,
            isGm: isGm,
            onClose: () => syncService.hideHandout(subMapId),
            toggle: toggle,
            room: room,
            syncService: syncService,
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // PUBLIC: GM side panel
  // -------------------------------------------------------------------------
  static Widget buildGmPanel({
    required SceneConfig? config,
    required int sceneIndex,
    List<Widget>? extraWidgets,
  }) {
    if (config == null) return const SizedBox.shrink();
    final scene = config.sceneAt(sceneIndex);
    if (scene == null) return const SizedBox.shrink();

    final List<Widget> children = [];
    if (scene.gmNotes != null) {
      children.add(_buildGmNotesContent(scene.gmNotes!));
    }
    if (scene.gmStatBlock != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 20));
        children.add(const Divider(color: kBorderDark));
        children.add(const SizedBox(height: 12));
      }
      children.add(_buildStatBlock(scene.gmStatBlock!));
    }
    if (extraWidgets != null && extraWidgets.isNotEmpty) {
      for (final w in extraWidgets) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: 20));
          children.add(const Divider(color: kBorderDark));
          children.add(const SizedBox(height: 12));
        }
        children.add(w);
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return gmSidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE helpers
  // -------------------------------------------------------------------------

  static Widget _buildIntroTextCard(String text) {
    return Positioned(
      left: 40,
      right: 40,
      bottom: 80,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(8),
            border: const Border(top: BorderSide(color: kGold, width: 1.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '— INTRODUZIONE —',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: GoogleFonts.cinzel(
                  color: kTextLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHandoutCard({
    required HandoutData handout,
    required bool isGm,
    required VoidCallback onClose,
    GmToggleData? toggle,
    GameRoom? room,
    VttSyncService? syncService,
  }) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(handout.asset, fit: BoxFit.contain),
    );

    // Build toggle button if provided
    Widget? toggleButton;
    if (toggle != null && isGm && room != null && syncService != null) {
      final isShown = room.revealedHandouts[toggle.handoutKey] == 1;
      toggleButton = Center(
        child: TextButton.icon(
          icon: const Icon(Icons.psychology, color: kGold, size: 16),
          label: Text(
            isShown ? toggle.hideLabel : toggle.showLabel,
            style: GoogleFonts.cinzel(
              color: kGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          onPressed: () {
            if (isShown) {
              syncService.hideHandout(toggle.handoutKey);
            } else {
              syncService.revealHandout(toggle.handoutKey);
            }
          },
        ),
      );
    }

    final cardContent = toggleButton != null
        ? Column(
            children: [
              Expanded(child: imageWidget),
              const SizedBox(height: 12),
              toggleButton,
            ],
          )
        : imageWidget;

    if (handout.layout == HandoutLayout.leftSide) {
      return positionedImageHandout(
        title: handout.title,
        assetPath: handout.asset,
        isGm: isGm,
        onClose: onClose,
        width: handout.width,
      );
    }

    return handoutCard(
      title: handout.title,
      isGm: isGm,
      onClose: onClose,
      width: handout.width,
      height: handout.height,
      content: cardContent,
    );
  }

  static Widget _buildGmNotesContent(GmNotesData notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gmSectionHeader(notes.sectionTitle),
        if (notes.narrative != null) ...[
          const SizedBox(height: 12),
          gmNarrativeText(notes.narrative!),
        ],
        if (notes.readAloud != null) ...[
          const SizedBox(height: 16),
          readAloudBox(notes.readAloud!),
        ],
        if (notes.bodyText != null) ...[
          const SizedBox(height: 16),
          gmBodyText(notes.bodyText!),
        ],
      ],
    );
  }

  static Widget _buildStatBlock(StatBlockData sb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gmSectionHeader(sb.name),
        const SizedBox(height: 8),
        const Divider(color: kBorderDark, height: 12, thickness: 1),
        if (sb.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          gmNarrativeText(sb.description),
        ],
        const SizedBox(height: 14),
        // ── Compact stat table (manual style) ──────────────────────────
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff0e0d0c),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorderDark, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Movimento, Danno Bonus, PF
              if (sb.stats.length >= 3)
                _compactStatRow([sb.stats[0], sb.stats[1], sb.stats[2]]),
              // Row 2: Armatura + PV
              if (sb.stats.length >= 5)
                _compactStatRow([sb.stats[3], sb.stats[4]]),
              // Extra stats if any
              ...sb.stats.skip(5).map((e) => _compactStatRow([e])),

              // Abilità — single inline line
              if (sb.skills.isNotEmpty)
                _compactLabelLine(
                  'Abilità',
                  sb.skills.map((e) => '${e.label} ${e.value}').join(', '),
                ),

              // Capacità — inline
              if (sb.abilities.isNotEmpty)
                _compactLabelLine('Capacità', sb.abilities.join(', ')),

              // Armi — one-liner sentence
              if (sb.weapons.isNotEmpty)
                _compactLabelLine(
                  'Armi',
                  sb.weapons.map((w) {
                    if (w.skill == '—' || w.skill.isEmpty) return w.name;
                    return '${w.name} (livello di abilità ${w.skill}, danno ${w.damage})';
                  }).join(', '),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Two-column compact row: "Label: Value  |  Label: Value"
  static Widget _compactStatRow(List<StatEntry> entries) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderDark, width: 0.5)),
      ),
      child: Row(
        children: entries
            .expand((e) sync* {
              yield Expanded(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${e.label}: ',
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: e.value,
                      style: const TextStyle(
                        color: kTextLight,
                        fontSize: 11,
                      ),
                    ),
                  ]),
                ),
              );
            })
            .toList(),
      ),
    );
  }

  /// Full-width label+value line (for abilità, capacità, armi)
  static Widget _compactLabelLine(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderDark, width: 0.5)),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: kGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ]),
      ),
    );
  }

  static Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        color: kGold,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Interactive sub-location map with clickable pins
  // -------------------------------------------------------------------------
  static Widget buildSubLocationMap({
    required SceneData scene,
    required bool isGm,
    required VttSyncService syncService,
    required String subMapId,
  }) {
    return _SubLocationMapWidget(
      scene: scene,
      isGm: isGm,
      syncService: syncService,
      subMapId: subMapId,
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful widget for the interactive sub-location map
// Supports: zoom/pan, tap-to-info on static pins, drag to move, long-press to add/remove
// ---------------------------------------------------------------------------
class _SubLocationMapWidget extends StatefulWidget {
  final SceneData scene;
  final bool isGm;
  final VttSyncService syncService;
  final String subMapId;
  const _SubLocationMapWidget({
    required this.scene,
    required this.isGm,
    required this.syncService,
    required this.subMapId,
  });

  @override
  State<_SubLocationMapWidget> createState() => _SubLocationMapWidgetState();
}

class _SubLocationMapWidgetState extends State<_SubLocationMapWidget> {
  // Which pin node's popup is open
  MapNode? _selectedNode;

  // Dragging state
  String? _draggingId;
  bool get _isDragging => _draggingId != null;

  final TransformationController _ctrl = TransformationController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Convert global pointer position → xFraction/yFraction within the map widget
  Offset _toFraction(Offset globalPos, RenderBox box) {
    final local = box.globalToLocal(globalPos);
    return Offset(
      (local.dx / box.size.width).clamp(0.02, 0.98),
      (local.dy / box.size.height).clamp(0.02, 0.98),
    );
  }

  void _showAddPinDialog(BuildContext context, Offset frac) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isGmOnly = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: kDarkBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: kGold, width: 1.5),
              ),
              title: Text(
                "AGGIUNGI PIN",
                style: GoogleFonts.cinzel(color: kGold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: kTextLight),
                      decoration: const InputDecoration(
                        labelText: "Nome Luogo / Numero",
                        labelStyle: TextStyle(color: kTextMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorderDark)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: kTextLight),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Note / Descrizione",
                        labelStyle: TextStyle(color: kTextMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorderDark)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text("Visibile solo al GM", style: TextStyle(color: kTextLight, fontSize: 13)),
                      value: isGmOnly,
                      onChanged: (val) {
                        setStateDialog(() {
                          isGmOnly = val ?? false;
                        });
                      },
                      activeColor: kGold,
                      checkColor: kDarkBg,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("ANNULLA", style: TextStyle(color: kTextMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    if (name.isEmpty) return;

                    final newNode = MapNode(
                      id: "node_${DateTime.now().millisecondsSinceEpoch}",
                      name: name,
                      description: desc,
                      xPercent: double.parse((frac.dx * 100).toStringAsFixed(1)),
                      yPercent: double.parse((frac.dy * 100).toStringAsFixed(1)),
                      isGmOnly: isGmOnly,
                      targetSubMap: '',
                      subMapId: widget.subMapId,
                    );

                    final currentAllNodes = widget.syncService.currentRoom?.mapNodes ?? [];
                    final updatedList = List<MapNode>.from(currentAllNodes)..add(newNode);

                    widget.syncService.updateMapNodes(updatedList);
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kGold),
                  child: const Text("CREA", style: TextStyle(color: kDarkBg, fontWeight: FontWeight.bold)),
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
    final asset = widget.scene.subMapAsset!;
    final isGm = widget.isGm;
    final room = widget.syncService.currentRoom;
    
    if (room == null) return const Center(child: CircularProgressIndicator());

    final allNodes = room.mapNodes;
    final subMapNodes = allNodes.where((n) => n.subMapId == widget.subMapId).toList();

    // Auto-initialize static pins on the server if empty or update static pins if names mismatch
    bool needsUpdate = isGm && subMapNodes.isEmpty && widget.scene.mapPins.isNotEmpty;
    
    // Check if pins 8 or 9 are old names (Pozzo / Formazioni Rocciose) and force refresh
    if (isGm && !needsUpdate && widget.scene.mapPins.isNotEmpty) {
      final pin8 = subMapNodes.firstWhere((n) => n.name.contains('Pozzo') || n.name.contains('Formazioni'), orElse: () => MapNode(id: '', name: '', description: '', xPercent: 0, yPercent: 0, isGmOnly: false, targetSubMap: '', subMapId: ''));
      if (pin8.id.isNotEmpty) {
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      final List<MapNode> initialNodes = [];
      for (int i = 0; i < widget.scene.mapPins.length; i++) {
        final pin = widget.scene.mapPins[i];
        String targetMap = '';
        if (pin.label == '5' || pin.name.contains('Ulvar')) targetMap = 'orlo_negozio';
        if (pin.label == '7' || pin.name.contains('Mulino') || pin.name.contains('Halfling')) targetMap = 'orlo_mulino_halfling';
        if (pin.label == '8' || pin.name.contains('Tempio')) targetMap = 'orlo_tempio';
        if (pin.label == '9' || pin.name.contains('Capanno') || pin.name.contains('Dranath')) targetMap = 'orlo_capanno_dranath';
        if (pin.label == '4' || pin.name.contains('Tre Cervi')) targetMap = 'locanda_tre_cervi';

        initialNodes.add(MapNode(
          id: "pin_${widget.subMapId}_${i}",
          name: pin.name,
          description: pin.description ?? '',
          xPercent: pin.xFraction * 100,
          yPercent: pin.yFraction * 100,
          isGmOnly: false,
          targetSubMap: targetMap,
          subMapId: widget.subMapId,
        ));
      }
      final otherNodes = allNodes.where((n) => n.subMapId != widget.subMapId).toList();
      final updatedList = List<MapNode>.from(otherNodes)..addAll(initialNodes);
      Future.microtask(() => widget.syncService.updateMapNodes(updatedList));
    }

    // Filter visible nodes based on role
    final visibleNodes = subMapNodes.where((node) {
      if (node.isGmOnly && !isGm) return false;
      return true;
    }).toList();

    return Stack(
      children: [
        // ── Zoomable map ──────────────────────────────────────────────────
        InteractiveViewer(
          transformationController: _ctrl,
          panEnabled: !_isDragging,
          scaleEnabled: !_isDragging,
          minScale: 0.5,
          maxScale: 5.0,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return GestureDetector(
                onLongPressStart: isGm
                    ? (details) {
                        final box = ctx.findRenderObject() as RenderBox;
                        final frac = _toFraction(details.globalPosition, box);
                        _showAddPinDialog(context, frac);
                      }
                    : null,
                onTap: () => setState(() => _selectedNode = null),
                child: Stack(
                  children: [
                    // Map image
                    Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),

                    // ── Map Nodes Overlay ─────────────────────────────────
                    ...visibleNodes.map((node) {
                      final left = constraints.maxWidth * (node.xPercent / 100) - 16;
                      final top = constraints.maxHeight * (node.yPercent / 100) - 16;
                      final isSelected = _selectedNode == node;

                      // Derive label from index or node name
                      String label = '★';
                      if (node.id.startsWith("pin_${widget.subMapId}_")) {
                        final parts = node.id.split('_');
                        if (parts.length > 2) {
                          final idx = int.tryParse(parts.last);
                          if (idx != null && idx < widget.scene.mapPins.length) {
                            label = widget.scene.mapPins[idx].label;
                          }
                        }
                      } else {
                        label = node.name.length <= 3 ? node.name : '★';
                      }

                      final pinBadge = _PinBadge(
                        label: label,
                        selected: isSelected,
                        custom: !node.id.startsWith("pin_${widget.subMapId}_"),
                      );

                      return Positioned(
                        left: left,
                        top: top,
                        child: isGm
                            ? Draggable<MapNode>(
                                data: node,
                                feedback: _PinBadge(
                                  label: label,
                                  selected: true,
                                  custom: !node.id.startsWith("pin_${widget.subMapId}_"),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: pinBadge,
                                ),
                                onDragStarted: () => setState(() {
                                  _draggingId = node.id;
                                  _selectedNode = null;
                                }),
                                onDragEnd: (details) {
                                  final box = ctx.findRenderObject() as RenderBox;
                                  final frac = _toFraction(details.offset + const Offset(16, 16), box);

                                  final currentAllNodes = widget.syncService.currentRoom?.mapNodes ?? [];
                                  final idx = currentAllNodes.indexWhere((n) => n.id == node.id);
                                  if (idx != -1) {
                                    final updatedList = List<MapNode>.from(currentAllNodes);
                                    updatedList[idx] = MapNode(
                                      id: node.id,
                                      name: node.name,
                                      description: node.description,
                                      xPercent: double.parse((frac.dx * 100).toStringAsFixed(1)),
                                      yPercent: double.parse((frac.dy * 100).toStringAsFixed(1)),
                                      isGmOnly: node.isGmOnly,
                                      isLocked: node.isLocked,
                                      targetSubMap: node.targetSubMap,
                                      subMapId: node.subMapId,
                                    );
                                    widget.syncService.updateMapNodes(updatedList);
                                  }
                                  setState(() {
                                    _draggingId = null;
                                  });
                                },
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedNode = isSelected ? null : node),
                                  child: pinBadge,
                                ),
                              )
                            : GestureDetector(
                                onTap: () => setState(() => _selectedNode = isSelected ? null : node),
                                child: pinBadge,
                              ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Info popup for selected node (GM & Players) ───────────────────
        if (_selectedNode != null)
          Positioned(
            right: 16,
            top: 80,
            bottom: 80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 320,
              decoration: BoxDecoration(
                color: kDarkBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(-4, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: kBorderDark, width: 1)),
                    ),
                    child: Row(
                      children: [
                        // Pin Badge display
                        Builder(
                          builder: (context) {
                            String label = '★';
                            if (_selectedNode!.id.startsWith("pin_${widget.subMapId}_")) {
                              final parts = _selectedNode!.id.split('_');
                              if (parts.length > 2) {
                                final idx = int.tryParse(parts.last);
                                if (idx != null && idx < widget.scene.mapPins.length) {
                                  label = widget.scene.mapPins[idx].label;
                                }
                              }
                            } else {
                              label = _selectedNode!.name.length <= 3 ? _selectedNode!.name : '★';
                            }
                            return _PinBadge(
                              label: label,
                              selected: true,
                              custom: !_selectedNode!.id.startsWith("pin_${widget.subMapId}_"),
                            );
                          }
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedNode!.name,
                            style: GoogleFonts.cinzel(
                              color: kGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: kDragonRed, size: 18),
                          onPressed: () => setState(() => _selectedNode = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _selectedNode!.description,
                        style: const TextStyle(
                          color: kTextLight,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (isGm) ...[
                    const Divider(color: kBorderDark, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Builder(
                            builder: (context) {
                              String targetMap = _selectedNode!.targetSubMap;
                              final name = _selectedNode!.name;
                              final id = _selectedNode!.id;
                              if (targetMap.isEmpty) {
                                if (id.endsWith('_8') || name.contains('Tempio')) targetMap = 'orlo_tempio';
                                else if (id.endsWith('_9') || name.contains('Capanno') || name.contains('Dranath')) targetMap = 'orlo_capanno_dranath';
                                else if (id.endsWith('_7') || name.contains('Mulino') || name.contains('Halfling')) targetMap = 'orlo_mulino_halfling';
                                else if (id.endsWith('_5') || name.contains('Ulvar')) targetMap = 'orlo_negozio';
                                else if (id.endsWith('_4') || name.contains('Cervi')) targetMap = 'locanda_tre_cervi';
                              }

                              if (targetMap.isEmpty) return const SizedBox.shrink();

                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff7a1515),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                icon: const Icon(Icons.meeting_room, color: Color(0xffdfc48c), size: 14),
                                label: const Text("ENTRA IN QUESTO LUOGO", style: TextStyle(color: Color(0xffdfc48c), fontSize: 10, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  if (isGm) {
                                    widget.syncService.changeActiveMap(targetMap);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Solo il GM può cambiare la mappa attiva della sessione.")),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: kDragonRed, size: 16),
                            label: const Text("ELIMINA PIN", style: TextStyle(color: kDragonRed, fontSize: 11)),
                            onPressed: () {
                              final currentAllNodes = widget.syncService.currentRoom?.mapNodes ?? [];
                              final updatedList = List<MapNode>.from(currentAllNodes)
                                ..removeWhere((n) => n.id == _selectedNode!.id);
                              widget.syncService.updateMapNodes(updatedList);
                              setState(() {
                                _selectedNode = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

        // ── GM help bar ───────────────────────────────────────────────────
        if (isGm)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kDarkBg.withOpacity(0.85),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kBorderDark),
              ),
              child: Text(
                '🔢 tap = info  •  drag = sposta  •  tieni premuto mappa = aggiungi  •  tieni premuto popup = elimina',
                style: GoogleFonts.cinzel(
                  color: kTextMuted,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Small circular pin badge — teal for static, amber for custom
class _PinBadge extends StatelessWidget {
  final String label;
  final bool selected;
  final bool custom;
  const _PinBadge({required this.label, this.selected = false, this.custom = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? kGold
        : custom
            ? const Color(0xff7a4a00)
            : const Color(0xff2a6b5e);
    final border = selected
        ? Colors.white
        : custom
            ? const Color(0xffffa040)
            : const Color(0xff4db89e);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: selected ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(selected ? 0.7 : 0.4),
            blurRadius: selected ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? kDarkBg : Colors.white,
            fontSize: label.length > 2 ? 9 : 11,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
