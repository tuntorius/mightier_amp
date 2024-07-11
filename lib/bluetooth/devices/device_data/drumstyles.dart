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

  static const Map<String, int> metronomeStylesPro = {
    'M1 - 4/4 4th': 67,
    'M2 - 4/4 8th': 68,
    'M3 - 4/4 16th': 69,
    'M4 - 4/4 2nd Tri': 70,
    'M5 - 4/4 4th Tri': 71,
    'M6 - 4/4 8th Tri': 72,
    'M7 - 3/4 4th': 73,
    'M8 - 3/4 8th': 74,
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

  static const Map<String, Map> drumCategoriesProV2 = {
    "Metronome": metronomeStylesProV2,
    "Rock": rockStylesProV2,
    "Country": countryStylesProV2,
    "Blues": bluesStylesProV2,
    "Metal": metalStylesProV2,
    "Funk": funkStylesProV2,
    "Jazz": jazzStylesProV2,
    "Ballad": balladStylesProV2,
    "Pop": popStylesProV2,
    "Reggae": reggaeStylesProV2,
    "Electronic": electronicStylesProV2
  };

  //version 2 - for 2024 update:

  static const Map<String, int> metronomeStylesProV2 = {
    'M1 - 4/4 4th': 0,
    'M2 - 4/4 8th': 1,
    'M3 - 4/4 16th': 2,
    'M4 - 4/4 2nd Tri': 3,
    'M5 - 4/4 4th Tri': 4,
    'M6 - 4/4 8th Tri': 5,
    'M7 - 3/4 4th': 6,
    'M8 - 3/4 8th': 7,
  };

  static const Map<String, int> rockStylesProV2 = {
    'Standard': 8,
    'Swing Rock': 9,
    'Power Beat': 10,
    'Smooth': 11,
    'Mega Drive': 12,
    'Hard Rock': 13,
    'Boogie': 14
  };

  static const Map<String, int> countryStylesProV2 = {
    'Walk Line': 15,
    'Blue Grass': 16,
    'Country': 17,
    'Waltz': 18,
    'Train': 19,
    'Country Rock': 20,
    'Slowly': 21
  };

  static const Map<String, int> bluesStylesProV2 = {
    'Slow Blues': 22,
    'Chicago': 23,
    'R&B': 24,
    'Blues Rock': 25,
    'Road Train': 26,
    'Shuffle': 27,
  };

  static const Map<String, int> metalStylesProV2 = {
    '2X Bass': 28,
    'Close Beat': 29,
    'Heavy Bass': 30,
    'Fast': 31,
    'Holy Case': 32,
    'Open Hat': 33,
    'Epic': 34,
  };

  static const Map<String, int> funkStylesProV2 = {
    'Bounce': 35,
    'East Coast': 36,
    'New Mann': 37,
    'R&B Funk': 38,
    '80s Funk': 39,
    'Soul': 40,
    'Uncle Jam': 41,
  };

  static const Map<String, int> jazzStylesProV2 = {
    'Blues Jazz': 42,
    'Classic 1': 43,
    'Classic 2': 44,
    'Easy Jazz': 45,
    'Fast': 46,
    'Walking': 47,
    'Smooth': 48,
  };

  static const Map<String, int> balladStylesProV2 = {
    'Bluesy': 49,
    'Grooves': 50,
    'Ballad Rock': 51,
    'Slow Rock': 52,
    'Tutorial': 53,
    'R&B Ballad': 54,
    'Gospel': 55,
  };

  static const Map<String, int> popStylesProV2 = {
    'Beach Side': 56,
    'Big City': 57,
    'Funky Pop': 58,
    'Modern': 59,
    'School Pop': 60,
    'Motown': 61,
    'Resistor': 62,
  };

  static const Map<String, int> reggaeStylesProV2 = {
    'Sheriff': 63,
    'Santeria': 64,
    'Reggae 3': 65,
    'Reggae 4': 66,
    'Reggae 5': 67,
    'Reggae 6': 68,
    'Reggae 7': 69,
  };

  static const Map<String, int> electronicStylesProV2 = {
    'Electronic 1': 70,
    'Electronic 2': 71,
    'Electronic 3': 72,
    'Elec-EDM': 73,
    'Elec-Tech': 74,
  };
}
