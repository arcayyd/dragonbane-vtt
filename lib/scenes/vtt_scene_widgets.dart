import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scene_models.dart';


// ---------------------------------------------------------------------------
// Design constants reused across all scenes
// ---------------------------------------------------------------------------
const Color kGold = Color(0xffdfc48c);
const Color kDarkBg = Color(0xff141210);
const Color kBorderDark = Color(0xff3d332a);
const Color kTextMuted = Color(0xffa89d8d);
const Color kTextLight = Color(0xffe5dcc6);
const Color kDragonRed = Color(0xff8a1c1c);
const Color kPanelBg = Color(0xff181513);

// ---------------------------------------------------------------------------
// Reusable handout card container (portrait-style, centered)
// ---------------------------------------------------------------------------
Widget handoutCard({
  required String title,
  required Widget content,
  required bool isGm,
  required VoidCallback onClose,
  double width = 480,
  double height = 560,
}) {
  return Center(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kDarkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
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
                  title,
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isGm)
                IconButton(
                  icon: const Icon(Icons.close, color: kDragonRed, size: 20),
                  tooltip: 'Chiudi Handout',
                  onPressed: onClose,
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: kBorderDark, height: 12, thickness: 1),
          const SizedBox(height: 12),
          Expanded(child: content),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Simple image handout card
// ---------------------------------------------------------------------------
Widget imageHandoutCard({
  required String title,
  required String assetPath,
  required bool isGm,
  required VoidCallback onClose,
  double width = 480,
  double height = 560,
}) {
  return handoutCard(
    title: title,
    isGm: isGm,
    onClose: onClose,
    width: width,
    height: height,
    content: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(assetPath, fit: BoxFit.contain),
    ),
  );
}

// ---------------------------------------------------------------------------
// Left-side positioned handout (e.g. uomo perduto)
// ---------------------------------------------------------------------------
Widget positionedImageHandout({
  required String title,
  required String assetPath,
  required bool isGm,
  required VoidCallback onClose,
  double left = 60,
  double top = 60,
  double bottom = 120,
  double width = 420,
}) {
  return Positioned(
    left: left,
    top: top,
    bottom: bottom,
    child: Container(
      width: width,
      decoration: BoxDecoration(
        color: kDarkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  title,
                  style: GoogleFonts.cinzel(
                    color: kGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isGm)
                IconButton(
                  icon: const Icon(Icons.close, color: kDragonRed, size: 20),
                  tooltip: 'Chiudi/Nascondi Handout',
                  onPressed: onClose,
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: kBorderDark, height: 12, thickness: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// GM scene navigation bar (prev / next scene buttons)
// ---------------------------------------------------------------------------
Widget gmSceneControls({
  required int sceneIndex,
  required VoidCallback onPrev,
  required VoidCallback onNext,
  bool hasNext = true,
}) {
  return Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (sceneIndex > 0) ...[
            InkWell(
              onTap: onPrev,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderDark, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: kTextMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'SCENA PREC.',
                      style: GoogleFonts.cinzel(
                        color: kTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasNext) const SizedBox(width: 16),
          ],
          if (hasNext)
            InkWell(
              onTap: onNext,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: kDragonRed,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PROSSIMA SCENA',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// GM side panel container
// ---------------------------------------------------------------------------
Widget gmSidePanel({required Widget child, double width = 450}) {
  return Container(
    width: width,
    decoration: const BoxDecoration(
      color: kPanelBg,
      border: Border(left: BorderSide(color: kGold, width: 1.5)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'NOTE DEL KEEPER',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Divider(color: kBorderDark, height: 16, thickness: 1),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(child: child)),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Red-bordered boxed read-aloud text block
// ---------------------------------------------------------------------------
Widget readAloudBox(String text) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xff0e0d0c),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: kDragonRed, width: 1),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: kTextLight,
        fontSize: 13.5,
        height: 1.55,
        fontFamily: 'serif',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Section header inside GM panel
// ---------------------------------------------------------------------------
Widget gmSectionHeader(String title) {
  return Text(
    title,
    style: GoogleFonts.cinzel(
      color: kGold,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    ),
  );
}

// ---------------------------------------------------------------------------
// Narrative italic paragraph
// ---------------------------------------------------------------------------
Widget gmNarrativeText(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: kTextMuted,
      fontSize: 13,
      height: 1.45,
      fontStyle: FontStyle.italic,
    ),
  );
}

// ---------------------------------------------------------------------------
// Plain body text (GM notes, not italic)
// ---------------------------------------------------------------------------
Widget gmBodyText(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: kTextMuted,
      fontSize: 13.5,
      height: 1.45,
    ),
  );
}

// ---------------------------------------------------------------------------
// Stat block row
// ---------------------------------------------------------------------------
Widget statRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: kTextLight, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Maladûk symbol overlay (modal-style fullscreen)
// ---------------------------------------------------------------------------
Widget maladukOverlay({required bool isGm, required VoidCallback onClose}) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Container(color: Colors.black.withOpacity(0.75)),
      Center(
        child: handoutCard(
          title: 'UNO STRANO TATUAGGIO',
          isGm: isGm,
          onClose: onClose,
          width: 480,
          height: 540,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset('assets/images/simbolo_maladuk.png', fit: BoxFit.contain),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// GM & Player Directional navigation buttons (e.g. NORD, SUD, EST, OVEST)
// ---------------------------------------------------------------------------
Widget directionalSceneControls({
  required List<DirectionButtonData> directions,
  List<DirectionButtonData> gmActions = const [],
  bool isGm = false,
  required Function(int targetSceneIndex, {String? actionLabel}) onSelectDirection,
}) {
  final List<Widget> children = [];

  // General direction buttons
  for (final dir in directions) {
    children.add(
      InkWell(
        onTap: () => onSelectDirection(dir.targetSceneIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: kDragonRed,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(dir.icon ?? Icons.explore, color: kGold, size: 18),
              const SizedBox(width: 8),
              Text(
                dir.label.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // GM-only secret action buttons
  if (isGm && gmActions.isNotEmpty) {
    for (final action in gmActions) {
      children.add(
        InkWell(
          onTap: () => onSelectDirection(action.targetSceneIndex, actionLabel: action.label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xff3b1d5a),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon ?? Icons.visibility, color: kGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  action.label.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  return Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: children,
      ),
    ),
  );
}
