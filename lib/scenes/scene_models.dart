import 'package:flutter/material.dart';

// scene_models.dart
// Data classes for the data-driven VTT scene system.
// To add a new location: add a SceneConfig to scene_registry.dart. No widget code needed.

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum SceneOverlay {
  none,
  sunlight,  // mountain pass rays
  smoke,     // village chimney smoke + swaying wheat
}

enum HandoutLayout {
  centered,   // card appears in the center of screen
  leftSide,   // card positioned on the left (e.g. uomo perduto)
}

// ---------------------------------------------------------------------------
// Handout card config
// ---------------------------------------------------------------------------
class HandoutData {
  final String title;
  final String asset;
  final HandoutLayout layout;
  final double width;
  final double height;

  const HandoutData({
    required this.title,
    required this.asset,
    this.layout = HandoutLayout.centered,
    this.width = 480,
    this.height = 560,
  });
}

// ---------------------------------------------------------------------------
// Stat block pieces
// ---------------------------------------------------------------------------
class StatEntry {
  final String label;
  final String value;
  const StatEntry(this.label, this.value);
}

class WeaponEntry {
  final String name;
  final String skill;
  final String damage;
  const WeaponEntry(this.name, this.skill, this.damage);
}

class StatBlockData {
  final String name;
  final String description;
  final List<StatEntry> stats;
  final List<StatEntry> skills;
  final List<String> abilities;
  final List<WeaponEntry> weapons;

  const StatBlockData({
    required this.name,
    required this.description,
    this.stats = const [],
    this.skills = const [],
    this.abilities = const [],
    this.weapons = const [],
  });
}

// ---------------------------------------------------------------------------
// GM notes panel content
// ---------------------------------------------------------------------------
class GmNotesData {
  final String sectionTitle;
  final String? narrative;   // italic intro text
  final String? readAloud;   // red-bordered read-aloud box
  final String? bodyText;    // plain info text after the box

  const GmNotesData({
    required this.sectionTitle,
    this.narrative,
    this.readAloud,
    this.bodyText,
  });
}

// ---------------------------------------------------------------------------
// Optional GM-only toggle button (e.g. show/hide Maladûk symbol)
// ---------------------------------------------------------------------------
class GmToggleData {
  final String handoutKey;    // key in revealedHandouts map
  final String showLabel;
  final String hideLabel;

  const GmToggleData({
    required this.handoutKey,
    required this.showLabel,
    required this.hideLabel,
  });
}

// ---------------------------------------------------------------------------
// A clickable pin on an interactive sub-location map
// ---------------------------------------------------------------------------
class MapPinData {
  /// Short label shown on the pin badge (e.g. "1", "2A", "7").
  final String label;

  /// Full name shown in the GM popup panel.
  final String name;

  /// GM-only description shown when the pin is tapped.
  final String? description;

  /// Horizontal position as a fraction of image width (0.0 = left, 1.0 = right).
  final double xFraction;

  /// Vertical position as a fraction of image height (0.0 = top, 1.0 = bottom).
  final double yFraction;

  const MapPinData({
    required this.label,
    required this.name,
    this.description,
    required this.xFraction,
    required this.yFraction,
  });
}

// ---------------------------------------------------------------------------
// A single scene within a location
// ---------------------------------------------------------------------------

class DirectionButtonData {
  final String label;
  final int targetSceneIndex;
  final IconData? icon;

  const DirectionButtonData({
    required this.label,
    required this.targetSceneIndex,
    this.icon,
  });
}

class SceneData {
  /// If provided, overrides the location's defaultBackground for this scene.
  final String? backgroundAsset;

  /// Animated overlay for this scene (overrides location default if set).
  final SceneOverlay? overlay;

  /// Handout card visible to players (and GM).
  final HandoutData? handout;

  /// Short text card shown at the bottom of screen (e.g. intro quote).
  final String? introText;

  /// GM-only notes panel content.
  final GmNotesData? gmNotes;

  /// GM-only stat block panel (shown below/instead of gmNotes when present).
  final StatBlockData? gmStatBlock;

  /// Optional extra toggle button in the handout card (GM only).
  final GmToggleData? gmToggle;

  /// When false, shows the tactical/interactive map instead of the cinematic view.
  /// Set to false for pure tactical scenes (no background image needed).
  final bool showCinematic;

  /// If set, renders an interactive zoomable sub-location map with overlaid pins.
  /// Takes priority over showCinematic=false (replaces the tactical grid).
  final String? subMapAsset;

  /// Clickable numbered pins overlaid on subMapAsset.
  final List<MapPinData> mapPins;

  /// Directional navigation buttons for moving between scenes in a dungeon/location.
  final List<DirectionButtonData> directions;

  /// Secret GM-only action buttons (e.g. "Mostra vista valle", "Mostra arpie").
  final List<DirectionButtonData> gmActions;

  const SceneData({
    this.backgroundAsset,
    this.overlay,
    this.handout,
    this.introText,
    this.gmNotes,
    this.gmStatBlock,
    this.gmToggle,
    this.showCinematic = true,
    this.subMapAsset,
    this.mapPins = const [],
    this.directions = const [],
    this.gmActions = const [],
  });
}

// ---------------------------------------------------------------------------
// Full location configuration
// ---------------------------------------------------------------------------
class SceneConfig {
  /// Must match the subMapId used in navigation (e.g. 'sentiero_iniziale').
  final String mapId;

  /// Background image shown during the cinematic handout phase.
  final String defaultBackground;

  /// Default animated overlay for all scenes in this location.
  final SceneOverlay defaultOverlay;

  /// Ordered list of scenes. Index matches revealedHandouts[mapId] value.
  final List<SceneData> scenes;

  const SceneConfig({
    required this.mapId,
    required this.defaultBackground,
    this.defaultOverlay = SceneOverlay.none,
    required this.scenes,
  });

  int get maxSceneIndex => scenes.length - 1;

  SceneData? sceneAt(int index) {
    if (index < 0 || index >= scenes.length) return null;
    return scenes[index];
  }
}
