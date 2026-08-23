class Character {
  final String id;
  final String name;
  final String stirpe; // Kin (Ancestry)
  final String professione; // Profession
  final String debolezza; // Weakness
  
  // Attributes
  final int forta; // STR
  final int costituzione; // CON
  final int agilita; // AGI
  final int intelligenza; // INT
  final int volonta; // WIL
  final int carisma; // CHA

  // Conditions (true if active)
  final bool esausto; // affected attribute: FOR
  final bool malaticcio; // affected attribute: COS
  final bool disorientato; // affected attribute: AGI
  final bool arrabbiato; // affected attribute: INT
  final bool spaventato; // affected attribute: VOL
  final bool scoraggiato; // affected attribute: CAR

  // Core stats
  final int hp;
  final int maxHp;
  final int wp;
  final int maxWp;

  // Skills: Map of Skill Name -> Level (e.g. "Acrobazia": 12)
  final Map<String, int> skills;
  
  // Weapons and shields
  final List<WeaponItem> weapons;
  
  // Inventory list
  final List<String> inventory;
  
  // Role and security
  final bool isNpc;
  final String gmNotes; // Notes only GM can read
  
  Character({
    required this.id,
    required this.name,
    this.stirpe = '',
    this.professione = '',
    this.debolezza = '',
    this.forta = 10,
    this.costituzione = 10,
    this.agilita = 10,
    this.intelligenza = 10,
    this.volonta = 10,
    this.carisma = 10,
    this.esausto = false,
    this.malaticcio = false,
    this.disorientato = false,
    this.arrabbiato = false,
    this.spaventato = false,
    this.scoraggiato = false,
    required this.hp,
    required this.maxHp,
    required this.wp,
    required this.maxWp,
    required this.skills,
    this.weapons = const [],
    this.inventory = const [],
    this.isNpc = false,
    this.gmNotes = '',
  });

  // Check if a skill or attribute is currently hindered by a condition
  bool hasBaneForAttribute(String attributeAbbreviation) {
    switch (attributeAbbreviation.toUpperCase()) {
      case 'FOR': return esausto;
      case 'COS': return malaticcio;
      case 'AGI': return disorientato;
      case 'INT': return arrabbiato;
      case 'VOL': return spaventato;
      case 'CAR': return scoraggiato;
      default: return false;
    }
  }

  // CopyWith method for state updates
  Character copyWith({
    String? id,
    String? name,
    String? stirpe,
    String? professione,
    String? debolezza,
    int? forta,
    int? costituzione,
    int? agilita,
    int? intelligenza,
    int? volonta,
    int? carisma,
    bool? esausto,
    bool? malaticcio,
    bool? disorientato,
    bool? arrabbiato,
    bool? spaventato,
    bool? scoraggiato,
    int? hp,
    int? maxHp,
    int? wp,
    int? maxWp,
    Map<String, int>? skills,
    List<WeaponItem>? weapons,
    List<String>? inventory,
    bool? isNpc,
    String? gmNotes,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      stirpe: stirpe ?? this.stirpe,
      professione: professione ?? this.professione,
      debolezza: debolezza ?? this.debolezza,
      forta: forta ?? this.forta,
      costituzione: costituzione ?? this.costituzione,
      agilita: agilita ?? this.agilita,
      intelligenza: intelligenza ?? this.intelligenza,
      volonta: volonta ?? this.volonta,
      carisma: carisma ?? this.carisma,
      esausto: esausto ?? this.esausto,
      malaticcio: malaticcio ?? this.malaticcio,
      disorientato: disorientato ?? this.disorientato,
      arrabbiato: arrabbiato ?? this.arrabbiato,
      spaventato: spaventato ?? this.spaventato,
      scoraggiato: scoraggiato ?? this.scoraggiato,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      wp: wp ?? this.wp,
      maxWp: maxWp ?? this.maxWp,
      skills: skills ?? this.skills,
      weapons: weapons ?? this.weapons,
      inventory: inventory ?? this.inventory,
      isNpc: isNpc ?? this.isNpc,
      gmNotes: gmNotes ?? this.gmNotes,
    );
  }

  // Convert to/from JSON for sync serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stirpe': stirpe,
      'professione': professione,
      'debolezza': debolezza,
      'forta': forta,
      'costituzione': costituzione,
      'agilita': agilita,
      'intelligenza': intelligenza,
      'volonta': volonta,
      'carisma': carisma,
      'esausto': esausto,
      'malaticcio': malaticcio,
      'disorientato': disorientato,
      'arrabbiato': arrabbiato,
      'spaventato': spaventato,
      'scoraggiato': scoraggiato,
      'hp': hp,
      'maxHp': maxHp,
      'wp': wp,
      'maxWp': maxWp,
      'skills': skills,
      'weapons': weapons.map((w) => w.toJson()).toList(),
      'inventory': inventory,
      'isNpc': isNpc,
      'gmNotes': gmNotes,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      stirpe: json['stirpe'] ?? '',
      professione: json['professione'] ?? '',
      debolezza: json['debolezza'] ?? '',
      forta: json['forta'] ?? 10,
      costituzione: json['costituzione'] ?? 10,
      agilita: json['agilita'] ?? 10,
      intelligenza: json['intelligenza'] ?? 10,
      volonta: json['volonta'] ?? 10,
      carisma: json['carisma'] ?? 10,
      esausto: json['esausto'] ?? false,
      malaticcio: json['malaticcio'] ?? false,
      disorientato: json['disorientato'] ?? false,
      arrabbiato: json['arrabbiato'] ?? false,
      spaventato: json['spaventato'] ?? false,
      scoraggiato: json['scoraggiato'] ?? false,
      hp: json['hp'] ?? 10,
      maxHp: json['maxHp'] ?? 10,
      wp: json['wp'] ?? 10,
      maxWp: json['maxWp'] ?? 10,
      skills: Map<String, int>.from(json['skills'] ?? {}),
      weapons: (json['weapons'] as List? ?? [])
          .map((w) => WeaponItem.fromJson(w))
          .toList(),
      inventory: List<String>.from(json['inventory'] ?? []),
      isNpc: json['isNpc'] ?? false,
      gmNotes: json['gmNotes'] ?? '',
    );
  }
}

class WeaponItem {
  final String name;
  final String attribute;
  final String damage;
  final String range;
  final int durability;
  final String qualities;

  WeaponItem({
    required this.name,
    required this.attribute,
    required this.damage,
    required this.range,
    this.durability = 0,
    this.qualities = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attribute': attribute,
      'damage': damage,
      'range': range,
      'durability': durability,
      'qualities': qualities,
    };
  }

  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    return WeaponItem(
      name: json['name'],
      attribute: json['attribute'] ?? 'FOR',
      damage: json['damage'] ?? '1d8',
      range: json['range'] ?? '-',
      durability: json['durability'] ?? 0,
      qualities: json['qualities'] ?? '',
    );
  }
}
