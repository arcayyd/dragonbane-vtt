// scene_registry.dart
// THE SINGLE SOURCE OF TRUTH for all VTT scene content.
// To add a new location: add a SceneConfig entry to the registry map.
// To add a scene to an existing location: add a SceneData to its scenes list.
// Zero widget code needed for standard scenes.

import 'package:flutter/material.dart';
import 'scene_models.dart';

const Map<String, SceneConfig> sceneRegistry = {
  // -------------------------------------------------------------------------
  // SENTIERO INIZIALE — Passo di Drakmar
  // -------------------------------------------------------------------------
  'sentiero_iniziale': SceneConfig(
    mapId: 'sentiero_iniziale',
    defaultBackground: 'assets/images/passo_handout.jpg',
    defaultOverlay: SceneOverlay.sunlight,
    scenes: [
      // Scene 0: Cinematic opening + intro quote
      SceneData(
        introText: '"Tanto tempo fa, da qualche parte nel passo di Drakar..."',
        gmNotes: GmNotesData(
          sectionTitle: 'VERSO LA VALLE NEBBIOSA',
          narrative:
              "All'inizio dell'avventura, i personaggi sono in viaggio da "
              "giorni attraverso gli alti e aspri Monti Kummer, alla ricerca "
              "di una strada verso la Valle Nebbiosa. Inizia la sessione "
              "leggendo o recitando questo testo:",
          readAloud:
              "L'antico e stretto passaggio attraversa le montagne come "
              "il solco di un'ascia. Ripide pendenze coperte di muschio si "
              "estendono verso i picchi innevati che ogni tanto si intravedono "
              "tra gli strati di nuvole. Da qualche parte più avanti "
              "si trova la Valle Nebbiosa, il luogo leggendario dove gli "
              "imperi del passato conservavano tesori e artefatti magici.\n\n"
              "Sono state le voci di vaste ricchezze e segreti arcani "
              "nascosti tra rovine e i racconti di questi tesori che vi "
              "hanno portati qui. E non siete i primi ad essere stati sedotti "
              "da queste tentazioni. Sin da quando gli orchi hanno iniziato "
              "a lasciare l'area, circa un decennio fa, un flusso sempre "
              "maggiore di coloni ed avventurieri si è fatto strada fino alla "
              "Valle Nebbiosa.\n\n"
              "Voi sapete, però, che la via è pericolosa e piena di rischi. "
              "Le vecchie strade imperiali sono crollate e le montagne "
              "brulicano di insidie. Il Passo di Drakmar, dove ora vi "
              "trovate, ha una nomea particolarmente infame. I nani dei "
              "Monti Kummer hanno avvisato che il ritorno degli umani "
              "ha richiamato in questa zona briganti e bestie fameliche.\n\n"
              "Le vostre paure si avverano non appena udite un lamento "
              "sconcertante. Vedete una figura giacere in mezzo al sentiero "
              "roccioso, a solo una ventina di metri da voi, indossa una "
              "semplice tunica grigia e stringe un pacchetto scuro al petto. "
              "Mentre il lamento diventa un rantolo, vi accorgete che quella "
              "persona è gravemente ferita.",
        ),
      ),

      // Scene 1: (tactical map shown, no handout card)
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'VERSO LA VALLE NEBBIOSA',
          narrative:
              "All'inizio dell'avventura, i personaggi sono in viaggio da "
              "giorni attraverso gli alti e aspri Monti Kummer, alla ricerca "
              "di una strada verso la Valle Nebbiosa. Inizia la sessione "
              "leggendo o recitando questo testo:",
          readAloud:
              "L'antico e stretto passaggio attraversa le montagne come "
              "il solco di un'ascia. Ripide pendenze coperte di muschio si "
              "estendono verso i picchi innevati che ogni tanto si intravedono "
              "tra gli strati di nuvole. Da qualche parte più avanti "
              "si trova la Valle Nebbiosa, il luogo leggendario dove gli "
              "imperi del passato conservavano tesori e artefatti magici.\n\n"
              "Sono state le voci di vaste ricchezze e segreti arcani "
              "nascosti tra rovine e i racconti di questi tesori che vi "
              "hanno portati qui. E non siete i primi ad essere stati sedotti "
              "da queste tentazioni. Sin da quando gli orchi hanno iniziato "
              "a lasciare l'area, circa un decennio fa, un flusso sempre "
              "maggiore di coloni ed avventurieri si è fatto strada fino alla "
              "Valle Nebbiosa.\n\n"
              "Voi sapete, però, che la via è pericolosa e piena di rischi. "
              "Le vecchie strade imperiali sono crollate e le montagne "
              "brulicano di insidie. Il Passo di Drakmar, dove ora vi "
              "trovate, ha una nomea particolarmente infame. I nani dei "
              "Monti Kummer hanno avvisato che il ritorno degli umani "
              "ha richiamato in questa zona briganti e bestie fameliche.\n\n"
              "Le vostre paure si avverano non appena udite un lamento "
              "sconcertante. Vedete una figura giacere in mezzo al sentiero "
              "roccioso, a solo una ventina di metri da voi, indossa una "
              "semplice tunica grigia e stringe un pacchetto scuro al petto. "
              "Mentre il lamento diventa un rantolo, vi accorgete che quella "
              "persona è gravemente ferita.",
        ),
      ),

      // Scene 2: Uomo perduto handout
      SceneData(
        handout: HandoutData(
          title: 'UN UOMO PERDUTO',
          asset: 'assets/images/uomo_perduto.jpg',
          layout: HandoutLayout.leftSide,
          width: 420,
          height: 500,
        ),
        gmNotes: GmNotesData(
          sectionTitle: 'UNA FRECCIA NERA',
          narrative:
              "Drigel Meteorologo, uno dei servitori umani di Azrahel "
              "Koth, ha cercato per molto tempo la statuetta dell'imperatore drago "
              "e porta con sé una mappa della valle per semplificare la ricerca. "
              "Qualche giorno prima dell'inizio dell'avventura, ha fatto il suo "
              "primo ritrovamento: il piedistallo del leggendario artefatto, "
              "scoperto in una miniera abbandonata sotto i Monti Kummer.",
          readAloud:
              "Ma la sua felicità ha avuto vita breve poiché, nel suo "
              "tragitto verso il villaggio di Orlo e Leanara, è stato localizzato "
              "da una pattuglia di goblin. Questi non sanno nulla di Um-Durman, "
              "ma la capotribù Maladûk ha ordinato loro di cercare una preziosa "
              "reliquia divisa in quattro parti più piccole, cercate da molti, "
              "sia viventi che non-morti. Il pacchetto che Meteorologo stava "
              "trasportando ha quindi attirato la loro attenzione.\n\n"
              "Se i personaggi si avvicinano, notano il pallore e la paura sul "
              "suo volto e che una delle sue cosce è stata perforata da "
              "una spessa freccia nera. Se esaminano la ferita, non serve "
              "nessun tiro di abilità per capire che la freccia è avvelenata. "
              "Delle venature blu-purpuree si espandono dalla ferita e "
              "segnano anche il volto dell'uomo.\n\n"
              "Improvvisamente, si siede e porge il pacchetto al "
              "personaggio con CAR maggiore, fissandolo con gli occhi "
              "sbarrati e sussurrando con una voce sempre più fioca:\n"
              '"Presto, prendilo! Leanara capirà… messaggio da Mastro '
              "Meteorologo… bisogna trovare tutti e quattro i pezzi… il "
              'segreto dell\'imperatore drago!"',
        ),
      ),

      // Scene 3: Problemi in vista + Maladûk toggle
      SceneData(
        handout: HandoutData(
          title: 'PROBLEMI IN VISTA',
          asset: 'assets/images/problemi_in_vista.jpg',
          layout: HandoutLayout.centered,
        ),
        gmToggle: GmToggleData(
          handoutKey: 'show_maladuk_symbol',
          showLabel: 'MOSTRA SIMBOLO DI MALADÛK',
          hideLabel: 'NASCONDI SIMBOLO',
        ),
        gmNotes: GmNotesData(
          sectionTitle: 'UNA FRECCIA NERA',
          narrative:
              "Drigel Meteorologo, uno dei servitori umani di Azrahel "
              "Koth, ha cercato per molto tempo la statuetta dell'imperatore drago "
              "e porta con sé una mappa della valle per semplificare la ricerca. "
              "Qualche giorno prima dell'inizio dell'avventura, ha fatto il suo "
              "primo ritrovamento: il piedistallo del leggendario artefatto, "
              "scoperto in una miniera abbandonata sotto i Monti Kummer.",
          readAloud:
              "Ma la sua felicità ha avuto vita breve poiché, nel suo "
              "tragitto verso il villaggio di Orlo e Leanara, è stato localizzato "
              "da una pattuglia di goblin. Questi non sanno nulla di Um-Durman, "
              "ma la capotribù Maladûk ha ordinato loro di cercare una preziosa "
              "reliquia divisa in quattro parti più piccole, cercate da molti, "
              "sia viventi che non-morti. Il pacchetto che Meteorologo stava "
              "trasportando ha quindi attirato la loro attenzione.",
        ),
      ),

      // Scenes 4-6: tactical map mode (show interactive grid)
      SceneData(showCinematic: false),
      SceneData(showCinematic: false),
      SceneData(showCinematic: false),
    ],
  ),

  // -------------------------------------------------------------------------
  // ORLO — Villaggio di Orlo (two IDs map to same config)
  // -------------------------------------------------------------------------
  'outskirt_village': SceneConfig(
    mapId: 'outskirt_village',
    defaultBackground: 'assets/images/orlo_cinematic.jpg',
    defaultOverlay: SceneOverlay.smoke,
    scenes: [
      // Scene 0: Sfondo cinematico con fumo + note arrivo GM (nessun handout ai giocatori)
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'ARRIVO A ORLO',
          narrative:
              "Dopo la scena di apertura, i personaggi si dirigono "
              "direttamente a Orlo, impiegando circa un giorno di cammino.\n\n"
              "La vegetazione si infittisce diventando una densa foresta mentre "
              "i personaggi scendono verso la Valle Nebbiosa. Fortunatamente, "
              "possono seguire con facilità i resti della stessa vecchia strada "
              "che porta fino alle montagne e attraversa la foresta.\n\n"
              "Qua e là, spuntano dal terreno pietre miliari segnate "
              "dalle intemperie, alcune delle quali decorate con antiche "
              "corone stilizzate. A pochi chilometri da Orlo, la foresta si "
              "dirada, aprendosi su campi coltivati. Presto, i personaggi si "
              "trovano a sguazzare lungo i solchi fangosi dei carri.\n\n"
              "Leggi o recita il seguente testo ai giocatori appena "
              "giungono a Orlo:",
          readAloud:
              "Le tracce dei carri lasciano il posto a una strada lastricata "
              "che taglia in due gli alti campi di grano. Innumerevoli "
              "profumi pervadono i vostri sensi: letame, fumo e verdure "
              "marce, ma anche pane appena sfornato e carne grigliata. "
              "La strada conduce a un insediamento circondato da "
              "una palizzata, con tante piccole case dai camini fumanti, "
              "visibili da oltre i pali aguzzi.\n\n"
              "Il cancello del villaggio è chiuso e fiancheggiato da "
              "due basse e resistenti torri in pietra con merlature e tetti "
              "di legno appuntiti. Mentre vi avvicinate, sentite la voce "
              "severa di un uomo che vi urla da una delle torri:\n\n"
              '"Fermi, stranieri! Dite i vostri nomi e il motivo del '
              "vostro arrivo, o giratevi e tornate nella foresta. Questo è "
              'un luogo di pace e decoro."',
          bodyText:
              "La torre è il luogo #2A e l'uomo è Hardy (pag. 19). Vuole "
              "sapere i nomi dei personaggi e il motivo del loro arrivo "
              "a Orlo. Se il gruppo risponde alle domande e afferma di "
              "venire in pace, il cancello si apre scricchiolando. Se i "
              "personaggi provano a porgli delle domande, Hardy li manda "
              "fermamente a cercare Vagnhild alla locanda Tre Cervi.",
        ),
      ),

      // Scene 1: Handout Hardy (ritratto visibile ai giocatori) + statblock GM
      SceneData(
        handout: HandoutData(
          title: 'HARDY',
          asset: 'assets/images/hardy_portrait.jpg',
          layout: HandoutLayout.centered,
        ),
        gmStatBlock: StatBlockData(
          name: 'HARDY',
          description:
              "Hardy è un veterano di guerra temprato dalle battaglie. Ha una "
              "quarantina d'anni, capelli fino alle spalle e il naso rotto. "
              "È forte e taciturno, ma ha un lato emotivo che emerge dopo qualche "
              "boccale di idromele alla locanda.\n\n"
              "Qualche volta esce dal villaggio per scacciare goblin, banditi e "
              "altri potenziali attaccabrighe. Durante queste spedizioni è "
              "accompagnato spesso dal figlio di Mastro Ulvar del negozio di Orlo "
              "(#5), Jory, che Hardy considera come suo successore.",
          stats: [
            StatEntry('Movimento', '12'),
            StatEntry('Danno Bonus FOR', '+D4'),
            StatEntry('PF', '16'),
            StatEntry('PV', '14'),
            StatEntry('Armatura', 'Cuoio borchiato e celata (3)'),
          ],
          skills: [
            StatEntry('Consapevolezza', '14'),
            StatEntry('Guarire', '8'),
            StatEntry('Rissa', '14'),
            StatEntry('Sfuggire', '12'),
          ],
          abilities: ['Difensivo', 'Veterano'],
          weapons: [
            WeaponEntry('Spadone', '14', '2D6'),
            WeaponEntry('Balestra pesante', '12', '2D8'),
            WeaponEntry('Scudo grande', '—', '—'),
          ],
        ),
      ),

      // Scene 2: Mappa interattiva del villaggio di Orlo con pin cliccabili
      SceneData(
        subMapAsset: 'assets/images/orlo_village_map_v2.jpg',
        mapPins: [
          MapPinData(
            label: '1',
            name: 'Cancello Sud (Ingresso Principale)',
            description:
                'Il cancello principale di Orlo, sorvegliato da Hardy. '
                'È qui che i personaggi sono stati fermati al loro arrivo. '
                'La porta è robusta, in legno rinforzato con barre di ferro.',
            xFraction: 0.50,
            yFraction: 0.84,
          ),
          MapPinData(
            label: '2A',
            name: 'Torre di Guardia Sud-Est',
            description:
                'La torre di guardia al cancello principale, dove Hardy '
                'si trovava quando ha fermato i personaggi. '
                'Bassa e resistente, in pietra, con merlature e tetto in legno appuntito.',
            xFraction: 0.76,
            yFraction: 0.59,
          ),
          MapPinData(
            label: '2B',
            name: 'Torrione del Cancello Nord',
            description:
                'Il torrione più grande, vicino al cancello nord. '
                'Da qui si domina tutta la valle. In tempi normali ospita una sentinella.',
            xFraction: 0.56,
            yFraction: 0.18,
          ),
          MapPinData(
            label: '3',
            name: 'Statua',
            description:
                'Una statua in pietra al centro del villaggio, consumata dalle intemperie. '
                'Raffigura un antico sovrano o divinità locale. '
                'Gli abitanti si raccolgono qui per le festività.',
            xFraction: 0.45,
            yFraction: 0.29,
          ),
          MapPinData(
            label: '4',
            name: 'Casa del Sindaco / Vagnhild',
            description:
                "L'edificio più grande e curato del villaggio. "
                "Qui risiede Vagnhild, la capovillaggio. "
                "I personaggi sono stati mandati da Hardy a cercarla qui.",
            xFraction: 0.41,
            yFraction: 0.36,
          ),
          MapPinData(
            label: '5',
            name: 'Negozio di Mastro Ulvar',
            description:
                'Il negozio generale del villaggio, gestito da Mastro Ulvar. '
                'Vende provviste, attrezzi e oggetti di prima necessità. '
                'Suo figlio Jory è il protetto di Hardy.',
            xFraction: 0.38,
            yFraction: 0.23,
          ),
          MapPinData(
            label: '6',
            name: 'Forgia / Fabbro',
            description:
                'La fucina del fabbro del villaggio. '
                'Si sente il suono delle martellate e si vede il fumo del mantice. '
                'Produce ferramenti, armi e strumenti agricoli.',
            xFraction: 0.33,
            yFraction: 0.29,
          ),
          MapPinData(
            label: '7',
            name: 'Locanda Tre Cervi',
            description:
                'La locanda del villaggio, gestita da Vagnhild (o dalla sua famiglia). '
                'Offre cibo, bevande e alloggio. '
                'È il centro sociale di Orlo, dove si riuniscono gli abitanti la sera.',
            xFraction: 0.47,
            yFraction: 0.66,
          ),
          MapPinData(
            label: '8',
            name: 'Pozzo / Santuario',
            description:
                "Il pozzo comune del villaggio, o piccolo santuario. "
                "Punto di incontro quotidiano per gli abitanti. "
                "L'acqua proviene da una sorgente sotterranea.",
            xFraction: 0.60,
            yFraction: 0.41,
          ),
          MapPinData(
            label: '9',
            name: 'Formazioni Rocciose / Grotta',
            description:
                "Le rocce cristalline che emergono dal terreno al centro di Orlo. "
                "Sono un fenomeno naturale inspiegabile per gli abitanti. "
                "Nascondono una grotta che potrebbe essere rilevante per l'avventura.",
            xFraction: 0.47,
            yFraction: 0.47,
          ),
          MapPinData(
            label: '10',
            name: 'Edificio Misterioso',
            description:
                "Un piccolo edificio in pietra tra le formazioni rocciose. "
                "Gli abitanti lo evitano, ritenendolo sfortunato. "
                "Potrebbe nascondere segreti legati all'imperatore drago.",
            xFraction: 0.54,
            yFraction: 0.53,
          ),
          MapPinData(
            label: '1',
            name: 'Edificio Principale Est (Locanda / Magazzino)',
            description:
                'Il grande edificio sul lato est del villaggio. '
                'Potrebbe essere un magazzino, una seconda locanda o la residenza '
                'di un personaggio importante.',
            xFraction: 0.84,
            yFraction: 0.38,
          ),
        ],
      ),
    ],
  ),

  // alias for orlo
  'villaggio_orlo': SceneConfig(
    mapId: 'villaggio_orlo',
    defaultBackground: 'assets/images/orlo_cinematic.jpg',
    defaultOverlay: SceneOverlay.smoke,
    scenes: [
      // Scene 0: Sfondo cinematico con fumo (nessun handout ai giocatori)
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'ARRIVO A ORLO',
          narrative:
              "Dopo la scena di apertura, i personaggi si dirigono "
              "direttamente a Orlo, impiegando circa un giorno di cammino.\n\n"
              "La vegetazione si infittisce diventando una densa foresta mentre "
              "i personaggi scendono verso la Valle Nebbiosa. Fortunatamente, "
              "possono seguire con facilità i resti della stessa vecchia strada "
              "che porta fino alle montagne e attraversa la foresta.\n\n"
              "Qua e là, spuntano dal terreno pietre miliari segnate "
              "dalle intemperie, alcune delle quali decorate con antiche "
              "corone stilizzate. A pochi chilometri da Orlo, la foresta si "
              "dirada, aprendosi su campi coltivati. Presto, i personaggi si "
              "trovano a sguazzare lungo i solchi fangosi dei carri.\n\n"
              "Leggi o recita il seguente testo ai giocatori appena "
              "giungono a Orlo:",
          readAloud:
              "Le tracce dei carri lasciano il posto a una strada lastricata "
              "che taglia in due gli alti campi di grano. Innumerevoli "
              "profumi pervadono i vostri sensi: letame, fumo e verdure "
              "marce, ma anche pane appena sfornato e carne grigliata. "
              "La strada conduce a un insediamento circondato da "
              "una palizzata, con tante piccole case dai camini fumanti, "
              "visibili da oltre i pali aguzzi.\n\n"
              "Il cancello del villaggio è chiuso e fiancheggiato da "
              "due basse e resistenti torri in pietra con merlature e tetti "
              "di legno appuntiti. Mentre vi avvicinate, sentite la voce "
              "severa di un uomo che vi urla da una delle torri:\n\n"
              '"Fermi, stranieri! Dite i vostri nomi e il motivo del '
              "vostro arrivo, o giratevi e tornate nella foresta. Questo è "
              'un luogo di pace e decoro."',
          bodyText:
              "La torre è il luogo #2A e l'uomo è Hardy (pag. 19). Vuole "
              "sapere i nomi dei personaggi e il motivo del loro arrivo "
              "a Orlo. Se il gruppo risponde alle domande e afferma di "
              "venire in pace, il cancello si apre scricchiolando. Se i "
              "personaggi provano a porgli delle domande, Hardy li manda "
              "fermamente a cercare Vagnhild alla locanda Tre Cervi.",
        ),
      ),
      // Scene 1: Handout Hardy + statblock GM
      SceneData(
        handout: HandoutData(
          title: 'HARDY',
          asset: 'assets/images/hardy_portrait.jpg',
          layout: HandoutLayout.centered,
        ),
        gmStatBlock: StatBlockData(
          name: 'HARDY',
          description:
              "Hardy è un veterano di guerra temprato dalle battaglie. Ha una "
              "quarantina d'anni, capelli fino alle spalle e il naso rotto. "
              "È forte e taciturno, ma ha un lato emotivo che emerge dopo qualche "
              "boccale di idromele alla locanda.\n\n"
              "Qualche volta esce dal villaggio per scacciare goblin, banditi e "
              "altri potenziali attaccabrighe. Durante queste spedizioni è "
              "accompagnato spesso dal figlio di Mastro Ulvar del negozio di Orlo "
              "(#5), Jory, che Hardy considera come suo successore.",
          stats: [
            StatEntry('Movimento', '12'),
            StatEntry('Danno Bonus FOR', '+D4'),
            StatEntry('PF', '16'),
            StatEntry('PV', '14'),
            StatEntry('Armatura', 'Cuoio borchiato e celata (3)'),
          ],
          skills: [
            StatEntry('Consapevolezza', '14'),
            StatEntry('Guarire', '8'),
            StatEntry('Rissa', '14'),
            StatEntry('Sfuggire', '12'),
          ],
          abilities: ['Difensivo', 'Veterano'],
          weapons: [
            WeaponEntry('Spadone', '14', '2D6'),
            WeaponEntry('Balestra pesante', '12', '2D8'),
            WeaponEntry('Scudo grande', '—', '—'),
          ],
        ),
      ),
      // Scene 2: Mappa interattiva del villaggio di Orlo con pin cliccabili
      SceneData(
        subMapAsset: 'assets/images/orlo_village_map_v2.jpg',
        mapPins: [
          MapPinData(label: '1', name: 'Cancello Sud', description: 'Il cancello principale di Orlo.', xFraction: 0.50, yFraction: 0.84),
          MapPinData(label: '2A', name: 'Torre Guardia Sud-Est', description: 'La torre dove si trovava Hardy.', xFraction: 0.76, yFraction: 0.59),
          MapPinData(label: '2B', name: 'Torrione Nord', description: 'Il torrione del cancello nord.', xFraction: 0.56, yFraction: 0.18),
          MapPinData(label: '3', name: 'Piazza del Villaggio', description: 'La statua dell\'Imperatore Drago al centro del villaggio.', xFraction: 0.45, yFraction: 0.29),
          MapPinData(label: '4', name: 'Locanda Ai Tre Cervi', description: 'La locanda del villaggio.', xFraction: 0.41, yFraction: 0.36),
          MapPinData(label: '5', name: 'Negozio di Mastro Ulvar', description: 'Il negozio generale del villaggio.', xFraction: 0.38, yFraction: 0.23),
          MapPinData(label: '6', name: 'Fucina', description: 'La fucina di Okald e Badinor.', xFraction: 0.33, yFraction: 0.29),
          MapPinData(label: '7', name: 'Casa di Vagnhild', description: 'La casa della capovillaggio Vagnhild.', xFraction: 0.47, yFraction: 0.66),
          MapPinData(label: '8', name: 'Pozzo', description: 'Il pozzo comune.', xFraction: 0.60, yFraction: 0.41),
          MapPinData(label: '9', name: 'Formazioni Rocciose', description: 'Rocce cristalline e grotta.', xFraction: 0.47, yFraction: 0.47),
          MapPinData(label: '10', name: 'Edificio Misterioso', description: 'Edificio evitato dagli abitanti.', xFraction: 0.54, yFraction: 0.53),
        ],
      ),
    ],
  ),

  'locanda_tre_cervi': SceneConfig(
    mapId: 'locanda_tre_cervi',
    defaultBackground: 'assets/images/tre_cervi_inn.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'LOCANDA AI TRE CERVI',
          narrative:
              "Un imponente edificio a due piani con un enorme tetto in "
              "paglia e muri a graticcio. Fuori dalla porta è appeso un "
              "cartello rosso con scritto 'I Tre Cervi – Birra, letti e cibo "
              "a prezzi da sogno'. Voci allegre si sentono fino in strada, "
              "insieme al profumo di cinghiale arrosto.\n\n"
              "✦ Sala Comune: I Tre Cervi è la bettola del villaggio. "
              "Dalla mattina presto fino a ben dopo mezzanotte ci sono "
              "D12+1 abitanti e visitatori seduti nella sala comune, che "
              "mangiano, bevono, spettegolano e scaldano le giunture "
              "davanti al grande focolare. Deliziosi stufati di carne e "
              "birra artigianale o idromele sono serviti a prezzi normali "
              "da locanda (Manuale Base, pag. 80).\n\n"
              "✦ Vagnhild: Come entrano, i personaggi sono accolti "
              "da Vagnhild. Anche se brontola autorevolmente, è "
              "piuttosto allegra e amichevole e offre a ciascuno di loro "
              "un boccale di idromele della casa. Si offre di rispondere alle "
              "domande riguardanti la zona e può riferire pettegolezzi sui "
              "luoghi d'avventura nella Valle Nebbiosa (pag. 17). Racconta anche questo:\n"
              "– Recentemente, grandi pipistrelli sono stati avvistati "
              "sopra i tetti. Hardy ha cercato di abbatterne qualcuno, ma senza successo.\n"
              "– Nell'area del tempio si è insediato un mistico di "
              "nome Dranath, una fonte infinita di conoscenza sul "
              "passato e un abile guaritore.",
          readAloud:
              "Un imponente edificio a due piani con un enorme tetto in "
              "paglia e muri a graticcio. Fuori dalla porta è appeso un "
              "cartello rosso con scritto 'I Tre Cervi – Birra, letti e cibo "
              "a prezzi da sogno'. Voci allegre si sentono fino in strada, "
              "insieme al profumo di cinghiale arrosto.",
        ),
      ),
    ],
  ),

  'locanda_tre_cervi_interno': SceneConfig(
    mapId: 'locanda_tre_cervi_interno',
    defaultBackground: 'assets/images/tre_cervi_interno.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'SALA COMUNE',
          narrative:
              "La sala comune dei Tre Cervi è calda e caotica.\n\n"
              "✦ Sala Comune: I Tre Cervi è la bettola del villaggio. "
              "Dalla mattina presto fino a ben dopo mezzanotte ci sono "
              "D12+1 abitanti e visitatori seduti nella sala comune, che "
              "mangiano, bevono, spettegolano e scaldano le giunture "
              "davanti al grande focolare. Deliziosi stufati di carne e "
              "birra artigianale o idromele sono serviti a prezzi normali "
              "da locanda (Manuale Base, pag. 80).\n\n"
              "✦ Vagnhild: Come entrano, i personaggi sono accolti "
              "da Vagnhild. Anche se brontola autorevolmente, è "
              "piuttosto allegra e amichevole e offre a ciascuno di loro "
              "un boccale di idromele della casa. Si offre di rispondere alle "
              "domande riguardanti la zona e può riferire pettegolezzi sui "
              "luoghi d'avventura nella Valle Nebbiosa (pag. 17). Racconta anche questo:\n"
              "– Recentemente, grandi pipistrelli sono stati avvistati "
              "sopra i tetti. Hardy ha cercato di abbatterne qualcuno, ma senza successo.\n"
              "– Nell'area del tempio si è insediato un mistico di "
              "nome Dranath, una fonte infinita di conoscenza sul "
              "passato e un abile guaritore.",
          readAloud:
              "Un fuoco scoppietta nel grande camino in pietra, mentre un maialino "
              "gira sullo spiedo diffondendo un profumo invitante. Clienti allegri "
              "bevono ai tavoli di legno e parlano ad alta voce.",
        ),
      ),
    ],
  ),

  'locanda_tre_cervi_stanze': SceneConfig(
    mapId: 'locanda_tre_cervi_stanze',
    defaultBackground: 'assets/images/tre_cervi_stanze.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: 'LE STANZE DELLA LOCANDA',
          narrative:
              "Le camere da letto al piano superiore della locanda.\n\n"
              "✦ Riposo: Le stanze sono pulite ed economiche. Qui i personaggi "
              "possono trascorrere una notte sicura per recuperare Punti Ferita "
              "e Punti Volontà secondo le regole del riposo lungo (pag. 48).\n\n"
              "✦ Dettagli: Due comodi letti di legno con coperte di lana grezza, "
              "un baule per gli effetti personali e uno stemma intagliato "
              "con la testa di un cervo appeso alla parete.",
          readAloud:
              "Le camere al piano superiore sono silenziose e accoglienti, "
              "riscaldate dalla calda luce di una candela. Il profumo del legno "
              "e della lana vi accoglie per una notte di meritato riposo.",
        ),
      ),
    ],
  ),

  'orlo_piazza': SceneConfig(
    mapId: 'orlo_piazza',
    defaultBackground: 'assets/images/orlo_piazza.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: "3. PIAZZA DEL VILLAGGIO",
          narrative:
              "La locanda, la fucina e il negozio si affacciano su uno "
              "spazio aperto dove una statua rovinata si innalza dal terreno. È una strana reliquia di un'era passata, che sembra "
              "raffigurare un guerriero con un'antica armatura.\n\n"
              "✦ L'Imperatore Drago: Il tempo non è stato gentile con "
              "la statua. Ha perso entrambe le braccia, ma si riconosce "
              "ancora un elmo con una corona simile a delle corna. "
              "Superando un tiro di MITI E LEGGENDE, i personaggi "
              "riconoscono l'imperatore drago Eledain, che si dice "
              "abbia governato questa parte del mondo secoli prima. "
              "Notano anche una notevole somiglianza tra la statua e i "
              "quattro pezzi della statuetta sulla mappa di Meteorologo.",
        ),
      ),
    ],
  ),

  'orlo_fucina': SceneConfig(
    mapId: 'orlo_fucina',
    defaultBackground: 'assets/images/orlo_fucina.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: "6. FUCINA",
          narrative:
              "Un grande edificio di tronchi con una facciata aperta. "
              "Attraverso il fumo si può scorgere il bagliore di un focolare "
              "e, dagli uncini nel soffitto, si vede pendere qualsiasi tipo "
              "di arma e pezzo di armatura. Pesanti martelli sbattono, "
              "mentre un melodico brontolio nanico risuona fino alla "
              "piazza del villaggio.\n\n"
              "✦ I Gemelli: La fucina è gestita da Okald e Badinor, due "
              "nani gemelli dai Monti Kummer che hanno scelto di "
              "vivere tra gli avventurieri di Orlo dopo una difficile "
              "contesa per l'eredità. L'estroversa Okald si occupa dei "
              "clienti mentre Badinor preferisce faticare nella fucina "
              "con la sola compagnia del suo martello.\n\n"
              "✦ Armi: Tutte le armi, scudi e armature Comuni e Non "
              "comuni elencati nel capitolo 6 del Manuale Base "
              "possono essere acquistati qui. Gli oggetti Rari possono "
              "essere ordinati e sono pronti in una settimana. I gemelli "
              "possono anche riparare armi e armature danneggiate, "
              "solitamente per metà del loro prezzo d'acquisto.",
        ),
      ),
    ],
  ),
  'orlo_troll': SceneConfig(
    mapId: 'orlo_troll',
    defaultBackground: 'assets/images/orlo_troll.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: "Troll nel Fienile",
          narrative:
              "Il caos esplode nel villaggio e delle voci gridano: \"C'è un troll nel fienile del vecchio Mifaldor!\"\n\n"
              "Subito dopo, il troll è di fronte ai personaggi. È un'enorme creatura che annusa l'aria con le grosse narici. "
              "A meno che non agisca in fretta, il gruppo sarà coinvolto in un combattimento, ma il troll può anche essere calmato "
              "superando un tiro di PERSUADERE.",
        ),
      ),
    ],
  ),
  'orlo_torre': SceneConfig(
    mapId: 'orlo_torre',
    defaultBackground: 'assets/images/orlo_torre.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        gmNotes: GmNotesData(
          sectionTitle: "TORRE DI ZIRAZZIA",
          narrative:
              "Una torre antica e solitaria si erge tra le colline e i boschi attorno ad Orlo. "
              "Attorno ad essa alita un'aria misteriosa e inquietante.",
        ),
      ),
    ],
  ),
  'guglia_troll': SceneConfig(
    mapId: 'guglia_troll',
    defaultBackground: 'assets/images/guglia_troll_intro.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      // Scene 0: 1. CANCELLO ROSSO
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_intro.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GUGLIA DEL TROLL - 1. CANCELLO ROSSO",
          narrative:
              "Durante il regno di Eledain, gli stregoni si recavano alla Guglia del Troll per osservare il cielo notturno e trovare stelle cadenti.\n\n"
              "Dalla pietra stellare ricavavano metalli resistenti e bellissimi gioielli luccicanti che venivano poi usati per diversi scopi magici.\n\n"
              "Quando l’impero draconico fu distrutto dai conflicts interni, sotto la torre fu costruita una camera blindata per proteggere degli artefatti preziosi. Con il crollo dell’impero, però, la torre cadde in rovina e fu infine dimenticata. Cespugli di rose magici erano l’unica cosa viva e prospera in quel luogo.\n\n"
              "Alcuni anni fa, una troll di nome Harga si è stabilita nella torre per studiare erbe medicinali, veleni e pozioni. Sfortunatamente, la torre era già abitata da qualcun altro, uno stormo di arpie furiose che avevano fatto il nido sul tetto. Da allora, la troll e le arpie sono nemiche giurate.\n\n"
              "Dopo diversi furti sfacciati, Harga si è barricata nella torre e ha preparato qualche trappola per spaventare gli intrusi.",
          readAloud:
              "1. CANCELLO ROSSO\n"
              "Davanti a voi si erge una torre fatiscente di un’epoca passata. Le rovine sono avvolte in un manto di rose rosse e nere con spine appuntite e un dolce profumo che annebbia i sensi. L’ingresso è bloccato da un imponente cancello in legno di quercia rossa. La torre ha qualche finestra, ma nessuna al piano terra.",
          bodyText:
              "✦ Le Rose: Le rose fioriscono tutto l’anno, nutrite dall’energia magica. I personaggi devono superare un tiro di COS a ogni round in cui sono entro un metro dalle rose o diventare Disorientati. L’effetto può essere evitato trattenendo il respiro (Manuale Base, pag. 53).\n\n"
              "✦ Occupanti: Se i personaggi guardano verso la cima della torre e superano un tiro di CONSAPEVOLEZZA, notano dei movimenti sul tetto e dietro le finestre del laboratorio (#5).\n\n"
              "✦ NORD: La porta verso il salone della torre (#2) è sbarrata dall’interno (40 PF, valore di armatura 12).\n\n"
              "✦ SUD: Superando un tiro di ACROBAZIA, un personaggio può arrampicarsi sui cespugli di rose fino alla Cucina (#4) al primo piano. Chi si arrampica è esposto al profumo delle rose e subisce D6 danni perforanti dalle spine. Non è possibile salire più in alto del primo piano.",
        ),
        directions: [
          DirectionButtonData(
            label: "NORD: Salone della Torre (#2)",
            targetSceneIndex: 1,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "SUD: Cucina (#4)",
            targetSceneIndex: 2,
            icon: Icons.arrow_downward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 7,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 1: 2. SALONE DELLA TORRE
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_salone.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "2. SALONE",
          readAloud:
              "2. SALONE\n"
              "Il salone è pieno di macerie e detriti dai muri e dai piani superiori crollati. Grosse mosche ronzano pigramente nell’aria umida e immobile.",
          bodyText:
              "✦ Ambrosius il Rospo: Il rospo da guardia di Harga, Ambrosius, si nasconde nella sua tana tra le pietre dell’angolo ovest e attacca i personaggi se esaminano le macerie.\n\n"
              "✦ Evento Casuale: Tira un D6 sulla tabella in alto per ogni intervallo completo passato qui.\n\n"
              "✦ NORD: Scale verso l’Abitazione Abbandonata (#3) al piano superiore.\n\n"
              "✦ SUD: La porta della torre (#1) è sbarrata, ma è facile da aprire dall’interno.\n\n"
              "✦ OVEST: Sotto la tana del rospo nell’angolo ovest c’è un portello che conduce nella cripta della torre. I personaggi possono trovarlo se cercano nel posto esatto oppure se ispezionano la stanza e superando un tiro di LOCALIZZARE. Sul portello ci sono un simbolo decorato (MITI E LEGGENDE: il simbolo del drago di Eledain) e un anello di ferro per aprirlo, che richiede un tiro di FOR con un castigo. Il portello può anche essere sfondato (20 PF, valore di armatura 10). Sotto di esso c’è una breve scala a chiocciola che scende fino alla Porta di Ferro (#7).",
        ),
        directions: [
          DirectionButtonData(
            label: "NORD: Abitazione Abbandonata (#3)",
            targetSceneIndex: 3,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "SUD: Cancello Rosso (#1)",
            targetSceneIndex: 0,
            icon: Icons.arrow_downward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "mostra ambrosius",
            targetSceneIndex: 1,
            icon: Icons.bug_report,
          ),
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 7,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 2: 4. CUCINA
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_cucina.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "4. CUCINA",
          readAloud:
              "4. CUCINA\n"
              "Quella che probabilmente un tempo era una cucina è stata ripulita da tutti gli utensili. Una finestra aperta è coperta di cespugli di rose rosse, e un dolce olezzo invade le vostre narici.",
          bodyText:
              "✦ Evento Casuale: Tira un D6 sulla tabella di pag. 68 per ogni intervallo completo passato qui.\n\n"
              "✦ NORD: Porta socchiusa verso l’Abitazione Abbandonata (#3). In cima alla porta c’è un secchio (a meno che la trappola nella stanza #3 non sia stata fatta scattare).\n\n"
              "✦ FINESTRA (SUD): Discesa lungo i cespugli di rose fino al Cancello Rosso (#1).",
        ),
        directions: [
          DirectionButtonData(
            label: "NORD: Abitazione Abbandonata (#3)",
            targetSceneIndex: 3,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "SUD: Discesa al Cancello Rosso (#1)",
            targetSceneIndex: 0,
            icon: Icons.arrow_downward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 8,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 3: 3. ABITAZIONE ABBANDONATA
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_abitazione.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "3. ABITAZIONE ABBANDONATA",
          readAloud:
              "3. ABITAZIONE ABBANDONATA\n"
              "La stanza è dominata da un enorme camino e da un antico tavolo in legno di quercia rossa, sopra il quale ci sono quattro brocche di argilla e due piatti di legno. Il pavimento è coperto di mobili rotti e altre macerie. Ci sono quattro porte, una per ogni direzione.",
          bodyText:
              "✦ Rastrello: Harga ha nascosto un rastrello tra i detriti, sperando che qualcuno ci cammini sopra. Il primo personaggio che entra nella stanza fa scattare la trappola e deve tirare su SFUGGIRE per non venire colpito e subire D6 danni contundenti. I personaggi notano il rastrello se si muovono con cautela e superano un tiro di LOCALIZZARE.\n\n"
              "✦ Scheletrappola: La tavola apparecchiata è una trappola. Un filo molto sottile è teso tra le brocche e i piatti e un sacco appeso al soffitto. Se i personaggi toccano questi oggetti, uno scheletro armato di scimitarra e scudo cade giù. Tutti nella stanza devono tirare su VOL per resistere alla paura. Lo scheletro è tenuto insieme da dei fili ed è completamente innocuo, ma fai pescare comunque l’iniziativa ai personaggi per vedere come reagiscono alla minaccia. Lo scheletro non fa nulla. La trappola può essere evitata se i personaggi esaminano il tavolo o il soffitto e superano un tiro di LOCALIZZARE.\n\n"
              "✦ Evento Casuale: Tira un D6 sulla tabella in alto per ogni intervallo completo passato qui.\n\n"
              "✦ NORD: Le scale salgono verso il Laboratorio di Harga (#5).\n\n"
              "✦ EST: Porta verso una latrina. Il fetore è palpabile, serve eseguire un tiro di COS per non diventare Disorientati.\n\n"
              "✦ SUD: Porta socchiusa verso la Cucina (#4). Un secchio si svuota addosso alla persona che la apre. È pieno di polvere pruriginosa creata da Harga, che rende la vittima Arrabbiata. La trappola può essere evitata solo se la prima persona che vuole entrare nella cucina esamina attivamente la porta e supera un tiro di LOCALIZZARE prima di aprirla.\n\n"
              "✦ OVEST: Porta verso una semplice camera da letto, ora vuota.",
        ),
        directions: [
          DirectionButtonData(
            label: "NORD: Laboratorio (#5)",
            targetSceneIndex: 4,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "SUD: Cucina (#4)",
            targetSceneIndex: 2,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "EST: Latrina",
            targetSceneIndex: 3,
            icon: Icons.arrow_forward,
          ),
          DirectionButtonData(
            label: "OVEST: Camera da Letto",
            targetSceneIndex: 3,
            icon: Icons.arrow_back,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 8,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 4: 5. LABORATORIO DI HARGA
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_laboratorio.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "5. LABORATORIO DI HARGA",
          readAloud:
              "5. LABORATORIO DI HARGA\n"
              "La stanza è piena zeppa di bottiglie, ampolle, pentole, brocche, mortai e pestelli, mestoli, erbe essiccate e becher di vetro contenenti parti di vari mostri: tutto ciò che vi può servire per creare strane pozioni. Fumo da un fuoco al centro della stanza sale fino alle molte crepe nel soffitto. In alto si può vedere il cielo attraverso rose rosse e nere.",
          bodyText:
              "✦ Harga: Nel corso di molti anni, la troll si è appropriata dell’antico laboratorio, che ora riflette la sua personalità. Quando i personaggi arrivano, si spaventa e si nasconde tra le macerie. Se restano nella stanza per un po’ di tempo e toccano in giro, si fa vedere dicendo: “Cosa fate in casa mia? Andatevene o vi farò sparire per sempre!”\n\n"
              "✦ Pozioni e Altri Oggetti: Tra le bottiglie, i personaggi possono trovare cinque dosi di mistura di erbe (favore ai tiri per resistere alle malattie), tre dosi di ciascun veleno (paralizzante, letale e soporifero, tutti di potenza 12), quattro dosi di pozione di cura (guarisce 2D6 PF), due dosi di una pozione che ha lo stesso effetto dell’incantesimo LEVITARE (livello di potere 1) su chi la beve, una clessidra, alcune pergamene, un calamo, cinque razioni e il grimorio di Harga, con tutte le sue magie. I personaggi possono trovare tutto questo frugando nel laboratorio per un intervallo.\n\n"
              "✦ NORD / GIÙ: Le scale scendono fino all’Abitazione Abbandonata (#3).\n\n"
              "✦ SU: Buco nel soffitto verso il Nido delle Arpie (#6).",
        ),
        directions: [
          DirectionButtonData(
            label: "GIÙ: Abitazione Abbandonata (#3)",
            targetSceneIndex: 3,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "SU: Nido delle Arpie (#6)",
            targetSceneIndex: 5,
            icon: Icons.arrow_upward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Mostra harga",
            targetSceneIndex: 4,
            icon: Icons.face,
          ),
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 9,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 5: 6. NIDO DELLE ARPIE
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_arpie.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "6. NIDO DELLE ARPIE",
          readAloud:
              "6. NIDO DELLE ARPIE\n"
              "La cima della torre è a cielo aperto. Il dolce odore delle rose è quasi travolgente. Enormi cespugli di rose rosse e nere sono aggrappati alle pareti. Al centro, vedete una bassa pozza di acqua piovana sporca con delle grandi piume scure che galleggiano in superficie.",
          bodyText:
              "✦ Rose: È impossibile evitare il profumo delle rose. I personaggi devono superare un tiro di COS a ogni round o diventare Disorientati. L’effetto può essere evitato trattenendo il respiro (Manuale Base, pag. 53).\n\n"
              "✦ Arpie: Le tre arpie Cardo, Aculeo e Spina sono nascoste tra i cespugli di rose, pronte ad assalire chiunque salga qui.\n\n"
              "✦ Nido: Le tre arpie hanno fatto il loro nido dentro i cespugli di rose. Per trovarlo serve superare un tiro di LOCALIZZARE. Ogni tiro impiega un round ed espone i personaggi al profumo dei fiori. Il nido contiene la chiave della Porta di Ferro (#7) e ricchezze pari a tre tesori.\n\n"
              "✦ GIÙ: Buco nel pavimento verso il Laboratorio di Harga (#5).",
        ),
        directions: [
          DirectionButtonData(
            label: "GIÙ: Laboratorio di Harga (#5)",
            targetSceneIndex: 4,
            icon: Icons.arrow_downward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Mostra vista valle",
            targetSceneIndex: 6,
            icon: Icons.landscape,
          ),
          DirectionButtonData(
            label: "Mostra arpie",
            targetSceneIndex: 5,
            icon: Icons.groups,
          ),
          DirectionButtonData(
            label: "Passa alla griglia",
            targetSceneIndex: 10,
            icon: Icons.grid_on,
          ),
        ],
      ),

      // Scene 6: 6. VISTA VALLE (NIDO DELLE ARPIE)
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_vista_valle.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "6. NIDO DELLE ARPIE",
          readAloud:
              "6. NIDO DELLE ARPIE\n"
              "La cima della torre è a cielo aperto. Il dolce odore delle rose è quasi travolgente. Enormi cespugli di rose rosse e nere sono aggrappati alle pareti. Al centro, vedete una bassa pozza di acqua piovana sporca con delle grandi piume scure che galleggiano in superficie.",
          bodyText:
              "✦ Rose: È impossibile evitare il profumo delle rose. I personaggi devono superare un tiro di COS a ogni round o diventare Disorientati. L’effetto può essere evitato trattenendo il respiro (Manuale Base, pag. 53).\n\n"
              "✦ Arpie: Le tre arpie Cardo, Aculeo e Spina sono nascoste tra i cespugli di rose, pronte ad assalire chiunque salga qui.\n\n"
              "✦ Nido: Le tre arpie hanno fatto il loro nido dentro i cespugli di rose. Per trovarlo serve superare un tiro di LOCALIZZARE. Ogni tiro impiega un round ed espone i personaggi al profumo dei fiori. Il nido contiene la chiave della Porta di Ferro (#7) e ricchezze pari a tre tesori.\n\n"
              "✦ GIÙ: Buco nel pavimento verso il Laboratorio di Harga (#5).",
        ),
        directions: [
          DirectionButtonData(
            label: "Torna al Nido delle Arpie (#6)",
            targetSceneIndex: 5,
            icon: Icons.arrow_back,
          ),
          DirectionButtonData(
            label: "GIÙ: Laboratorio di Harga (#5)",
            targetSceneIndex: 4,
            icon: Icons.arrow_downward,
          ),
        ],
        gmActions: [
          DirectionButtonData(
            label: "Mostra nido",
            targetSceneIndex: 5,
            icon: Icons.nest_cam_wired_stand,
          ),
          DirectionButtonData(
            label: "Mostra arpie",
            targetSceneIndex: 6,
            icon: Icons.groups,
          ),
        ],
      ),

      // Scene 7: GRIGLIA TATTICA — PRIMO PIANO
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_griglia_piano1.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GRIGLIA TATTICA — PRIMO PIANO",
          readAloud:
              "GUGLIA DEL TROLL — MAPPA TATTICA PRIMO PIANO\n"
              "Visuale tattica su griglia del Primo Piano della torre.",
          narrative:
              "✦ Mappa Tattica Primo Piano: Griglia con quadrati di movimento per i personaggi e i nemici.\n\n"
              "✦ Controlli GM: Usa 'Sali di un piano' per mostrare il livello superiore o 'Torna indietro' per ripristinare l'illustrazione della scena.",
        ),
        directions: [],
        gmActions: [
          DirectionButtonData(
            label: "Sali di un piano",
            targetSceneIndex: 8,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "Torna indietro",
            targetSceneIndex: 1,
            icon: Icons.arrow_back,
          ),
        ],
      ),

      // Scene 8: GRIGLIA TATTICA — SECONDO PIANO
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_griglia_piano2.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GRIGLIA TATTICA — SECONDO PIANO",
          readAloud:
              "GUGLIA DEL TROLL — MAPPA TATTICA SECONDO PIANO\n"
              "Visuale tattica su griglia del Secondo Piano della torre (Abitazione Abbandonata e Cucina).",
          narrative:
              "✦ Mappa Tattica Secondo Piano: Griglia con il grande tavolo di quercia (#3) e la cucina (#4).\n\n"
              "✦ Controlli GM: Usa 'Sali di un piano' per accedere al terzo piano, 'Scendi di un piano' per tornare al primo o 'Torna indietro' per ripristinare la vista illustrata.",
        ),
        directions: [],
        gmActions: [
          DirectionButtonData(
            label: "Scendi al primo piano",
            targetSceneIndex: 7,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "Sali al terzo piano",
            targetSceneIndex: 9,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "Torna indietro",
            targetSceneIndex: 3,
            icon: Icons.arrow_back,
          ),
        ],
      ),

      // Scene 9: GRIGLIA TATTICA — TERZO PIANO (Laboratorio di Harga)
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_griglia_piano3.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GRIGLIA TATTICA — TERZO PIANO",
          readAloud:
              "GUGLIA DEL TROLL — MAPPA TATTICA TERZO PIANO\n"
              "Visuale tattica su griglia del Terzo Piano della torre (Laboratorio di Harga).",
          narrative:
              "✦ Mappa Tattica Terzo Piano: Griglia con il focolare centrale, alambicchi, banchi da lavoro e la scala verso il tetto.\n\n"
              "✦ Controlli GM: Usa 'Sali al tetto' per accedere al nido delle arpie, 'Scendi al secondo piano' per tornare giù o 'Torna indietro' per ripristinare l'illustrazione del laboratorio.",
        ),
        directions: [],
        gmActions: [
          DirectionButtonData(
            label: "Scendi al secondo piano",
            targetSceneIndex: 8,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "Sali al tetto",
            targetSceneIndex: 10,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "Torna indietro",
            targetSceneIndex: 4,
            icon: Icons.arrow_back,
          ),
        ],
      ),

      // Scene 10: GRIGLIA TATTICA — TETTO / NIDO DELLE ARPIE
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_griglia_tetto.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GRIGLIA TATTICA — TETTO / NIDO DELLE ARPIE",
          readAloud:
              "GUGLIA DEL TROLL — MAPPA TATTICA TETTO / NIDO ARPIE\n"
              "Visuale tattica del tetto a cielo aperto con la pozza d'acqua ed i cespugli di rose.",
          narrative:
              "✦ Mappa Tattica Tetto: Zona di scontro con le tre arpie Cardo, Aculeo e Spina.\n\n"
              "✦ Controlli GM: Usa 'Scendi al terzo piano' per rientrare nel laboratorio, 'Vai alla cripta' per scendere nei sotterranei o 'Torna indietro' per ripristinare la vista illustrata.",
        ),
        directions: [],
        gmActions: [
          DirectionButtonData(
            label: "Scendi al terzo piano",
            targetSceneIndex: 9,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "Vai alla cripta",
            targetSceneIndex: 11,
            icon: Icons.arrow_downward,
          ),
          DirectionButtonData(
            label: "Torna indietro",
            targetSceneIndex: 5,
            icon: Icons.arrow_back,
          ),
        ],
      ),

      // Scene 11: GRIGLIA TATTICA — CRIPTA SOTTO LA TORRE
      SceneData(
        backgroundAsset: 'assets/images/guglia_troll_griglia_cripta.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "GRIGLIA TATTICA — CRIPTA SOTTO LA TORRE",
          readAloud:
              "GUGLIA DEL TROLL — MAPPA TATTICA CRIPTA\n"
              "Visuale tattica della cripta sotterranea decorata con i 4 volti dei draghi nei quadranti.",
          narrative:
              "✦ Mappa Tattica Cripta: Ambiente sotterraneo con le lastre dei quattro draghi (A, B, C, D), la porta di ferro (#7) ed il basamento centrale.\n\n"
              "✦ Controlli GM: Usa 'Sali al primo piano' per risalire il portello, 'Torna al tetto' per andare in cima o 'Torna indietro' per ripristinare la vista illustrata.",
        ),
        directions: [],
        gmActions: [
          DirectionButtonData(
            label: "Sali al primo piano",
            targetSceneIndex: 7,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "Torna al tetto",
            targetSceneIndex: 10,
            icon: Icons.arrow_upward,
          ),
          DirectionButtonData(
            label: "Torna indietro",
            targetSceneIndex: 1,
            icon: Icons.arrow_back,
          ),
        ],
      ),
    ],
  ),
  'cultisti_impiccati': SceneConfig(
    mapId: 'cultisti_impiccati',
    defaultBackground: 'assets/images/cultisti_impiccati.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        backgroundAsset: 'assets/images/cultisti_impiccati.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "CULTISTI IMPICCATI",
          readAloud:
              "EVENTO DI VIAGGIO — CULTISTI IMPICCATI\n"
              "Lungo la strada desolata che solca la regione, tre figure incappucciate vestite di scure tuniche da cultisti pendono esanimi dai rami contorti di un grande albero secco.",
          narrative:
              "Cultisti Morti. Tre umani morti dalle tuniche nere sono appesi a un albero lungo la strada. Guardandoli più da vicino, si notano ferite da spada sui loro corpi. Portano il marchio di Sathmog sui loro avambracci (i personaggi li notano solo se stanno cercando attivamente o se superano un tiro di LOCALIZZARE). Queste povere anime sono cultisti di Sathmog uccisi dal cavaliere di Eledain Tylos (pag. 30) come avvertimento.",
        ),
      ),
    ],
  ),
  'cavaliere_drago': SceneConfig(
    mapId: 'cavaliere_drago',
    defaultBackground: 'assets/images/cavaliere_drago.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        backgroundAsset: 'assets/images/cavaliere_drago.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "IL CAVALIERE DRAGO",
          readAloud:
              "EVENTO DI VIAGGIO — IL CAVALIERE DRAGO\n"
              "Un rumore di zoccoli in rapido avvicinamento risuona nella foresta. Tra gli alberi secolari sorge un maestoso cavaliere in armatura a cavallo.",
          narrative:
              "Il Cavaliere Drago. I personaggi sentono un suono di zoccoli in rapido avvicinamento. Chi supera un tiro di CONSAPEVOLEZZA può nascondersi se vuole; gli altri vengono fermati da un cavaliere in armatura. Il suo nome è Tylos ed è un membro dei Custodi della Fiamma Immacolata, il cui marchio è sull’armatura. Chiede ai personaggi dove siano diretti. A prescindere da quello che dicono, devono eseguire un tiro di PERSUADERE perché lui creda alla loro storia, dato che sospetta che siano cultisti di Sathmog in viaggio verso Forte Malus (pag. 79) per liberare il loro compagno imprigionato là. Se il tiro fallisce, Tylos attacca a meno che i personaggi non dicano di essere alleati di Alfilia Fogliombrosa (pag. 22). Se riescono a calmarlo, Tylos ordina loro di seguirlo e li conduce a Forte Malus (pag. 79) per “una missione importante” (risolvere l’enigma sulla porta del sotterraneo o sfondare il pavimento, ma questo non lo rivela ora). Se i personaggi sono già stati a Forte Malus, Tylos non ne è al corrente. Se si rifiutano di seguirlo, dovranno superare un altro tiro di PERSUADERE o venire attaccati. Tylos ha le stesse statistiche e lo stesso equipaggiamento di Isadelia (pag. 84) ed è su un cavallo da guerra.",
        ),
      ),
    ],
  ),
  'foresta': SceneConfig(
    mapId: 'foresta',
    defaultBackground: 'assets/images/foresta.jpg',
    defaultOverlay: SceneOverlay.none,
    scenes: [
      SceneData(
        backgroundAsset: 'assets/images/foresta.jpg',
        gmNotes: GmNotesData(
          sectionTitle: "FORESTA",
          readAloud:
              "EVENTO DI VIAGGIO — FORESTA\n"
              "Un antico sentiero si snoda tra pini secolari, muschi e rocce coperte di nebbia. Corvi neri osservano il vostro passaggio dai rami ritorti.",
          narrative:
              "✦ Sentiero della Foresta: Una folta vegetazione avvolge il cammino. Tirare su CONSAPEVOLEZZA o SOPRAVVIVENZA per notare tracce di creature selvagge o trappole naturali.",
        ),
      ),
    ],
  ),
};
