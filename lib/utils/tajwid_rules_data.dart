// Tajwid Rules - 25 rules with colors, descriptions, examples
// Colors: Idgham=Blue, Ikhfa=Green, Qalqalah=Red, Madd=Purple, etc.

import '../models/tajwid_rule_model.dart';

class TajwidRulesData {
  static const List<TajwidRule> rules = [
    TajwidRule(
      id: 'idgham',
      name: 'Idgham',
      arabicName: 'إدغام',
      description: 'Merging of Noon Sakin or Tanween into the following letter',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Noon Sakin Rules',
      subTypes: ['Idgham with Ghunnah', 'Idgham without Ghunnah'],
      exampleWord: 'مِن يَقُولُ',
      videoUrl: 'https://www.youtube.com/watch?v=A0lHGbe0K-M',
    ),
    TajwidRule(
      id: 'ikhfa',
      name: 'Ikhfa',
      arabicName: 'إخفاء',
      description: 'Hiding/concealing Noon Sakin or Tanween with Ghunnah',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Noon Sakin Rules',
      subTypes: ['Ikhfa Haqiqi'],
      exampleWord: 'مِن تَحتِ',
      videoUrl: 'https://youtu.be/uY71Hi5j8_Q?si=FsRn8vWLQtxNU2a4',
    ),
    TajwidRule(
      id: 'iqlab',
      name: 'Iqlab',
      arabicName: 'إقلاب',
      description: 'Converting Noon Sakin or Tanween into Meem before Ba',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Noon Sakin Rules',
      subTypes: [],
      exampleWord: 'مِن بَعدِ',
      videoUrl: 'https://youtu.be/zWZCtEtrkE8?si=4HUepcuEVpXXmfyH',
    ),
    TajwidRule(
      id: 'izhar',
      name: 'Izhar',
      arabicName: 'إظهار',
      description: 'Clear pronunciation of Noon Sakin or Tanween',
      colorHex: '#000000', // Clear (Black)
      backgroundHex: '#FFFFFF',
      category: 'Noon Sakin Rules',
      subTypes: ['Izhar Halqi'],
      exampleWord: 'مِن خَيرٍ',
      videoUrl: 'https://youtu.be/9iibZwLFabI?si=Ad0P5pRVot_SP7ws',
    ),
    TajwidRule(
      id: 'qalqalah',
      name: 'Qalqalah',
      arabicName: 'قلقلة',
      description: 'Echoing bounce sound on letters ق ط ب ج د when Sakin',
      colorHex: '#00AFEB', // Quran.com Light Blue (Exact)
      backgroundHex: '#E1F5FE',
      category: 'Qalqalah',
      subTypes: ['Qalqalah Sughra', 'Qalqalah Kubra'],
      exampleWord: 'قُل',
      videoUrl: 'https://youtu.be/thu6eZ-AeOA?si=HnV0AxGNC340cUuZ',
    ),
    TajwidRule(
      id: 'madd_tabi',
      name: 'Madd Tabi\'i',
      arabicName: 'مد طبيعي',
      description:
          'Natural elongation - 2 counts (Alef, Waw, Ya after Harakat)',
      colorHex: '#BF9B30', // Quran.com Gold (Exact)
      backgroundHex: '#FFF8E1',
      category: 'Madd Rules',
      subTypes: [],
      exampleWord: 'قَالَ',
      videoUrl: 'https://youtu.be/oC_LBcbNCPM?si=saTDa7DKkZ7GvOp2',
    ),
    TajwidRule(
      id: 'madd_muttasil',
      name: 'Madd Muttasil',
      arabicName: 'مد متصل',
      description:
          'Connected Madd - 4-5 counts (Madd letter + Hamzah in same word)',
      colorHex: '#FF4040', // Quran.com Light Red (Exact)
      backgroundHex: '#FFEBEE',
      category: 'Madd Rules',
      subTypes: [],
      exampleWord: 'جَاءَ',
      videoUrl: 'https://youtu.be/AOV5R4WlzqA?si=xpzjo3A-8vn7jtdb',
    ),
    TajwidRule(
      id: 'madd_munfasil',
      name: 'Madd Munfasil',
      arabicName: 'مد منفصل',
      description:
          'Separated Madd - 4-5 counts (Madd letter ends word, Hamzah starts next)',
      colorHex: '#FF841A', // Quran.com Orange (Exact)
      backgroundHex: '#FFF3E0',
      category: 'Madd Rules',
      subTypes: [],
      exampleWord: 'فِي أَنفُسِكُم',
      videoUrl: 'https://youtu.be/AOV5R4WlzqA?si=ptILOxuOeQfCyLL6',
    ),
    TajwidRule(
      id: 'madd_lazim',
      name: 'Madd Lazim',
      arabicName: 'مد لازم',
      description:
          'Obligatory Madd - 6 counts (Sukoon or Shaddah after Madd letter)',
      colorHex: '#D1000B', // Quran.com Dark Red (Exact)
      backgroundHex: '#FFEBEE',
      category: 'Madd Rules',
      subTypes: ['Madd Lazim Kalimi', 'Madd Lazim Harfi'],
      exampleWord: 'الضَّالِّين',
      videoUrl: 'https://youtu.be/lqMyIL3izYM?si=9z0wCdDo1ZEat4m5',
    ),
    TajwidRule(
      id: 'ghunnah',
      name: 'Ghunnah',
      arabicName: 'غنة',
      description:
          'Nasal sound through nose - 2 counts (Meem or Noon with Shaddah)',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Ghunnah',
      subTypes: [],
      exampleWord: 'إِنَّ',
      videoUrl: 'https://youtube.com/shorts/LsxrKTP_fU4?si=ElQoqvIlTEl6AglM',
    ),
    TajwidRule(
      id: 'shaddah',
      name: 'Shaddah',
      arabicName: 'شدّة',
      description: 'Double consonant - letter is held twice as long',
      colorHex: '#37474F',
      backgroundHex: '#ECEFF1',
      category: 'Shaddah',
      subTypes: [],
      exampleWord: 'شَدَّ',
      videoUrl: 'https://youtu.be/saHb0bcVa7k?si=cuXb6GP8BiBuq2JJ',
    ),
    TajwidRule(
      id: 'tafkhim',
      name: 'Tafkhim',
      arabicName: 'تفخيم',
      description: 'Heavy pronunciation - back of tongue raised',
      colorHex: '#558B2F',
      backgroundHex: '#F9FBE7',
      category: 'Characteristics',
      subTypes: [],
      exampleWord: 'خَلَقَ',
      videoUrl: 'https://youtu.be/Ae4Iu-yPA4c?si=2WO2F4IfWGJoBMUx',
    ),
    TajwidRule(
      id: 'tarqiq',
      name: 'Tarqiq',
      arabicName: 'ترقيق',
      description: 'Light pronunciation - tongue stays low',
      colorHex: '#00695C',
      backgroundHex: '#E0F2F1',
      category: 'Characteristics',
      subTypes: [],
      exampleWord: 'بِسمِ',
      videoUrl: 'https://youtu.be/Ae4Iu-yPA4c?si=2WO2F4IfWGJoBMUx',
    ),
    TajwidRule(
      id: 'lam_shamsiyya',
      name: 'Lam Shamsiyya',
      arabicName: 'لام شمسية',
      description:
          'Sun letters - the Lam of "Al" is assimilated into the following letter',
      colorHex: '#AAAAAA', // Dar al-Maarifah Gray
      backgroundHex: '#F5F5F5',
      category: 'Lam Rules',
      subTypes: [],
      exampleWord: 'الشَّمس',
      videoUrl: 'https://youtu.be/tm8dcT9yNUA?si=V7kxvxG3pyBSMe03',
    ),
    TajwidRule(
      id: 'lam_qamariyya',
      name: 'Lam Qamariyya',
      arabicName: 'لام قمرية',
      description: 'Moon letters - the Lam of "Al" is clearly pronounced',
      colorHex: '#000000', // Clear (Black)
      backgroundHex: '#FFFFFF',
      category: 'Lam Rules',
      subTypes: [],
      exampleWord: 'القَمَر',
      videoUrl: 'https://youtu.be/tm8dcT9yNUA?si=V7kxvxG3pyBSMe03',
    ),
    TajwidRule(
      id: 'idgham_mimi',
      name: 'Idgham Mimi',
      arabicName: 'إدغام ميمي',
      description: 'Merging Meem Sakin into following Meem with Ghunnah',
      colorHex: '#283593',
      backgroundHex: '#E8EAF6',
      category: 'Meem Sakin Rules',
      subTypes: [],
      exampleWord: 'لَهُم مَّا',
      videoUrl: 'https://youtu.be/9Pl_waWlo1k?si=1jyz1E9aOQuFMall',
    ),
    TajwidRule(
      id: 'ikhfa_shafawi',
      name: 'Ikhfa Shafawi',
      arabicName: 'إخفاء شفوي',
      description: 'Hiding Meem Sakin before Ba with Ghunnah',
      colorHex: '#AD1457',
      backgroundHex: '#FCE4EC',
      category: 'Meem Sakin Rules',
      subTypes: [],
      exampleWord: 'تَرمِيهِم بِحِجَارَة',
      videoUrl: 'https://youtu.be/vObTG3vQBdo?si=ki1-ZDBoynehMowa',
    ),
    TajwidRule(
      id: 'izhar_shafawi',
      name: 'Izhar Shafawi',
      arabicName: 'إظهار شفوي',
      description:
          'Clear pronunciation of Meem Sakin before all letters except Meem and Ba',
      colorHex: '#00838F',
      backgroundHex: '#E0F7FA',
      category: 'Meem Sakin Rules',
      subTypes: [],
      exampleWord: 'هُم فِيهَا',
      videoUrl: 'https://youtu.be/UG8SK4-v8fw?si=E1o5A1LP-LmQz90I',
    ),
    TajwidRule(
      id: 'waqf_ibtida',
      name: 'Waqf & Ibtida',
      arabicName: 'وقف وابتداء',
      description:
          'Stopping and starting rules - when to pause and resume recitation',
      colorHex: '#6D4C41',
      backgroundHex: '#EFEBE9',
      category: 'Waqf Rules',
      subTypes: ['Waqf Taam', 'Waqf Kafi', 'Waqf Hasan'],
      exampleWord: '● ج ۛ',
      videoUrl: 'https://youtu.be/XIf0h3uX6OU?si=6zq2RDWP8ZqSnhom',
    ),
    TajwidRule(
      id: 'sakt',
      name: 'Sakt',
      arabicName: 'سكت',
      description:
          'Brief pause without breathing - specific positions in Quran',
      colorHex: '#455A64',
      backgroundHex: '#ECEFF1',
      category: 'Waqf Rules',
      subTypes: [],
      exampleWord: 'كَلَّا ۛ بَل',
      videoUrl: 'https://youtube.com/shorts/lD0K_XKwx9Q?si=3vcoXFVr7ysEKC-t',
    ),
    TajwidRule(
      id: 'hamzat_wasl',
      name: 'Hamzat al-Wasl',
      arabicName: 'همزة الوصل',
      description:
          'Connecting Hamzah - dropped when continuing from previous word',
      colorHex: '#4527A0',
      backgroundHex: '#EDE7F6',
      category: 'Hamzah Rules',
      subTypes: [],
      exampleWord: 'بِسمِ ٱللَّهِ',
      videoUrl: 'https://youtu.be/apQ4OpzDTzU?si=JLl9z6NiotIF2Z-d',
    ),
    TajwidRule(
      id: 'ra_rules',
      name: 'Ra Rules',
      arabicName: 'أحكام الراء',
      description: 'Rules for pronouncing the letter Ra - heavy or light',
      colorHex: '#BF360C',
      backgroundHex: '#FBE9E7',
      category: 'Letter Rules',
      subTypes: ['Ra Tafkhim', 'Ra Tarqiq'],
      exampleWord: 'رَبِّ / الرَّحِيم',
      videoUrl: 'https://youtu.be/aQxSPl1DGo8?si=XzV4MQobIxcS0Xmd',
    ),
    TajwidRule(
      id: 'noon_qutni',
      name: 'Noon Qutni',
      arabicName: 'نون القطني',
      description: 'Extra Noon added when reading Quran with specific rules',
      colorHex: '#1A237E',
      backgroundHex: '#E8EAF6',
      category: 'Special Rules',
      subTypes: [],
      exampleWord: 'إِذَن',
      videoUrl: 'https://youtu.be/RA05UXwZLmM?si=NGJCA3drsgDOAzne',
    ),
    TajwidRule(
      id: 'madd_arid',
      name: 'Madd Arid',
      arabicName: 'مد عارض',
      description:
          'Incidental Madd - occurs when stopping at end of verse, 2-6 counts',
      colorHex: '#827717',
      backgroundHex: '#F9FBE7',
      category: 'Madd Rules',
      subTypes: [],
      exampleWord: 'نَستَعِينُ',
      videoUrl: 'https://youtu.be/j1eHcChXYC8?si=C9Mu7fAhy2NnA9Et',
    ),
    TajwidRule(
      id: 'madd_leen',
      name: 'Madd Leen',
      arabicName: 'مد لين',
      description:
          'Softness Madd - Waw or Ya with Fatha before them when stopping',
      colorHex: '#E65100',
      backgroundHex: '#FFF3E0',
      category: 'Madd Rules',
      subTypes: [],
      exampleWord: 'خَوفٍ',
      videoUrl: 'https://youtu.be/1IPzpRRFVOs?si=didz8aRBeh0BDWV2',
    ),
  ];

  static TajwidRule? findById(String id) {
    try {
      return rules.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<TajwidRule> byCategory(String category) {
    return rules.where((r) => r.category == category).toList();
  }
}

