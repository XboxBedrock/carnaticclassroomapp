import 'package:flutter/material.dart';
import 'package:carnaticapp/grading.dart';

class SongRenderer extends StatelessWidget {
  final CarnaticSong song;

  const SongRenderer({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Ragam: ${song.raga}",
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          "Talam: ${song.tala}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...song.blocks.map((block) => _renderBlock(block, song.lines)),
      ],
    );
  }

  Widget _renderBlock(SongBlock block, List<SongLine> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.name != null)
          Text(
            block.name!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        ...block.renderOrder.map((lineIndex) => _renderLine(lines[lineIndex])),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _renderLine(SongLine line) {
    List<Widget> swaraWidgets = [];
    for (SwaraNote swara in line.swara) {
      if (swara.isBreak) {
        swaraWidgets.add(const SizedBox(width: double.infinity)); // Line break
      } else {
        swaraWidgets.addAll(_renderSwara(swara));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: swaraWidgets
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: line.sahitya.map((sahitya) {
              return Text(
                sahitya,
                style: const TextStyle(fontSize: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _beatExtensions(SwaraNote swara) {
      List<Widget> widgets = [];
      //One thing is that the lines above will compensate for quarter and eight
      //complete rewrite to r
      double numBeatsD = swara.beats;
      double divFactor = 1.0;
      if (numBeatsD == 0) return [];
      int numBeats;
      if (numBeatsD-numBeatsD.toInt() == 0.25) {
        numBeats = (numBeatsD * 4).toInt();
        divFactor = 4.0;
      } else if (numBeatsD-numBeatsD.toInt() == 0.5) {
        numBeats = (numBeatsD * 2).toInt();
        divFactor = 2.0;
      } else {
        numBeats = numBeatsD.toInt();
      }

      if (numBeats <= 1) return [];
      int numSemicolons = numBeats ~/ 2;
      int numCommas = numBeats % 2;

      for (int i = 0; i < numSemicolons; i++) {
        widgets.add(_renderSwara(SwaraNote(";", octave: 0, beats: swara.beats, isBreak: false, isSlide: swara.isSlide, isShake: swara.isShake, isExtension: true))[0]);
      }
      for (int i = 0; i < numCommas; i++) {
        widgets.add(_renderSwara(SwaraNote(",", octave: 0, beats: swara.beats, isBreak: false, isSlide: swara.isSlide, isShake: swara.isShake, isExtension: true))[0]);
      }
      return widgets;
  }

  List<Widget> _renderSwara(SwaraNote swara) {
    List<Widget> widgets = [];
    // we want to be able to render the dot above or below the swara based on the octave
    //We have to add semicolons for the swara note when beat is more than 1, this will be grouped with semicolons being two beats and commas being one beat
    Widget mainReturn = Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              // these extensions should probably be displayed as if they are seperate notes in their own
              // right now they are just displayed as a continuation of the note
              swara.note,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: swara.isSlide ? Colors.blue : Colors.black,
              ),
            ),
            if (swara.octave > 0)
              Positioned(
                top: -1,
                child: const Icon(Icons.square, size: 4, color: Colors.black),
              ),
            if (swara.octave < 0)
              Positioned(
                bottom: -1,
                child: const Icon(Icons.square, size: 4, color: Colors.black),
              ),
              //also gotta draw line above for notes that end in .5 and double line for ending in .25 swara numbeats
              if (swara.beats-swara.beats.toInt() == 0.5) ...[
                Positioned(
                  top: -5,
                  //line that spans full letterbox and spacing, not icon just line
                  child: Container(
                    width: 20,
                    height: 2,
                    color: Colors.black,
                  )
                  
                ),
              ] else if (swara.beats-swara.beats.toInt() == 0.25) ...[
                Positioned(
                  top: -5,
                  child: Container(
                    width: 20,
                    height: 2,
                    color: Colors.black,
                  )
                ),
                Positioned(
                    top: -9,
                    child: Container(
                    width: 20,
                    height: 2,
                    color: Colors.black,
                  )
                ),
              ]
          ],
    );

    widgets.add(mainReturn);

    if (!swara.isExtension) {
      // if the swara is an extension, we add the beat extensions
      // these are the semicolons and commas that represent the beats
      _beatExtensions(swara).forEach((widget) {
        widgets.add(widget);
      });
    }

    return widgets;



  }
}
