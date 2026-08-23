import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sync/sync_interface.dart';
import '../models/game_room.dart';
import 'vtt_scene_widgets.dart';

// ---------------------------------------------------------------------------
// ORLO — Villaggio di Orlo
// Max scene index: 2  (scenes 0..2, set in mock_sync.dart)
//   0 → cinematic cover (smoke + wheat animation, no extra card)
//   1 → Hardy portrait handout (players) + stat block panel (GM only)
//   2 → (free map mode, no handout)
// ---------------------------------------------------------------------------

/// Returns the handout overlay widget for Orlo at the given [sceneIndex].
/// Returns null if no handout card should be shown.
Widget? orloHandout({
  required int sceneIndex,
  required bool isGm,
  required GameRoom room,
  required VttSyncService syncService,
  required String subMapId,
}) {
  // Scene 0: just the cinematic background (no extra card needed)
  if (sceneIndex == 0) return null;

  // Scene 1: Hardy portrait card (visible to players too)
  if (sceneIndex == 1) {
    return imageHandoutCard(
      title: 'HARDY',
      assetPath: 'assets/images/hardy_portrait.jpg',
      isGm: isGm,
      onClose: () => syncService.hideHandout(subMapId),
    );
  }

  return null;
}

// ---------------------------------------------------------------------------
// GM Notes panel for Orlo — changes content per sceneIndex
// ---------------------------------------------------------------------------
Widget orloGmNotes(int sceneIndex) {
  return gmSidePanel(
    child: _orloNotesContent(sceneIndex),
  );
}

Widget _orloNotesContent(int sceneIndex) {
  // Scene 0 → arrival narrative
  if (sceneIndex == 0) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gmSectionHeader('ARRIVO A ORLO'),
        const SizedBox(height: 12),
        gmNarrativeText(
          'Dopo la scena di apertura, i personaggi si dirigono '
          'direttamente a Orlo, impiegando circa un giorno di cammino.\n\n'
          'La vegetazione si infittisce diventando una densa foresta mentre i personaggi scendono verso la Valle Nebbiosa. '
          'Fortunatamente, possono seguire con facilità i resti della '
          'stessa vecchia strada che porta fino alle montagne e attraversa la foresta.\n\n'
          'Qua e là, spuntano dal terreno pietre miliari segnate '
          'dalle intemperie, alcune delle quali decorate con antiche '
          'corone stilizzate. A pochi chilometri da Orlo, la foresta si '
          'dirada, aprendosi su campi coltivati. Presto, i personaggi si '
          'trovano a sguazzare lungo i solchi fangosi dei carri.\n\n'
          'Leggi o recita il seguente testo ai giocatori appena '
          'giungono a Orlo:',
        ),
        const SizedBox(height: 16),
        readAloudBox(
          'Le tracce dei carri lasciano il posto a una strada lastricata '
          'che taglia in due gli alti campi di grano. Innumerevoli '
          'profumi pervadono i vostri sensi: letame, fumo e verdure '
          'marce, ma anche pane appena sfornato e carne grigliata. '
          'La strada conduce a un insediamento circondato da '
          'una palizzata, con tante piccole case dai camini fumanti, '
          'visibili da oltre i pali aguzzi.\n\n'
          'Il cancello del villaggio è chiuso e fiancheggiato da '
          'due basse e resistenti torri in pietra con merlature e tetti '
          'di legno appuntiti. Mentre vi avvicinate, sentite la voce '
          'severa di un uomo che vi urla da una delle torri:\n\n'
          '"Fermi, stranieri! Dite i vostri nomi e il motivo del '
          'vostro arrivo, o giratevi e tornate nella foresta. Questo è '
          'un luogo di pace e decoro."',
        ),
        const SizedBox(height: 16),
        gmBodyText(
          'La torre è il luogo #2A e l\'uomo è Hardy (pag. 19). Vuole '
          'sapere i nomi dei personaggi e il motivo del loro arrivo '
          'a Orlo. Se il gruppo risponde alle domande e afferma di '
          'venire in pace, il cancello si apre scricchiolando. Se i '
          'personaggi provano a porgli delle domande, Hardy li manda '
          'fermamente a cercare Vagnhild alla locanda Tre Cervi.',
        ),
      ],
    );
  }

  // Scene 1 → Hardy stat block
  if (sceneIndex == 1) {
    return _hardyStatBlock();
  }

  // Fallback
  return const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Hardy full stat block (GM-only side panel)
// ---------------------------------------------------------------------------
Widget _hardyStatBlock() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      gmSectionHeader('HARDY'),
      const SizedBox(height: 8),
      const Divider(color: kBorderDark, height: 12, thickness: 1),
      const SizedBox(height: 8),
      gmNarrativeText(
        'Hardy è un veterano di guerra temprato dalle battaglie. Ha una '
        'quarantina d\'anni, capelli fino alle spalle e il naso rotto. '
        'È forte e taciturno, ma ha un lato emotivo che emerge dopo qualche '
        'boccale di idromele alla locanda.\n\n'
        'Qualche volta esce dal villaggio per scacciare goblin, banditi e '
        'altri potenziali attaccabrighe. Durante queste spedizioni è '
        'accompagnato spesso dal figlio di Mastro Ulvar del negozio di Orlo '
        '(#5), Jory, che Hardy considera come suo successore.',
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff0e0d0c),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kDragonRed, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'STATISTICHE',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            statRow('Movimento', '12'),
            statRow('Danno Bonus FOR', '+D4'),
            statRow('PF', '16'),
            statRow('PV', '14'),
            statRow('Armatura', 'Cuoio borchiato e celata (3)'),
            const SizedBox(height: 10),
            Text(
              'ABILITÀ',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            statRow('Consapevolezza', '14'),
            statRow('Guarire', '8'),
            statRow('Rissa', '14'),
            statRow('Sfuggire', '12'),
            const SizedBox(height: 10),
            Text(
              'CAPACITÀ',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            gmBodyText('Difensivo, Veterano'),
            const SizedBox(height: 10),
            Text(
              'ARMI',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            statRow('Spadone', 'livello abilità 14, danno 2D6'),
            statRow('Balestra pesante', 'livello abilità 12, danno 2D8'),
            statRow('Scudo grande', '—'),
          ],
        ),
      ),
    ],
  );
}
