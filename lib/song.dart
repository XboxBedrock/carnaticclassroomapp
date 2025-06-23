import 'package:carnaticapp/grading.dart';
import 'package:carnaticapp/util.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/pitch_result.dart';

class CarnaticSongPlayed {
  List<double> _freqList = [];
  List<int> _noteDurations = [];

  double? _freqLastPlayed = null;
  int _totalDurationInSamples = 0;
  int _sampleRate;

  //The offset of note, dictated by noteMap
  int _activeShruti;
  int _tonicOctave;

  CarnaticSongPlayed(this._activeShruti, this._tonicOctave, this._sampleRate);

  //deal in terms of global pitch

  void addSample(double frequency, int numSamples) {
    if (_freqLastPlayed == null) {
      _freqLastPlayed = frequency;
    } else if (_freqLastPlayed != frequency) {
      _freqList.add(_freqLastPlayed?.toDouble() ?? 0);
      _noteDurations.add(_totalDurationInSamples);

      _freqLastPlayed = frequency;
    }

    _totalDurationInSamples = numSamples;
  }

  void sendNullNoteSignal(int numSamples) {
    if (_freqLastPlayed != null) {
      _freqList.add(_freqLastPlayed?.toDouble() ?? 0);
      _noteDurations.add(_totalDurationInSamples);

      _freqLastPlayed = null;
    }

    _totalDurationInSamples = numSamples;
  }

  Future<PlayedSong> gradeify() async {

    PlayedSong g = PlayedSong();

    for (int i = 0; i < _freqList.length; ++i) {
      g.addFreq(_freqList[i], _noteDurations[i]/_sampleRate);
    }

    return g;

  }

  @override
  String toString() {
    String ret = "NEWNEWNENWENWNEWN ";

    print(_noteDurations);

    int totalTime = 0;

    for (int i = 0; i < _freqList.length; ++i) {
      //ret += "${_freqList[i]} relOct - ${_noteDurations[i]} seconds \n";
      totalTime = _noteDurations[i];
    }

    ret += "\n TOTALTIME: $totalTime";

    return ret;
  }
}
