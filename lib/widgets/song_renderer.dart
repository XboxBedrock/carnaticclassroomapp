import 'dart:math';
import 'package:carnaticapp/events/SwaraChangeEvent.dart';
import 'package:flutter/material.dart';
import 'package:carnaticapp/grading.dart';
import 'package:carnaticapp/widgets/swara_widget.dart';

class SongRenderer extends StatefulWidget {
  final CarnaticSong song;
  final bool showInvisibleCursor; // Toggle for invisible cursor

  const SongRenderer({
    Key? key,
    required this.song,
    this.showInvisibleCursor = true, // Default cursor visibility
  }) : super(key: key);

  @override
  _SongRendererState createState() => _SongRendererState();
}

class _SongRendererState extends State<SongRenderer> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseFontSize = screenWidth * 0.05;

    return SingleChildScrollView( // Add vertical scrolling
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.song.name,
            style: TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.bold),
          ),
          Text(
            "Ragam: ${widget.song.raga}",
            style: TextStyle(fontSize: baseFontSize * 0.75),
          ),
          Text(
            "Talam: ${widget.song.tala}",
            style: TextStyle(fontSize: baseFontSize * 0.75),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...widget.song.blocks.map((block) =>
              _renderBlock(context, block, widget.song.lines, baseFontSize, screenHeight)),
        ],
      ),
    );
  }

  Widget _renderBlock(
    BuildContext context,
    SongBlock block,
    List<SongLine> lines,
    double baseFontSize,
    double screenHeight,
  ) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final lineSpacing = isPortrait ? screenHeight * 0.04 : screenHeight * 0.12;

    final blockLines = block.renderOrder.map((i) => lines[i]).toList();

    final expandedLines = blockLines.map((line) {
      final cells = <Widget>[];
      int sahityaCounter = 0;
      for (var swara in line.swara) {
        final widgets = _renderSwara(
          swara,
          sahityaCounter,
          line,
          baseFontSize,
          screenHeight,
          -1
        );
        cells.addAll(widgets);
        sahityaCounter = cells.length;
        if (swara.isBreak) sahityaCounter--;
      }
      return cells;
    }).toList();

    final maxCols = expandedLines
        .map((cells) => cells.length)
        .fold<int>(0, (prev, len) => max(prev, len));

    final rowHeight = lineSpacing * 2.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.name != null)
          Text(
            block.name!,
            style: TextStyle(
              fontSize: baseFontSize * 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: lineSpacing),
        Table(
          columnWidths: {
            for (int c = 0; c < maxCols; c++) c: const FlexColumnWidth(1),
          },
          children: [
            for (var cells in expandedLines)
              TableRow(
                children: [
                  for (var w in cells)
                    Stack(
                      children: [
                        SizedBox(
                          height: rowHeight,
                          child: Center(child: w),
                        ),
                      ],
                    ),
                  for (int i = cells.length; i < maxCols; i++)
                    SizedBox(height: rowHeight),
                ],
              ),
          ],
        ),
        SizedBox(height: lineSpacing * 0.5),
      ],
    );
  }

  List<Widget> _beatExtensions(
    SwaraNote swara,
    int sahityaIndex,
    SongLine? line,
    double baseFontSize,
    double screenHeight,
  ) {
    final widgets = <Widget>[];


    for (int i = 0; i < swara.extensions.length; i++) {
      widgets.addAll(_renderSwara(
        SwaraNote(swara.extensions[i].symbol, octave: 0, beats: swara.beats, isBreak: false, isSlide: swara.isSlide, isShake: swara.isShake, isExtension: true, swaraParentNote: swara),
        sahityaIndex + i + 1,
        line,
        baseFontSize,
        screenHeight,
        i // Pass the extension index
      ));
    }
    return widgets;
  }

  List<Widget> _renderSwara(
    SwaraNote swara,
    int sahityaIndex,
    SongLine? line,
    double baseFontSize,
    double screenHeight,
    int extensionIndex // Default to -1 if not provided
  ) {
    final widgets = <Widget>[];

    final mainWidget = 
    SwaraWidget(
      swaraNote: swara,
      lineText: line?.sahitya != null && sahityaIndex < line!.sahitya.length && !swara.isBreak
          ? line.sahitya[sahityaIndex]
          : null,
      baseFontSize: baseFontSize,
      screenHeight: screenHeight,
      parentSwaraNote: swara.swaraParentNote,
      extensionIndex: extensionIndex // Only set
    );


    widgets.add(mainWidget);

    // if this is _not_ already an extension marker, add any beat-extensions too
    if (!swara.isExtension) {
      widgets.addAll(_beatExtensions(swara, sahityaIndex, line, baseFontSize, screenHeight));
    } 

    return widgets;
  }
}
