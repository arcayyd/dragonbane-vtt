class NpcData {
  final String id;
  final String name;
  final String category; // 'orlo' o 'viaggi'
  final String imageAsset;
  final String description;
  final List<String> stats;
  final List<String> skills;
  final List<String> weapons;
  final List<String> abilities;

  const NpcData({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.description,
    this.stats = const [],
    this.skills = const [],
    this.weapons = const [],
    this.abilities = const [],
  });
}

const List<NpcData> npcList = [
  // --- ORLO ---
  NpcData(
    id: 'npc_annabella',
    name: 'Annabella',
    category: 'orlo',
    imageAsset: 'assets/images/vagnhild.jpg',
    description:
        "Annabella lavora alla locanda 'Ai Tre Cervi' ed è una delle figure centrali del villaggio. "
        "È accogliente e dinamica, ma si mormora che nasconda importanti segreti legati ai culti della zona.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 14',
      'PV (Punti Volontà): 12',
    ],
    skills: [
      'Persuadere: 14',
      'Intrattenere: 14',
      'Rissa: 10',
    ],
    weapons: [
      'Martello da Guerra Leggero (Abilità: 12, Danno: 2D6)',
    ],
    abilities: ['Ospitalità', 'Segreti del Culto'],
  ),
  NpcData(
    id: 'npc_vagnhild',
    name: 'Vagnhild',
    category: 'orlo',
    imageAsset: 'assets/images/valeria_portrait.jpg',
    description:
        "La carismatica capovillaggio informale di Orlo e gestisce la locanda 'Ai Tre Cervi'. "
        "È autorevole, fiera ed accogliente, ma sa farsi rispettare in ogni occasione.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 14',
      'PV (Punti Volontà): 12',
    ],
    skills: [
      'Persuadere: 15',
      'Consapevolezza: 12',
    ],
    weapons: [
      'Martello da Guerra (Abilità: 12, Danno: 2D6)',
    ],
    abilities: ['Leader del villaggio'],
  ),
  NpcData(
    id: 'npc_hardy',
    name: 'Hardy',
    category: 'orlo',
    imageAsset: 'assets/images/hardy_portrait.jpg',
    description:
        "Capo delle guardie del villaggio, Hardy è un veterano di guerra temprato dalle battaglie. "
        "È forte, taciturno e vigila sulle torri di guardia. Allena il giovane Jory e si assicura "
        "che la palizzata sia sempre difesa da goblin e briganti.",
    stats: [
      'Movimento: 12',
      'PF (Punti Ferita): 16',
      'PV (Punti Volontà): 14',
      'Armatura: Cuoio borchiato e celata (3)',
    ],
    skills: [
      'Consapevolezza: 14',
      'Guarire: 8',
      'Rissa: 14',
      'Sfuggire: 12',
    ],
    weapons: [
      'Spadone (Abilità: 14, Danno: 2D6)',
      'Balestra pesante (Abilità: 12, Danno: 2D8)',
      'Scudo grande',
    ],
    abilities: ['Difensivo', 'Veterano'],
  ),
  NpcData(
    id: 'npc_quasimodo',
    name: 'Quasimodo',
    category: 'orlo',
    imageAsset: 'assets/images/quasimodo.jpg',
    description:
        "Misteriosa ed enigmatica anatra antropomorfa (Mallard) ricoperta da un manto scuro e da un cappuccio. "
        "È un furfante esperto ed infido che trama nell'ombra attorno al villaggio di Orlo, dirigendo la sua banda di sgherri.",
    stats: [
      'Movimento: 12',
      'PF (Punti Ferita): 13',
      'PV (Punti Volontà): 14',
      'Armatura: Cuoio borchiato (2)',
    ],
    skills: [
      'Furtività: 16',
      'Combattimento: 14',
      'Slealtà / Raggirare: 15',
      'Consapevolezza: 13',
    ],
    weapons: [
      'Pugnale avvelenato (Abilità: 16, Danno: 1D8 + Veleno)',
      'Balestra leggera (Abilità: 14, Danno: 2D6)',
    ],
    abilities: ['Mimetismo nell\'ombra', 'Attacco di Sorpresa'],
  ),
  NpcData(
    id: 'npc_sgherri_quasimodo',
    name: 'Sgherri di Quasimodo',
    category: 'orlo',
    imageAsset: 'assets/images/sgherri_quasimodo.jpg',
    description:
        "Una banda di tre spietati mercenari e tagliagole al soldo di Quasimodo: "
        "un subdolo assassino armato di pugnale insanguinato, un possente bruto armato di spadone "
        "ed una letale alchimista esperta in veleni paralizzanti.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 15 per sgherro',
      'PV (Punti Volontà): 10',
      'Armatura: Cuoio rinforzato (2)',
    ],
    skills: [
      'Combattimento: 14',
      'Rissa: 13',
      'Furtività: 12',
    ],
    weapons: [
      'Spadone a due mani (Bruto: Abilità 14, Danno 2D6+2)',
      'Pugnali doppi (Assassino: Abilità 15, Danno 1D8)',
      'Boccetta di Veleno Alchemico (Alchimista: Danno paralizzante)',
    ],
    abilities: ['Tattiche di Gruppo', 'Accerchiamento'],
  ),
  NpcData(
    id: 'npc_alfilia_fogliombrosa',
    name: 'Alfilia Fogliombrosa',
    category: 'orlo',
    imageAsset: 'assets/images/guerriera_armatura.jpg',
    description:
        "Una paladina e protettrice della Valle Nebbiosa in armatura di piastre complete incisa con antichi simboli. "
        "Vigila su Orlo e collabora alla sicurezza della comunità contro le minacce esterne.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 18',
      'PV (Punti Volontà): 14',
      'Armatura: Piastre complete (6)',
    ],
    skills: [
      'Consapevolezza: 12',
      'Spade: 15',
      'Fede: 14',
    ],
    weapons: [
      'Spadone d\'Arme (Abilità: 15, Danno: 2D6+2)',
    ],
    abilities: ['Impassibile', 'Protezione Sacra'],
  ),
  NpcData(
    id: 'npc_okald',
    name: 'Okald',
    category: 'orlo',
    imageAsset: 'assets/images/dranath.jpg',
    description:
        "Un saggio ed enigmatico mistico e guaritore che vive a Orlo. Okald è in grado di "
        "curare ferite e malattie con le sue arti magiche ed ha una profonda conoscenza dei "
        "luoghi antichi della Valle Nebbiosa.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 10',
      'PV (Punti Volontà): 16',
    ],
    skills: [
      'Miti e Leggende: 16',
      'Guarire: 14',
      'Persuadere: 12',
    ],
    weapons: [
      'Bastone (Abilità: 10, Danno: D6)',
    ],
    abilities: [
      'Magia di Guarigione (Cura Ferite - Livello di Potere: D6)',
    ],
  ),
  NpcData(
    id: 'npc_ulvar',
    name: 'Mastro Ulvar',
    category: 'orlo',
    imageAsset: 'assets/images/ulvar.jpg',
    description:
        "Gestisce l'unico emporio del villaggio. È un uomo alto sulla cinquantina con baffi cadenti "
        "e mani grandi come prosciutti. Vende attrezzatura generale ed è il padre di Jory, "
        "sebbene il figlio mostri scarso interesse per il commercio.",
    stats: [
      'Movimento: 8',
      'PF (Punti Ferita): 12',
      'PV (Punti Volontà): 10',
    ],
    skills: [
      'Commerciare: 15',
      'Valutare: 14',
      'Consapevolezza: 12',
    ],
    weapons: [
      'Coltello da Bottegaio (Abilità: 10, Danno: D4)',
    ],
    abilities: ['Negoziatore'],
  ),
  NpcData(
    id: 'npc_jory',
    name: 'Jory',
    category: 'orlo',
    imageAsset: 'assets/images/jory.jpg',
    description:
        "Il figlio di Mastro Ulvar. Suo padre lo vorrebbe come successore nel negozio, ma il ragazzo "
        "ha occhi solo per l'avventura. Guarda con ammirazione Hardy e spera di diventare una guardia del villaggio.",
    stats: [
      'Movimento: 11',
      'PF (Punti Ferita): 12',
      'PV (Punti Volontà): 10',
    ],
    skills: [
      'Spade: 10',
      'Sfuggire: 11',
      'Atletica: 12',
    ],
    weapons: [
      'Spada Corta (Abilità: 10, Danno: D8)',
    ],
    abilities: ['Sognatore', 'Agile'],
  ),
  NpcData(
    id: 'npc_semolina_guanciotto',
    name: 'Semolina Guanciotto',
    category: 'orlo',
    imageAsset: 'assets/images/annabella.jpg',
    description:
        "Semolina Guanciotto lavora attivamente a Orlo. Allegra ed operosa, "
        "si occupa di varie mansioni ed è sempre pronta a scambiare battute con chiunque visiti il villaggio.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 10',
      'PV (Punti Volontà): 12',
    ],
    skills: [
      'Intrattenere: 12',
      'Persuadere: 10',
    ],
    weapons: [],
    abilities: ['Accogliente'],
  ),
  NpcData(
    id: 'npc_badinor',
    name: 'Badinor',
    category: 'orlo',
    imageAsset: 'assets/images/badinor.jpg',
    description:
        "Un abile e robusto fabbro nano rispettato in tutto il villaggio. Gestisce la forgia di Orlo "
        "e può riparare armi ed armature danneggiate degli avventurieri per qualche moneta d'argento.",
    stats: [
      'Movimento: 8',
      'PF (Punti Ferita): 16',
      'PV (Punti Volontà): 12',
      'Armatura: Grembiule di cuoio rinforzato (2)',
    ],
    skills: [
      'Artigianato (Fabbro): 16',
      'Martelli: 12',
      'Resistere: 14',
    ],
    weapons: [
      'Martello da Forgia (Abilità: 12, Danno: D8+2)',
    ],
    abilities: ['Riparare Equipaggiamento', 'Costituzione Nana'],
  ),
  NpcData(
    id: 'npc_popolani_armati',
    name: 'Popolani armati',
    category: 'orlo',
    imageAsset: 'assets/images/coloni.jpg',
    description:
        "Gli abitanti di Orlo che coltivano i campi circostanti. Sebbene pacifici, sono pronti a "
        "prendere le armi (forconi, asce e spade corte) sotto la guida di Hardy per difendere la "
        "palizzata dagli attacchi dei goblin.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 10',
      'PV (Punti Volontà): 8',
    ],
    skills: [
      'Artigianato: 10',
      'Rissa: 10',
    ],
    weapons: [
      'Forcone / Ascia da Taglio (Abilità: 10, Danno: D8)',
    ],
    abilities: ['Lavoro di Squadra'],
  ),

  // --- VIAGGI ---
  NpcData(
    id: 'npc_oda_e_medvin',
    name: 'Oda e Medvin',
    category: 'viaggi',
    imageAsset: 'assets/images/oda_e_medvin.jpg',
    description:
        "Oda, un'anziana donna saggia e stanca, viaggia insieme a Medvin, un giovane spaventato. "
        "Si muovono lungo i sentieri della Valle Nebbiosa portando con sé antichi racconti ed avvertimenti.",
    stats: [
      'Movimento: 8',
      'PF (Punti Ferita): 10',
      'PV (Punti Volontà): 12',
    ],
    skills: [
      'Miti e Leggende: 14',
      'Consapevolezza: 10',
    ],
    weapons: [],
    abilities: ['Saggezza Popolare'],
  ),
  NpcData(
    id: 'npc_lilly',
    name: 'Lilly',
    category: 'viaggi',
    imageAsset: 'assets/images/lilly.jpg',
    description:
        "Lilly è una giovane ed espressiva ragazza dai capelli rossi che viaggia lungo i sentieri della regione. "
        "Intelligente, osservatrice e risoluta, conosce molte scorciatoie e storie locali sui pericoli della valle.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 10',
      'PV (Punti Volontà): 14',
    ],
    skills: [
      'Consapevolezza: 14',
      'Furtività: 14',
      'Miti e Leggende: 12',
      'Persuadere: 12',
    ],
    weapons: [
      'Pugnale (Abilità: 10, Danno: D8)',
    ],
    abilities: ['Conoscenza delle Scorciatoie', 'Spirito Curioso'],
  ),

  // --- PG GIOCANTI ---
  NpcData(
    id: 'pg_durnak',
    name: 'Durnak',
    category: 'pg',
    imageAsset: 'assets/images/durnak.jpg',
    description:
        "Durnak è un possente nano fabbro ed avventuriero, armato di un pesante maglio da guerra "
        "e guidato dall'onore delle antiche tradizioni dei nani. Robusto, leale ed incrollabile in battaglia.",
    stats: [
      'Movimento: 8',
      'PF (Punti Ferita): 18',
      'PV (Punti Volontà): 14',
      'Armatura: Grembiule di cuoio rinforzato (3)',
    ],
    skills: [
      'Artigianato (Fabbro): 16',
      'Martelli: 15',
      'Resistenza / COS: 16',
      'Consapevolezza: 12',
    ],
    weapons: [
      'Maglio da Guerra Pesante (Abilità: 15, Danno: 2D8+2)',
    ],
    abilities: ['Resistenza Nanica', 'Mastro Fabbro'],
  ),
  NpcData(
    id: 'pg_morgan',
    name: 'Morgan',
    category: 'pg',
    imageAsset: 'assets/images/morgan.jpg',
    description:
        "Morgan è un saggio ed enigmatico incantatore ramingo, custode dei segreti della natura e della magia arcana. "
        "È costantemente accompagnato da due corvi fidati che perlustrano i cieli per lui.",
    stats: [
      'Movimento: 10',
      'PF (Punti Ferita): 12',
      'PV (Punti Volontà): 18',
      'Armatura: Mantello di lana e tonaca imbottita (1)',
    ],
    skills: [
      'Miti e Leggende: 16',
      'Magia (Elementalismo / Animismo): 16',
      'Consapevolezza: 14',
      'Persuadere: 12',
    ],
    weapons: [
      'Bastone da Passeggio Intagliato (Abilità: 12, Danno: D8)',
    ],
    abilities: ['Compagni Corvi', 'Padronanza Arcana'],
  ),
  NpcData(
    id: 'pg_capricorn',
    name: 'Capricorn',
    category: 'pg',
    imageAsset: 'assets/images/capricorn.jpg',
    description:
        "Capricorn è un feroce e scattante cacciatore licantropo / lupin. Dominatore delle selve, "
        "impugna uno spadone a due mani con micidiale maestria e fiuta le minacce a grande distanza.",
    stats: [
      'Movimento: 14',
      'PF (Punti Ferita): 16',
      'PV (Punti Volontà): 12',
      'Armatura: Cuoio rinforzato e pellicce (3)',
    ],
    skills: [
      'Spade (Spadone): 16',
      'Consapevolezza (Olfatto / Udito): 16',
      'Atletica / Acrobatica: 14',
      'Furtività: 14',
    ],
    weapons: [
      'Spadone Pesante a Due Mani (Abilità: 16, Danno: 2D8+2)',
      'Artigli (Abilità: 14, Danno: D6+2)',
    ],
    abilities: ['Senso del Segugio', 'Attacco di Furia'],
  ),
  NpcData(
    id: 'pg_gilberd',
    name: 'Gilberd',
    category: 'pg',
    imageAsset: 'assets/images/gilberd.jpg',
    description:
        "Gilberd è un'astuta ed elegante anatra antropomorfa (Mallard), maestro di inganni, scassinatore e duellante d'affondo. "
        "Agile, elegante e sempre un passo avanti ai suoi nemici ed ai guardiani dei tesori.",
    stats: [
      'Movimento: 12',
      'PF (Punti Ferita): 14',
      'PV (Punti Volontà): 14',
      'Armatura: Giacchetto in cuoio lavorato e gilet (2)',
    ],
    skills: [
      'Furtività: 16',
      'Destrezza Manuale / Scassinare: 16',
      'Stocco / Pugnale: 15',
      'Persuadere / Raggirare: 14',
    ],
    weapons: [
      'Stocco Finemente Decorato (Abilità: 15, Danno: D10+1)',
      'Pugnale da Lancio (Abilità: 14, Danno: D8)',
    ],
    abilities: ['Tiro Furtivo', 'Riflessi di Anatra'],
  ),
];
