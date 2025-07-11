import 'package:carnaticapp/events/SwaraChangeEvent.dart';
import 'package:carnaticapp/util.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/pitch_result.dart';
import 'package:provider/provider.dart';

class PlayedSong {
  List<(double, double)> _freqAndTimes = [];

  PlayedSong();

  void addFreq(double freq, double time) {
    _freqAndTimes.add((freq, time));
  }
}


class GradeNote {
  CarnaticNote _targetNote;
  int _targetOctave;
  double _numBeats;

  GradeNote(this._targetNote, this._targetOctave, this._numBeats);

  

  int halfStepsOff(PitchResult res, int activeShruti, int tonicOctave) {
    int octave = getOctave(truncDouble(res.expectedFrequency, 2));
    int relHalfs = relativeHalfSteps(octave, res.note, activeShruti, tonicOctave);

    int relative = wrap(relHalfs);

    int carnaticOctave;

    double tOctave = relHalfs / 12;
    if (tOctave < 0) {
      carnaticOctave = tOctave.floor();
    } else {
      carnaticOctave = tOctave.toInt();
    }

    int halfStepsDeviated = relative - _targetNote.relative;

    int octaveOffset = carnaticOctave - _targetOctave;

    halfStepsDeviated += octaveOffset*12;

    return halfStepsDeviated;
  }
}

class CarnaticSongIterator implements Iterator<SwaraNote> {
  final CarnaticSong _song;
  int _currentBlockIndex = 0;
  int _currentLineIndex = 0;
  int _currentSwaraIndex = 0;

  late SwaraNote _current;

  CarnaticSongIterator(this._song) {
    int blockIndex = _song.playOrder[_currentBlockIndex];
    SongBlock block = _song.blocks[blockIndex];
    int lineIndex = block.playOrder[_currentLineIndex];
    SongLine line = _song.lines[lineIndex];
    SwaraNote swara = line.swara[_currentSwaraIndex];

    _current = swara;
  }
  
  @override

  SwaraNote get current => _current;
  
  @override
  bool moveNext() {

    if (_currentBlockIndex >= _song.playOrder.length) return false;

    int blockIndex = _song.playOrder[_currentBlockIndex];
    SongBlock block = _song.blocks[blockIndex];

    if (_currentLineIndex >= block.playOrder.length) {
      _currentLineIndex = 0;
      _currentSwaraIndex = 0;
      _currentBlockIndex++;
      return moveNext();
    }

    int lineIndex = block.playOrder[_currentLineIndex];
    SongLine line = _song.lines[lineIndex];

    if (_currentSwaraIndex >= line.swara.length) {
      _currentSwaraIndex = 0;
      _currentLineIndex++;
      return moveNext();
    }

    SwaraNote swara = line.swara[_currentSwaraIndex];
    _currentSwaraIndex++;
    _current = swara;
    return true;
  }
}

class GradeSong {
  final CarnaticSong _song;
  final double _bpm;
  final int _activeShruti;
  final int _tonicOctave;

  GradeSong(this._song, this._bpm, this._activeShruti, this._tonicOctave);

  //This will return an array of cents off for each time (time, centsoff)
  Future<List<(double, double?)>> gradeSongNoteTempoAlignment(PlayedSong p, PitchHandler pHandler) async {
    CarnaticSongIterator iterator = _song.getIterator();
    List<(double, double?)> timeAndCentsOff = [];
    int i = 0;
    double duration = 0;

    SwaraNote? currentSwara = iterator.current;
    while (currentSwara != null) {
      if (currentSwara.isBreak) {
        iterator.moveNext();
        currentSwara = iterator.current;
        continue; // Skip break lines
      }

      double newDuration = duration + (currentSwara.beats * 60) / _bpm;

      while (i < p._freqAndTimes.length && p._freqAndTimes[i].$2 <= newDuration) {
        PitchResult res = await pHandler.handlePitch(p._freqAndTimes[i].$1);
        double putTime = p._freqAndTimes[i].$2;

        if (putTime < duration) putTime = duration;

        if (res.expectedFrequency == 0.0) {
          timeAndCentsOff.add((putTime, null));
        } else {
          int halfStepsDeviated = relativeHalfSteps(
            getOctave(truncDouble(res.expectedFrequency, 2)),
            res.note,
            _activeShruti,
            _tonicOctave,
          ) - noteMap[currentSwara.note]!;

          double totalCentsOff = res.diffCents + halfStepsDeviated * 100;
          timeAndCentsOff.add((putTime, totalCentsOff));
        }

        ++i;
      }

      duration = newDuration;
      iterator.moveNext();
      currentSwara = iterator.current;
    }

    return timeAndCentsOff;
  }

}

class SwaraNote {
  final String note; // e.g., "S", "R", "G", etc.
  final int octave; // Octave number
  final bool isBreak; // Indicates if this is a special break note
  final double beats; // Duration in number of beats
  final bool isSlide; // Indicates if this note is a slide
  final bool isShake; // Indicates if this note is a shake
  final bool isExtension; // Indicates if this note is an extension
  final SwaraNote? swaraParentNote; //Parent for extensions
  late double noExtensionBeats; // Beats without extensions

  List<SwaraExtension> extensions = []; // List of extensions for this note

  SwaraNote(
    this.note, {
    required this.octave,
    this.isBreak = false,
    required this.beats,
    this.isSlide = false,
    this.isShake = false,
    this.isExtension = false,
    this.swaraParentNote,
  }) {

    if (isExtension || isBreak) {
      return; // No extensions for break or extension notes
    }

    double numBeatsD = beats;

    int numBeats;
    int divFactor;
    if ((numBeatsD - numBeatsD.toInt()).abs() == 0.25) {
      numBeats = (numBeatsD * 4).toInt();
      divFactor = 4;
    } else if ((numBeatsD - numBeatsD.toInt()).abs() == 0.5) {
      numBeats = (numBeatsD * 2).toInt();
      divFactor = 2;
    } else {
      numBeats = numBeatsD.toInt();
      divFactor = 1;
    }

    numBeats--;

    final numSemicolons = numBeats ~/ 2;
    final numCommas = numBeats % 2;

    for (int i = 0; i < numSemicolons; i++) {
      extensions.add(
        SwaraExtension(symbol: ";", beats: 2.0/divFactor),
      );
    }
    for (int i = 0; i < numCommas; i++) {
      extensions.add(
        SwaraExtension(symbol: ",", beats: 1.0/divFactor),
      );
    }

    if (numBeats > 0) {
      noExtensionBeats = numBeatsD - (numSemicolons * 2.0/divFactor) - (numCommas * 1.0/divFactor);
    } else {
      noExtensionBeats = numBeatsD;
    }
  }
}

class SwaraExtension {
  final String symbol;
  final double beats;

  SwaraExtension({
    required this.symbol,
    required this.beats,
  });
}

class SongLine {
  final List<SwaraNote> swara; // Array of SwaraNote instances
  final List<String> sahitya; // Array of sahitya strings

  //names arguments swara and sahitya
  SongLine({
    required this.swara,
    required this.sahitya,
  });

}

class SongBlock {
  final String? name; // Name of the block, e.g., "Pallavi", "Anupallavi"
  final String? groupName; // Group name for categorization eg "ettugade swara"
  final List<int> renderOrder; // Indices of lines for rendering
  final List<int> playOrder; // Indices of lines for playback

  SongBlock({
    this.name,
    this.groupName,
    required this.renderOrder,
    required this.playOrder,
  });
}

class CarnaticSong {
  final String name; // Name of the song
  final String raga; // Raga of the song
  final String tala; // Tala of the song
  final double bpm; // Beats per minute
  final String sahityaFull; // Full sahitya text
  final List<SongLine> lines; // List of SongLine instances
  final List<SongBlock> blocks; // List of SongBlock instances
  final List<int> playOrder; // Order of block indices for playback
  final List<int> renderOrder; // Order of block indices for rendering

  CarnaticSong({
    required this.name,
    required this.raga,
    required this.tala,
    required this.bpm,
    required this.sahityaFull,
    required this.lines,
    required this.blocks,
    required this.playOrder,
    required this.renderOrder,
  });

  CarnaticSongIterator getIterator() {
    return CarnaticSongIterator(this);
  }
}

