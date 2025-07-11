import 'dart:isolate';
import 'dart:async';
import 'dart:typed_data';

import 'package:carnaticapp/events/EventBus.dart';
import 'package:carnaticapp/grading.dart';
import 'package:carnaticapp/events/SwaraChangeEvent.dart';
import 'package:carnaticapp/raga.dart';
import 'package:carnaticapp/song.dart';
import 'package:carnaticapp/song_player.dart';
import 'package:carnaticapp/util.dart';
import 'package:dart_melty_soundfont/array_int16.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:fftea/fftea.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/pitch_result.dart';
import 'package:carnaticapp/widgets/song_renderer.dart';
import 'package:carnaticapp/songs/varavina.dart';

const int tSampleRate = 44100;
const int tBufferSize = 3000;

final pitchDetectorDart = PitchDetector(
  audioSampleRate: tSampleRate + 0.0,
  bufferSize: tBufferSize,
);

void main() {
  runApp(const MyApp());
}

Future<double?> _audioProcess(List<double> audioSample) async {
  final pitchDetectorRes = await pitchDetectorDart.getPitchFromFloatBuffer(
    audioSample,
  );
  if (pitchDetectorRes.pitched) {
    return pitchDetectorRes.pitch;
  } else {
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  int _numSamples = 0;
  final FlutterAudioCapture _plugin = FlutterAudioCapture();
  final pitchUp = PitchHandler(InstrumentType.guitar);

  bool _pcmSoundLoaded = false;
  bool _isPlaying = false;

  CarnaticSongPlayed? currentPlayingSession;

  SongPlayer? player;

  //temporary violin measures
  int activeShruti = 3;
  int tonicOctave = 4;

  @override
  void initState() {
    super.initState();
    // Need to initialize before use note that this is async!
    _plugin.init();

    _registerRagas();

    // Load the PCM sound setup
    _loadPcmSound().then((_) {
      _pcmSoundLoaded = true;
      setState(() {});
    });
  }

  void _registerRagas() {
    RagaRegistry.registerRaga(mohanam);
  }

  Future<void> _loadPcmSound() async {
    FlutterPcmSound.setFeedCallback(onFeed);
    await FlutterPcmSound.setLogLevel(LogLevel.standard);
    await FlutterPcmSound.setFeedThreshold(1);
    await FlutterPcmSound.setup(sampleRate: tSampleRate, channelCount: 1);
  }

  Future<void> listener(dynamic obj) async {
    var buffer = Float64List.fromList(obj.cast<double>());
    _numSamples += buffer.length;
    final List<double> audioSample = buffer.toList();

    final pitch = await compute(_audioProcess, audioSample);

    final pitchRes = (pitch != null) ? await pitchUp.handlePitch(pitch) : null;

    if (currentPlayingSession != null) {
      if (pitchRes != null &&
          pitchRes.expectedFrequency.roundToDouble() != 0.0 &&
          pitch != null) {
        currentPlayingSession?.addSample(pitch, _numSamples);
      } else {
        currentPlayingSession?.sendNullNoteSignal(_numSamples);
      }
    }
  }

  void _debugPrint() {
    //print(currentPlayingSession);
    //List<GradeNote> song = [GradeNote(relatives[0][0], 0, 1), GradeNote(relatives[1][0], 0, 1)];
    //GradeSong gradeSong = GradeSong(varavina, 60, activeShruti, tonicOctave);

    //var gradeable = await currentPlayingSession?.gradeify();

    //if (gradeable != null) {
    //  print(await gradeSong.gradeSongNoteTempoAlignment(gradeable, pitchUp));
    //}

    eventBus.fire(SwaraChangeEvent(true, true, 0, varavina.lines[0].swara[0]));

    print("dpatch");
  }

  void onError(Object e) {
    print(e);
  }

  void onFeed(int remainingFrames) async {
    if (!_isPlaying) {
      // If we are already playing, we don't need to do anything
      return;
    }

    if (player != null) {
      var data = player!.getNextBuffer();
      ArrayInt16? buf = data.$1;
      (SwaraNote, double)? swaraData = data.$2;

      //start a process for timed cursor events on swaranote
      if (swaraData != null) {
        // Fire an event with the swara data
        print(
          "Firing swara change event: ${swaraData.$1.note} at time ${swaraData.$2}",
        );
        eventBus.fire(SwaraChangeEvent(true, false, -1, swaraData.$1));

        double timeForOneBeat = (swaraData.$2 * 1000) / swaraData.$1.beats;
        //expiry
        Timer(
          Duration(
            milliseconds: (swaraData.$1.noExtensionBeats * timeForOneBeat)
                .round(),
          ),
          () {
            eventBus.fire(SwaraChangeEvent(false, true, -1, swaraData.$1));
          },
        );

        int idx = 0;

        double accumulatedTime = swaraData.$1.noExtensionBeats * timeForOneBeat;

        print (swaraData.$1.extensions);

        for (SwaraExtension se in swaraData.$1.extensions) {

          int currentIndex = idx;


          //highlight
          Timer(
            Duration(
              milliseconds: (accumulatedTime)
                  .round(),
            ),
            () {
              eventBus.fire(SwaraChangeEvent(true, false, currentIndex, swaraData.$1));

            },
          );

          //unhighlight
          Timer(
            Duration(
              milliseconds: (se.beats * timeForOneBeat + accumulatedTime)
                  .round(),
            ),
            () {
              eventBus.fire(SwaraChangeEvent(false, true, currentIndex, swaraData.$1));
            },
          );

          idx++;
          
          accumulatedTime += (se.beats * timeForOneBeat);
        }
      }
      if (buf != null) {
        print("Buffer length: ${buf.bytes.lengthInBytes}");
        // Feed the buffer to the PCM sound
        //run the next line async

        FlutterPcmSound.feed(PcmArrayInt16(bytes: buf.bytes));
      } else {
        // If no buffer is available, stop the player
        _isPlaying = false;
      }
    }
  }

  Future<void> _startRecord() async {
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // _counter without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.

    //currentPlayingSession = CarnaticSongPlayed(activeShruti, tonicOctave, tSampleRate);
    //_numSamples = 0;

    //await _plugin.start(
    //  listener,
    //  onError,
    //  sampleRate: tSampleRate,
    //  bufferSize: tBufferSize,
    //);

    player = SongPlayer(varavina, activeShruti, tonicOctave, 60);

    _isPlaying = true;

    await player!.playSong();

    print(_pcmSoundLoaded);

    print(player?.getBufferLength());

    FlutterPcmSound.start();
  }

  Future<void> _stopRecord() async {
    _isPlaying = false;
    //await _plugin.stop();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _startRecord,
              tooltip: 'Increment',
              child: const Text("Start"),
            ),
            FloatingActionButton(
              onPressed: _stopRecord,
              tooltip: 'Increment',
              child: const Text("Stop"),
            ),
            FloatingActionButton(
              onPressed: _debugPrint,
              tooltip: 'Increment',
              child: const Text("Debug Print"),
            ),
            SongRenderer(song: varavina),
          ],
        ),
      ),
    );
  }
}
