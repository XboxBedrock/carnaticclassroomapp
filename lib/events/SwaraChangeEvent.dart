import 'package:carnaticapp/grading.dart';
import 'package:flutter/material.dart';

class SwaraChangeEvent extends Notification {
  final bool cursorVisible;
  final bool highlighted;
  final int extensionIndex;
  final SwaraNote swaraNote;

  const SwaraChangeEvent( 
    this.cursorVisible,
    this.highlighted,
    this.extensionIndex,
    this.swaraNote,
  );
}