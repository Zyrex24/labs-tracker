import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sick_notes_dao.g.dart';

@DriftAccessor(tables: [SickNotes])
class SickNotesDao extends DatabaseAccessor<AppDatabase> with _$SickNotesDaoMixin {
  SickNotesDao(AppDatabase db) : super(db);

  // Get sick note by session ID
  Future<SickNote?> getSickNoteBySession(String labSessionId) {
    return (select(sickNotes)..where((tbl) => tbl.labSessionId.equals(labSessionId)))
        .getSingleOrNull();
  }

  // Get all sick notes
  Future<List<SickNote>> getAllSickNotes() => select(sickNotes).get();

  // Get sick notes by state
  Future<List<SickNote>> getSickNotesByState(String state) {
    return (select(sickNotes)..where((tbl) => tbl.state.equals(state))).get();
  }

  // Insert sick note
  Future<void> insertSickNote(SickNotesCompanion sickNote) {
    return into(sickNotes).insert(sickNote);
  }

  // Update sick note
  Future<void> updateSickNote(SickNote sickNote) {
    return update(sickNotes).replace(sickNote);
  }

  // Update sick note state
  Future<void> updateSickNoteState(String id, String state) {
    return (update(sickNotes)..where((tbl) => tbl.id.equals(id)))
        .write(SickNotesCompanion(state: Value(state)));
  }

  // Delete sick note
  Future<void> deleteSickNote(String id) {
    return (delete(sickNotes)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Watch sick note by session
  Stream<SickNote?> watchSickNoteBySession(String labSessionId) {
    return (select(sickNotes)..where((tbl) => tbl.labSessionId.equals(labSessionId)))
        .watchSingleOrNull();
  }

  // Watch all sick notes
  Stream<List<SickNote>> watchAllSickNotes() => select(sickNotes).watch();
}

