import 'package:carnaticapp/grading.dart';
import 'package:carnaticapp/raga.dart';
import 'package:carnaticapp/util.dart';
import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class SongPlayer {
  CarnaticSong _song;
  late CarnaticSongIterator _iterator;
  int _activeShruti;
  int _tonicOctave;
  int _bpm;
  late Raga _raga;

  List<ArrayInt16> _buffer = [];
  List<(SwaraNote, double)> _swaraOrder = [];

  late Synthesizer _synth;

  SongPlayer(this._song, this._activeShruti, this._tonicOctave, this._bpm) {
    _iterator = CarnaticSongIterator(_song);
    _raga = RagaRegistry.getRaga(_song.raga) ?? 
            Raga("Unknown", "Unknown", [CarnaticNote("Sa", 0, "s", null)]);
  }

  int getBufferLength() {
    return _buffer.length;
  }

  Future<void> playSong() async {
    ByteData bytes = await rootBundle.load('assets/violin.sf2');

    _synth = Synthesizer.loadByteData(bytes, 
    SynthesizerSettings(
        sampleRate: 44100, 
        blockSize: 64, 
        maximumPolyphony: 64, 
        enableReverbAndChorus: true,
    ));

    _synth.selectPreset(channel: 0, preset: 0);

    //_buffer.add(buf16);
    await _startBufferingThread().then((value) {
      _buffer = value._buffer;
      _swaraOrder = value._swaraOrder;
    });

    print("Buffer length 1: ${_buffer.length}");

  }

  static ArrayInt16 _playSwaraProcessing(int note, int octave, int tonicOctave, int activeShruti, double duration, Synthesizer _synth) {

    ArrayInt16 buf16 = ArrayInt16.zeros(numShorts: (44100 * duration).toInt());

    // Convert to global pitch
    int globalPitch = note + (tonicOctave * 12) + (octave * 12) + activeShruti;

    print("Playing note: $globalPitch, octave: $octave, duration: $duration");

    _synth.noteOn(channel: 0, key: globalPitch, velocity: 120);

    _synth.renderMonoInt16(buf16);

    _synth.noteOff(channel: 0, key: globalPitch);

    return buf16;
  }

  static SongPlayer _renderAllSwaras(SongPlayer s) {
    bool first = true;
    while (first || s._iterator.moveNext()) {
      SwaraNote? swara = s._iterator.current;
      // If the swara is null, we can skip it

      if (swara != null) {
        ArrayInt16 buf16 = _playSwaraProcessing(
          s._raga.getNoteByName(swara.note).relative,
          swara.octave,
          s._tonicOctave,
          s._activeShruti,
          swara.beats / (s._bpm / 60),
          s._synth,
        );

        if (buf16.bytes.lengthInBytes > 0) {
            s._swaraOrder.add((swara, swara.beats / (s._bpm / 60)));
            s._buffer.add(buf16);
          }


        
        first = false;
      }

      
    }

    return s;
  }

  Future<SongPlayer> _startBufferingThread() async {

    print("Starting to render all swaras in a new process");
    //start the render all swaras in a new process

    return compute(_renderAllSwaras, this);
  }

  (ArrayInt16?, (SwaraNote, double)?) getNextBuffer() {
    print("Getting next buffer from player");
    if (_buffer.isNotEmpty) {
      ArrayInt16 nextBuffer = _buffer.removeAt(0);
      while (_iterator.current.beats == 0 && _iterator.moveNext()) {
        // Skip swaras with zero beats
      }
      (SwaraNote, double) nextSwara = (_iterator.current, _swaraOrder.removeAt(0).$2);
      _iterator.moveNext(); // Move to the next swara for the next call

      return (nextBuffer, nextSwara);
      // Process the next buffer, e.g., send it to an audio player
      // For example:
      // audioPlayer.play(nextBuffer);
    } else {
      // Handle the case when there are no more buffers to play
      return (null, null);
    }
  }


  void reset() {
    _iterator = CarnaticSongIterator(_song);
  }




}