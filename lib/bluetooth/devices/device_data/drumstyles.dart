class DrumStyles {
  static const List<String> drumStyles8BT = [
    "Metronome",
    "Pop",
    "Metal",
    "Blues",
    "Country",
    "Rock",
    "Ballad Rock",
    "Funk",
    "R&B",
    "Latin"
  ];

  static const List<String> drumStyles2040BT = [
    "Metronome",
    "Rock",
    "60's",
    "Bossanova",
    "Pop 1",
    "Pop 2",
    "Pop 3",
    "Blues 1",
    "Blues 2",
    "Jazz",
    "Jam",
    "R&B",
    "Latin",
    "Dance House",
    "Dance House 1",
    "Blues 3/4",
    "Ballad 3/4"
  ];

  static const List<String> drumStylesPlug = [
    "Metronome",
    "Pop",
    "Metal",
    "Blues",
    "Swing",
    "Rock",
    "Ballad Rock",
    "Funk",
    "R&B",
    "Latin",
    "Dance"
  ];

  static const Map<String, int> rockStylesPro = {
    'Standard': 0,
    'Swing Rock': 1,
    'Power Beat': 2,
    'Smooth': 3,
    'Mega Drive': 4,
    'Hard Rock': 5,
    'Boogie': 6
  };

  static const Map<String, int> countryStylesPro = {
    'Walk Line': 7,
    'Blue Grass': 8,
    'Country': 9,
    'Waltz': 10,
    'Train': 11,
    'Country Rock': 12,
    'Slowly': 13
  };

  static const Map<String, int> bluesStylesPro = {
    'Slow Blues': 14,
    'Chicago': 15,
    'R&B': 16,
    'Blues Rock': 17,
    'Road Train': 18,
    'Shuffle': 19,
  };

  static const Map<String, int> metalStylesPro = {
    '2X Bass': 20,
    'Close Beat': 21,
    'Heavy Bass': 22,
    'Fast': 23,
    'Holy Case': 24,
    'Open Hat': 25,
    'Epic': 26,
  };

  static const Map<String, int> funkStylesPro = {
    'Bounce': 27,
    'East Coast': 28,
    'New Mann': 29,
    'R&B Funk': 30,
    '80s Funk': 31,
    'Soul': 32,
    'Uncle Jam': 33,
  };

  static const Map<String, int> jazzStylesPro = {
    'Blues Jazz': 34,
    'Classic 1': 35,
    'Classic 2': 36,
    'Easy Jazz': 37,
    'Fast': 38,
    'Walking': 39,
    'Smooth': 40,
  };

  static const Map<String, int> balladStylesPro = {
    'Bluesy': 41,
    'Grooves': 42,
    'Ballad Rock': 43,
    'Slow Rock': 44,
    'Tutorial': 45,
    'R&B Ballad': 46,
    'Gospel': 47,
  };

  static const Map<String, int> popStylesPro = {
    'Beach Side': 48,
    'Big City': 49,
    'Funky Pop': 50,
    'Modern': 51,
    'School Pop': 52,
    'Motown': 53,
    'Resistor': 54,
  };

  static const Map<String, int> reggaeStylesPro = {
    'Sheriff': 55,
    'Santeria': 56,
    'Reggae 3': 57,
    'Reggae 4': 58,
    'Reggae 5': 59,
    'Reggae 6': 60,
    'Reggae 7': 61,
  };

  static const Map<String, int> electronicStylesPro = {
    'Electronic 1': 62,
    'Electronic 2': 63,
    'Electronic 3': 64,
    'Elec-EDM': 65,
    'Elec-Tech': 66,
  };

  static const Map<String, Map> drumCategoriesPro = {
    "Rock": rockStylesPro,
    "Country": countryStylesPro,
    "Blues": bluesStylesPro,
    "Metal": metalStylesPro,
    "Funk": funkStylesPro,
    "Jazz": jazzStylesPro,
    "Ballad": balladStylesPro,
    "Pop": popStylesPro,
    "Reggae": reggaeStylesPro,
    "Electronic": electronicStylesPro
  };
}
