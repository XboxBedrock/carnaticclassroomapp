import 'package:carnaticapp/util.dart';

class RagaRegistry {
  static final Map<String, Raga> _ragaMap = {};
  
  static void registerRaga(Raga raga) {
    _ragaMap[raga.name] = raga;
  }

  static Raga? getRaga(String name) {
    return _ragaMap[name];
  }

  static List<Raga> getAllRagas() {
    return _ragaMap.values.toList();
  }
}

class Raga {
  final String name;
  final String description;
  final List<CarnaticNote> notes;

  Raga(this.name, this.description, this.notes);

  @override
  String toString() {
    return 'Raga{name: $name, description: $description, notes: $notes}';
  }

  CarnaticNote getNoteByName(String noteName) {
    return notes.firstWhere((note) => note.note == noteName, orElse: () => CarnaticNote('Unknown', 0, "unknown", null));
  }
}