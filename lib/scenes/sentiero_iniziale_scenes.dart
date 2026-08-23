import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sync/sync_interface.dart';
import '../models/game_room.dart';
import 'vtt_scene_widgets.dart';

// ---------------------------------------------------------------------------
// SENTIERO INIZIALE — Passo di Drakmar
// Max scene index: 6  (scenes 0..6, set in mock_sync.dart)
// ---------------------------------------------------------------------------

/// Returns the handout overlay widget for the given [sceneIndex].
/// Returns null if no handout should be shown above the background.
Widget? sentieroHandout({
  required int sceneIndex,
  required bool isGm,
  required GameRoom room,
  required VttSyncService syncService,
  required String subMapId,
}) {
  // Scene 0: intro title card
  if (sceneIndex == 0) {
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
                '"Tanto tempo fa, da qualche parte nel passo di Drakar..."',
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

  // Scene 2: Uomo perduto (wounded man)
  if (sceneIndex == 2) {
    return positionedImageHandout(
      title: 'UN UOMO PERDUTO',
      assetPath: 'assets/images/uomo_perduto.jpg',
      isGm: isGm,
      onClose: () => syncService.hideHandout(subMapId),
    );
  }

  // Scene 3: Problemi in Vista + optional Maladûk toggle
  if (sceneIndex == 3) {
    return Center(
      child: handoutCard(
        title: 'PROBLEMI IN VISTA',
        isGm: isGm,
        onClose: () => syncService.hideHandout(subMapId),
        content: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/problemi_in_vista.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (isGm) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.psychology, color: kGold, size: 16),
                  label: Text(
                    room.revealedHandouts['show_maladuk_symbol'] == 1
                        ? 'NASCONDI SIMBOLO'
                        : 'MOSTRA SIMBOLO DI MALADÛK',
                    style: GoogleFonts.cinzel(
                      color: kGold,
                      fontSize: 11,
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  return null; // scenes 1, 4, 5, 6 show no extra handout card
}

// ---------------------------------------------------------------------------
// GM Notes panel content for Sentiero Iniziale
// ---------------------------------------------------------------------------
Widget sentieroGmNotes(int sceneIndex) {
  final bool isMeteorologo = sceneIndex >= 2;

  return gmSidePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gmSectionHeader(isMeteorologo ? 'UNA FRECCIA NERA' : 'VERSO LA VALLE NEBBIOSA'),
        const SizedBox(height: 12),
        gmNarrativeText(
          isMeteorologo
              ? 'Drigel Meteorologo, uno dei servitori umani di Azrahel '
                'Koth, ha cercato per molto tempo la statuetta dell\'imperatore drago e porta con sé una mappa della valle per '
                'semplificare la ricerca. Qualche giorno prima dell\'inizio '
                'dell\'avventura, ha fatto il suo primo ritrovamento: il piedistallo del leggendario artefatto, scoperto in una miniera '
                'abbandonata sotto i Monti Kummer.'
              : 'All\'inizio dell\'avventura, i personaggi sono in viaggio da '
                'giorni attraverso gli alti e aspri Monti Kummer, alla ricerca '
                'di una strada verso la Valle Nebbiosa. Inizia la sessione '
                'leggendo o recitando questo testo:',
        ),
        const SizedBox(height: 16),
        readAloudBox(
          isMeteorologo
              ? 'Ma la sua felicità ha avuto vita breve poiché, nel suo '
                'tragitto verso il villaggio di Orlo e Leanara, è stato localizzato da una pattuglia di goblin. Questi non sanno nulla '
                'di Um-Durman, ma la capotribù Maladûk ha ordinato '
                'loro di cercare una preziosa reliquia divisa in quattro parti '
                'più piccole, cercate da molti, sia viventi che non-morti. Il '
                'pacchetto che Meteorologo stava trasportando ha quindi '
                'attirato la loro attenzione.\n\n'
                'Se i personaggi si avvicinano, notano il pallore e la paura sul '
                'suo volto e che una delle sue cosce è stata perforata da '
                'una spessa freccia nera. Se esaminano la ferita, non serve '
                'nessun tiro di abilità per capire che la freccia è avvelenata. '
                'Delle venature blu-purpuree si espandono dalla ferita e '
                'segnano anche il volto dell\'uomo.\n\n'
                'Improvvisamente, si siede e porge il pacchetto al '
                'personaggio con CAR maggiore, fissandolo con gli occhi '
                'sbarrati e sussurrando con una voce sempre più fioca:\n'
                '"Presto, prendilo! Leanara capirà… messaggio da Mastro '
                'Meteorologo… bisogna trovare tutti e quattro i pezzi… il '
                'segreto dell\'imperatore drago!"'
              : 'L\'antico e stretto passaggio attraversa le montagne come '
                'il solco di un\'ascia. Ripide pendenze coperte di muschio si '
                'estendono verso i picchi innevati che ogni tanto si intravedono '
                'tra gli strati di nuvole. Da qualche parte più avanti '
                'si trova la Valle Nebbiosa, il luogo leggendario dove gli '
                'imperi del passato conservavano tesori e artefatti magici.\n\n'
                'Sono state le voci di vaste ricchezze e segreti arcani '
                'nascosti tra rovine e i racconti di questi tesori che vi '
                'hanno portati qui. E non siete i primi ad essere stati sedotti '
                'da queste tentazioni. Sin da quando gli orchi hanno iniziato '
                'a lasciare l\'area, circa un decennio fa, un flusso sempre '
                'maggiore di coloni ed avventurieri si è fatto strada fino alla '
                'Valle Nebbiosa.\n\n'
                'Voi sapete, però, che la via è pericolosa e piena di rischi. '
                'Le vecchie strade imperiali sono crollate e le montagne '
                'brulicano di insidie. Il Passo di Drakmar, dove ora vi '
                'trovate, ha una nomea particolarmente infame. I nani dei '
                'Monti Kummer hanno avvisato che il ritorno degli umani '
                'ha richiamato in questa zona briganti e bestie fameliche.\n\n'
                'Le vostre paure si avverano non appena udite un lamento '
                'sconcertante. Vedete una figura giacere in mezzo al sentiero '
                'roccioso, a solo una ventina di metri da voi, indossa una '
                'semplice tunica grigia e stringe un pacchetto scuro al petto. '
                'Mentre il lamento diventa un rantolo, vi accorgete che quella '
                'persona è gravemente ferita.',
        ),
      ],
    ),
  );
}
