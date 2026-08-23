# Dragonbane VTT — Regole di Progetto

## Regola #1 — Non esplorare mai la codebase all'inizio

Usa la skill `dragonbane-vtt` (`.agents/skills/dragonbane-vtt/SKILL.md`) come punto di partenza.
Contiene la mappa completa del progetto. Leggila **prima** di aprire qualsiasi file.

## Regola #2 — Per aggiungere scene: SOLO scene_registry.dart

Per aggiungere una nuova location o scena non toccare `sub_map_view.dart`, `scene_engine.dart` o altri file.
L'unico file da modificare è `lib/scenes/scene_registry.dart`.
Aggiorna anche `_sceneMaxIndex` in `mock_sync.dart`.

## Regola #3 — Build workflow

```powershell
# 1. Rinomina cartelle native (richiesto da flutter build web):
Rename-Item "_android" "android" -ErrorAction SilentlyContinue
Rename-Item "_ios" "ios" -ErrorAction SilentlyContinue

# 2. Build
C:\Users\eleon\.puro\envs\stable\flutter\bin\flutter.bat build web --release

# 3. Rinomina di ritorno
Rename-Item "android" "_android" -ErrorAction SilentlyContinue
Rename-Item "ios" "_ios" -ErrorAction SilentlyContinue

# 4. Avvia server locale
python -m http.server 8080 --directory build\web
```

## Regola #4 — Analisi errori

Usa `flutter analyze lib/` invece di analizzare l'intero progetto. I warning preesistenti su
`unused_local_variable`, `unused_import`, `unused_element` sono noti e non vanno fixati a meno che
l'utente non lo chieda esplicitamente.

## Regola #5 — Modifiche ai file grandi

`sub_map_view.dart` ha ~2100 righe. Usa **sempre** `grep_search` prima di modificarlo per
trovare le righe esatte. Non leggere mai l'intero file. Usa `multi_replace_file_content`
per modifiche multiple non contigue.

## Regola #6 — Sincronizzazione

Tutte le modifiche di stato (cambio mappa, avanzamento scena, reveal handout) passano per
`VttSyncService`. Non manipolare mai `GameRoom` direttamente nelle viste.
Il flusso è sempre: `syncService.method() → _broadcastRoomChange() → notifyListeners() → rebuild UI`.

## Lingua

L'utente scrive in italiano. Rispondi sempre in italiano.
I testi narrativi nel `scene_registry.dart` sono in italiano come da manuale originale.
