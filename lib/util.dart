
import 'dart:math';

List<double> octaveIntervals = [
  4186.01,
  2093.00,
  1046.50,
  523.25,
  261.63,
  130.81,
  65.41,
  32.70,
  16.35
];

Map<String, int> noteMap = {
  "C": 0,
  "C#": 1,
  "D": 2,
  "D#": 3,
  "E": 4,
  "F": 5,
  "F#": 6,
  "G": 7,
  "G#": 8,
  "A": 9,
  "A#": 10,
  "B": 11
};

int wrap(int note) {
  int ret = note % 12;
  if (ret < 0) return 12 - ret;
  return ret;
}

List<List<CarnaticNote>> relatives = [
  [CarnaticNote("S", 0, "Shadjam", null)],
  [CarnaticNote("R", 1, "Suddha Rishabham", 1)],
  [
    CarnaticNote("R", 2, "Chatusruti Rishabham", 2),
    CarnaticNote("G", 3, "Suddha Gandharam", 1)
  ],
  [
    CarnaticNote("R", 2, "ShatSruti Rishabham", 3),
    CarnaticNote("G", 3, "Sadharana Gandharam", 2)
  ],
  [CarnaticNote("G", 4, "Antara Gandharam", 3)],
  [CarnaticNote("M", 5, "Suddha Madhyamam", 1)],
  [CarnaticNote("M", 6, "Prati Madhyamam", 2)],
  [CarnaticNote("P", 7, "Panchamam", null)],
  [CarnaticNote("D", 8, "Suddha Dhaivatam", 1)],
  [
    CarnaticNote("D", 9, "Chatusruti Dhaivatam", 2),
    CarnaticNote("N", 9, "Suddha Nishadam", 1)
  ],
  [
    CarnaticNote("D", 9, "ShatSruti Dhaivatam", 3),
    CarnaticNote("N", 10, "Kaisiki Nishadam", 2)
  ],
  [CarnaticNote("N", 11, "Kakali Nishadam", 3)]
];

class CarnaticNote {
  String note;
  int relative;
  String position;
  int? subscript;

  CarnaticNote(this.note, this.relative, this.position, this.subscript);

  @override
  String toString() {
    return "$note $subscript";
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (identical(this, other)) return true; 
    if (other is! CarnaticNote) return false;
    return (note == other.note) && (subscript == other.subscript);
  }
}



double truncDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).toInt().toDouble() / mod);
}


int relativeHalfSteps(int octave, String note, int tonic, int tonicOctave) {
  int octaveOffset = (octave - tonicOctave) * 12;
  int noteOffset = noteMap[note]! - tonic;
  return noteOffset + octaveOffset;
}

int getOctave(double freq) {

  int incre = 8;
  for (int i = 0; i < 9; ++i) {
    if (freq >= octaveIntervals[i]-0.1) return incre;
    incre--;
  }
  return 0;
}