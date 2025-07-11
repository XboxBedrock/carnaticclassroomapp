import 'package:carnaticapp/events/EventBus.dart';
import 'package:carnaticapp/events/SwaraChangeEvent.dart';
import 'package:flutter/material.dart';
import 'package:carnaticapp/grading.dart';

class SwaraWidget extends StatefulWidget {
  final SwaraNote swaraNote;
  final SwaraNote? parentSwaraNote;
  final int? extensionIndex;
  final String? lineText;
  final double baseFontSize;
  final double screenHeight;

  const SwaraWidget({
    Key? key,
    required this.swaraNote,
    required this.baseFontSize,
    this.lineText,
    required this.screenHeight,
    this.parentSwaraNote,
    this.extensionIndex = -1, // Default to -1 if not provided	
  }) : super(key: key);

  @override
  _SwaraWidgetState createState() => _SwaraWidgetState();
}

class _SwaraWidgetState extends State<SwaraWidget> {
  bool _cursorVisible = false;
  bool _highlighted = false;

  void processNotification(SwaraChangeEvent notification) {
    if (notification.extensionIndex >= 0) {
      if (notification.swaraNote == widget.parentSwaraNote && 
          notification.extensionIndex == widget.extensionIndex) {
        setState(() {
          _cursorVisible = notification.cursorVisible;
          _highlighted = notification.highlighted;
        });
      }
    }
    else if (notification.swaraNote == widget.swaraNote) {
      setState(() {
        _cursorVisible = notification.cursorVisible;
        _highlighted = notification.highlighted;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    eventBus.on<SwaraChangeEvent>().listen(processNotification);
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: widget.baseFontSize * 0.8,
          height: widget.baseFontSize * 1.5,
          alignment: Alignment.center,
          child: Text(
            widget.swaraNote.note,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.baseFontSize,
              fontWeight: FontWeight.bold,
              color: _highlighted ? Colors.blue : Colors.black,
            ),
          ),
        ),
        if (widget.lineText != null)
          Positioned(
            bottom: -widget.baseFontSize * 0.9,
            child: Text(
              widget.lineText!,
              style: TextStyle(fontSize: widget.baseFontSize * 0.6, color: Colors.grey),
            ),
          ),
        if (widget.swaraNote.octave != 0)
          Positioned(
            top: widget.swaraNote.octave > 0 ? -widget.baseFontSize * 0.004 : null,
            bottom: widget.swaraNote.octave < 0 ? -widget.baseFontSize * 0.004 : null,
            child: Row(
              children: List.generate(
                widget.swaraNote.octave.abs(),
                (_) => Icon(Icons.square, size: widget.baseFontSize * 0.2),
              ),
            ),
          ),
        if (_cursorVisible)
          Positioned(
            right: -widget.baseFontSize * 0.3,
            top: widget.screenHeight * 0.0004,
            bottom: widget.screenHeight * 0.0004,
            child: Container(
              width: 2,
              color: Colors.yellow, // Cursor visibility toggle
            ),
          ),
        if (widget.swaraNote.beats - widget.swaraNote.beats.toInt() == 0.5)
          Positioned(
            top: -widget.baseFontSize * 0.15,
            child: Container(
              width: widget.baseFontSize * 1.5,
              height: widget.baseFontSize * 0.05,
              color: Colors.black,
            ),
          )
        else if (widget.swaraNote.beats - widget.swaraNote.beats.toInt() == 0.25) ...[
          Positioned(
            top: -widget.baseFontSize * 0.15,
            child: Container(
              width: widget.baseFontSize,
              height: widget.baseFontSize * 0.05,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: -widget.baseFontSize * 0.35,
            child: Container(
              width: widget.baseFontSize,
              height: widget.baseFontSize * 0.05,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }
}
