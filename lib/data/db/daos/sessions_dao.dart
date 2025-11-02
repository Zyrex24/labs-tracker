import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [LabSessions])
class SessionsDao extends DatabaseAccessor<AppDatabase> with _$SessionsDaoMixin {
  SessionsDao(AppDatabase db) : super(db);

  // Get all sessions
  Future<List<LabSession>> getAllSessions() => select(labSessions).get();

  // Get sessions by subject
  Future<List<LabSession>> getSessionsBySubject(String subjectId) {
    return (select(labSessions)..where((tbl) => tbl.subjectId.equals(subjectId))).get();
  }

  // Get session by ID
  Future<LabSession?> getSessionById(String id) {
    return (select(labSessions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get sessions by type
  Future<List<LabSession>> getSessionsByType(String type) {
    return (select(labSessions)..where((tbl) => tbl.type.equals(type))).get();
  }

  // Get upcoming sessions
  Future<List<LabSession>> getUpcomingSessions(String currentDateTime) {
    return (select(labSessions)
          ..where((tbl) => tbl.plannedAt.isBiggerOrEqualValue(currentDateTime))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.plannedAt)]))
        .get();
  }

  // Insert session
  Future<void> insertSession(LabSessionsCompanion session) {
    return into(labSessions).insert(session);
  }

  // Update session
  Future<void> updateSession(LabSession session) {
    return update(labSessions).replace(session);
  }

  // Update session with companion
  Future<void> updateSessionCompanion(LabSessionsCompanion companion) {
    return (update(labSessions)..where((tbl) => tbl.id.equals(companion.id.value))).write(companion);
  }

  // Delete session
  Future<void> deleteSession(String id) {
    return (delete(labSessions)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Watch all sessions
  Stream<List<LabSession>> watchAllSessions() {
    return (select(labSessions)..orderBy([(tbl) => OrderingTerm.asc(tbl.plannedAt)])).watch();
  }

  // Watch sessions by subject
  Stream<List<LabSession>> watchSessionsBySubject(String subjectId) {
    return (select(labSessions)
          ..where((tbl) => tbl.subjectId.equals(subjectId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.plannedAt)]))
        .watch();
  }
}

