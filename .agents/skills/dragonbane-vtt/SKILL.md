---
name: dragonbane-vtt
description: >
  Project-specific skill for the Dragonbane VTT (Virtual Tabletop) built with Flutter Web.
  Activates automatically when working on the calm-babbage project. Provides instant
  context on architecture, file map, and the exact workflow for common tasks — eliminating
  the need to explore the codebase at the start of every session.
---

# Dragonbane VTT — Project Skill

## What this project is

A Flutter Web VTT (Virtual Tabletop) for the TTRPG module *Il Segreto dell'Imperatore Drago* (Dragonbane system).
It has a GM view and a player view, synchronized in real-time via `MockSyncService` (simulated WebSocket).
Built with Flutter, served as a static web app from `build/web/`.

## Architecture at a glance

```
lib/
  main.dart                  # Router: Login → OverworldMap → SubMap, tab navigation
  core/
    sync/
      sync_interface.dart    # VttSyncService abstract class (the contract)
      mock_sync.dart         # In-memory implementation with _sceneMaxIndex map
    theme.dart               # VttTheme colors
  models/
    game_room.dart           # GameRoom: activeMapId, revealedHandouts, tokens, players
    character.dart           # Character/token model
    map_node.dart            # MapNode (overworld pins)
  views/
    overworld_map_view.dart  # Main map with pins; tapping a pin calls changeActiveMap()
    sub_map_view.dart        # Scene viewer + tactical grid. Core logic here (~2100 lines)
    gm_dashboard_view.dart   # GM admin panel
    character_sheet_view.dart
  scenes/
    scene_models.dart        # Pure data classes: SceneConfig, SceneData, StatBlockData…
    scene_registry.dart      # THE ONLY FILE to edit when adding scenes/locations
    scene_engine.dart        # Reads registry data → builds widgets (never edit for content)
    vtt_scene_widgets.dart   # Low-level UI helpers (handoutCard, gmSidePanel, statRow…)
```

## The data-driven scene system (KEY CONCEPT)

**To add a new location or scene: edit ONLY `scene_registry.dart`.**
No widget code needed. The engine handles everything.

### SceneData fields (all optional):
- `showCinematic: bool` — false = show tactical grid instead of cinematic background
- `backgroundAsset: String?` — overrides location default background
- `overlay: SceneOverlay?` — `.none | .sunlight | .smoke`
- `introText: String?` — small text card at bottom of screen (e.g. opening quote)
- `handout: HandoutData?` — image card shown to players
- `gmNotes: GmNotesData?` — GM side panel with narrative + read-aloud + body text
- `gmStatBlock: StatBlockData?` — NPC stat block in GM panel (compact layout matching manual)
- `gmToggle: GmToggleData?` — extra GM button to reveal/hide an extra handout
- `subMapAsset: String?` — **interactive zoomable sub-location map** with pin overlay
- `mapPins: List<MapPinData>` — clickable numbered pins on the sub-map (GM gets popup)

### ⚠️ IMPORTANT — Apostrophes in Dart strings

**Always use double-quoted strings** (`"..."`) for any description text containing Italian apostrophes (`'`).
Using single-quoted strings with `'` inside causes a parse error.

```dart
// WRONG — breaks the Dart parser:
description: 'L'acqua proviene da...',

// CORRECT — use double quotes:
description: "L'acqua proviene da...",
```

### Template for adding a new location:

```dart
// In scene_registry.dart, add to the Map:
'my_new_location_id': SceneConfig(
  mapId: 'my_new_location_id',
  defaultBackground: 'assets/images/my_location_bg.jpg',
  defaultOverlay: SceneOverlay.none,  // or .smoke or .sunlight
  scenes: [
    // Scene 0: cinematic intro + optional handout + optional statblock
    SceneData(
      gmNotes: GmNotesData(
        sectionTitle: 'NOME SEZIONE',
        narrative: 'Testo narrativo in corsivo...',
        readAloud: 'Testo da leggere ai giocatori...',
        bodyText: 'Note aggiuntive GM...',
      ),
    ),
    // Scene 1: handout + statblock NPC
    SceneData(
      handout: HandoutData(
        title: 'NOME NPC',
        asset: 'assets/images/npc_portrait.jpg',
      ),
      gmStatBlock: StatBlockData(
        name: 'NOME NPC',
        description: 'Descrizione...',
        // StatEntry order matters for compact layout:
        // stats[0]=Movimento, [1]=DannoBonus, [2]=PF, [3]=Armatura, [4]=PV
        stats: [StatEntry('Movimento','10'), StatEntry('Danno Bonus FOR','+D4'),
                StatEntry('PF','12'), StatEntry('Armatura','Cuoio (2)'), StatEntry('PV','10')],
        skills: [StatEntry('Combattimento', '14')],
        abilities: ['Abilità speciale'],
        weapons: [WeaponEntry('Spada', '14', '2D6')],
      ),
    ),
    // Scene 2: interactive sub-location map (see pin workflow below)
    SceneData(
      subMapAsset: 'assets/images/my_location_map.jpg',
      mapPins: [
        MapPinData(label:'1', name:'Nome luogo', description:"Descrizione GM.", xFraction:0.5, yFraction:0.5),
        // ... più pin
      ],
    ),
  ],
),

// Also add to mock_sync.dart _sceneMaxIndex:
'my_new_location_id': 2,  // = scenes.length - 1
```

Also add a pin in `overworld_map_view.dart` pointing to the new mapId.

---

## 🗺️ Workflow ottimizzato per le sottomappe (MIN TOKEN)

> Aggiungere una nuova sottomappa richiede **solo 3 passi** — nessuna esplorazione di file.

### Passo 1 — Genera la mappa (se necessario)

Usa `generate_image` con un prompt dettagliato. Copia il file in `assets/images/`.

### Passo 2 — Aggiungi le coordinate pin in `assets/submaps/pin_coords.json`

```json
"nome_location_id": [
  { "label": "1",  "name": "Cancello",  "x": 0.50, "y": 0.84 },
  { "label": "2",  "name": "Locanda",   "x": 0.35, "y": 0.60 }
]
```

Le coordinate `x`/`y` sono frazioni 0.0–1.0 dell'immagine (0,0 = angolo top-left).
**Stima iniziale** delle posizioni guardando l'immagine: raffina dopo build se necessario.

### Passo 3 — In scene_registry.dart usa la lista pin compatta

```dart
SceneData(
  subMapAsset: 'assets/images/nome_location_map.jpg',
  mapPins: [
    MapPinData(label:'1', name:'Cancello', xFraction:0.50, yFraction:0.84),
    MapPinData(label:'2', name:'Locanda',  xFraction:0.35, yFraction:0.60),
  ],
),
```

Per le descrizioni GM (opzionali) usa **SEMPRE doppi apici** se il testo ha apostrofi:
```dart
description: "L'acqua proviene da...",  // CORRETTO
```

### Calibrazione coordinate pin

Dopo il build, se i pin non sono sui numeri giusti della mappa:
1. Apri `assets/submaps/pin_coords.json` — aggiusta `x` e `y`
2. Aggiorna le stesse coordinate in `scene_registry.dart` (stesso valore)
3. Rebuild

---

## Sync system

- `changeActiveMap(mapId)` → broadcasts to all clients, resets sceneIndex to 0
- `revealHandout(mapId)` → increments sceneIndex (capped by `_sceneMaxIndex`)
- `hideHandout(mapId)` → decrements sceneIndex
- All state lives in `GameRoom` model, distributed via `notifyListeners()`
- Players see scene changes automatically via `Provider.of<VttSyncService>`

## Build & run

```powershell
# Build (must rename native folders first):
Rename-Item "_android" "android"; Rename-Item "_ios" "ios"
C:\Users\eleon\.puro\envs\stable\flutter\bin\flutter.bat build web --release
# After build, rename back:
Rename-Item "android" "_android"; Rename-Item "ios" "_ios"

# Delete service worker to force browser refresh:
Remove-Item "build\web\flutter_service_worker.js" -ErrorAction SilentlyContinue

# Serve locally:
python -m http.server 8080 --directory build\web
```

## Key conventions

- Colors: `kGold = #dfc48c`, `kDragonRed = #8a1c1c`, `kDarkBg = #141210`, `kPanelBg = #181513`
- Fonts: Cinzel (headings/titles), serif inline (read-aloud boxes)
- GM panel is always 450px wide, right side of screen
- `withOpacity()` is deprecated — use `.withValues(alpha: x)` for new code
- Animations: `AnimatedSmokeOverlay`, `AnimatedSunlightOverlay` are in `sub_map_view.dart`
- StatBlock layout: stats[0]=Movimento, [1]=DannoBonus, [2]=PF, [3]=Armatura, [4]=PV (ordine conta per layout compatto)

## Files NOT to touch for content changes

- `sub_map_view.dart` — only for structural/UI fixes
- `scene_engine.dart` — only if adding new widget capabilities
- `vtt_scene_widgets.dart` — only if adding new UI primitives
- `mock_sync.dart` — only the `_sceneMaxIndex` map needs updating when adding locations
- `assets/submaps/pin_coords.json` — reference for pin coordinates (human-readable, not loaded at runtime)
