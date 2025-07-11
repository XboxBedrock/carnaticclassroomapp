import 'package:carnaticapp/grading.dart';
import 'package:carnaticapp/raga.dart';
import 'package:carnaticapp/util.dart';

Raga mohanam = Raga(
  "Mohanam",
  "A pentatonic raga, often associated with joy and devotion.",
  [
    CarnaticNote("S", 0, "Shadjam", null),
    CarnaticNote("R", 2, "Chatusruti Rishabham", 2),
    CarnaticNote("G", 3, "Antara Gandharam", 3),
    CarnaticNote("P", 7, "Panchamam", null),
    CarnaticNote("D", 9, "Chatusruti Dhaivatam", 2),
    CarnaticNote("N", 10, "Kaisiki Nishadam", 2)
  ],
);

final CarnaticSong varavina = CarnaticSong(
  name: "Varaveena",
  raga: "Mohanam",
  tala: "Chaturasra Jathi Rupaka",
  bpm: 120,
  sahityaFull: "Varaveena mridupani...",
  lines: [
    SongLine(
      swara: [
        SwaraNote("G", octave: 0, beats: 2),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("P", octave: 2, beats: 0.25),
        SwaraNote("D", octave: -2, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("S", octave: 1, beats: 0.5),
        SwaraNote("S", octave: -1, beats: 1.5),
        SwaraNote("S", octave: -1, beats: 1.5),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Va", "ra", "vee", "na", "Mru", "du", "Pa", "ni"],
    ),
    SongLine(
      swara: [
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("S", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Va", "na", "ru", "ha", "Lo", "cha", "na", "Raa", "ni"],
    ),
    SongLine(
      swara: [
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("S", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Su", "ru", "chi", "ra", "Bam", "bha", "ra", "Ve", "ni"],
    ),
    SongLine(
      swara: [
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("S", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Su", "ra", "nu", "tha", "Kal", "ya", "Ve", "ni"],
    ),
    SongLine(
      swara: [
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("P", octave: 0, beats: 1),
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Ni", "ru", "pa", "ma", "Shu", "bha", "Gu", "na", "Lo"],
    ),
    SongLine(
      swara: [
        SwaraNote("G", octave: 0, beats: 1),
        SwaraNote("D", octave: 0, beats: 1),
        SwaraNote("R", octave: 0, beats: 1),
        SwaraNote("S", octave: 0, beats: 1),
        SwaraNote("||", octave: 0, beats: 0, isBreak: true),
      ],
      sahitya: ["Va", "ra", "da", "Pri", "ya"],
    ),
  ],
  blocks: [
    SongBlock(
      name: "Pallavi",
      groupName: null,
      renderOrder: [0, 1],
      playOrder: [0, 1],
    ),
    SongBlock(
      name: "Anupallavi",
      groupName: null,
      renderOrder: [2, 3],
      playOrder: [2, 3],
    ),
    SongBlock(
      name: "Charanam",
      groupName: null,
      renderOrder: [4, 5],
      playOrder: [4, 5],
    ),
  ],
  playOrder: [0, 1, 2],
  renderOrder: [0, 1, 2],
);
