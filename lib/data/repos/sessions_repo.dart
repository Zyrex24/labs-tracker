import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/attendance_state.dart';
import '../db/app_database.dart';

class SessionsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SessionsRepository(this._db);

  // Get all sessions
  Future<Result<List<LabSession>>> getAllSessions() async {
    try {
      final sessions = await _db.sessionsDao.getAllSessions();
      return Success(sessions);
    } catch (e) {
      return Failure('Failed to get sessions: $e');
    }
  }

  // Get sessions by subject
  Future<Result<List<LabSession>>> getSessionsBySubject(String subjectId) async {
    try {
      final sessions = await _db.sessionsDao.getSessionsBySubject(subjectId);
      return Success(sessions);
    } catch (e) {
      return Failure('Failed to get sessions: $e');
    }
  }

  // Get session by ID
  Future<Result<LabSession>> getSessionById(String id) async {
    try {
      final session = await _db.sessionsDao.getSessionById(id);
      if (session == null) {
        return const Failure('Session not found');
      }
      return Success(session);
    } catch (e) {
      return Failure('Failed to get session: $e');
    }
  }

  // Create session
  Future<Result<String>> createSession({
    required String subjectId,
    required DateTime plannedAt,
    String? slot,
    String? location,
    SessionType type = SessionType.regular,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final attendanceId = _uuid.v4();
      
      // Insert session
      await _db.sessionsDao.insertSession(
        LabSessionsCompanion.insert(
          id: sessionId,
          subjectId: subjectId,
          plannedAt: AppDateUtils.toIso8601(plannedAt),
          slot: Value(slot),
          location: Value(location),
          type: type.value,
        ),
      );
      
      // Create attendance record
      await _db.attendanceDao.insertAttendance(
        AttendanceCompanion.insert(
          id: attendanceId,
          labSessionId: sessionId,
          status: AttendanceStatus.notReady.value,
          updatedAt: AppDateUtils.toIso8601(DateTime.now()),
        ),
      );
      
      return Success(sessionId);
    } catch (e) {
      return Failure('Failed to create session: $e');
    }
  }

  // Update session
  Future<Result<void>> updateSession(
    String id, {
    DateTime? plannedAt,
    String? slot,
    String? location,
  }) async {
    try {
      final session = await _db.sessionsDao.getSessionById(id);
      if (session == null) {
        return const Failure('Session not found');
      }
      
      final updated = LabSessionsCompanion(
        id: Value(id),
        plannedAt: plannedAt != null ? Value(AppDateUtils.toIso8601(plannedAt)) : const Value.absent(),
        slot: slot != null ? Value(slot) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
      );
      
      await _db.sessionsDao.updateSessionCompanion(updated);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update session: $e');
    }
  }

  // Delete session
  Future<Result<void>> deleteSession(String id) async {
    try {
      await _db.sessionsDao.deleteSession(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete session: $e');
    }
  }

  // Get upcoming sessions
  Future<Result<List<LabSession>>> getUpcomingSessions() async {
    try {
      final now = AppDateUtils.toIso8601(DateTime.now());
      final sessions = await _db.sessionsDao.getUpcomingSessions(now);
      return Success(sessions);
    } catch (e) {
      return Failure('Failed to get upcoming sessions: $e');
    }
  }

  // Watch all sessions
  Stream<List<LabSession>> watchAllSessions() {
    return _db.sessionsDao.watchAllSessions();
  }

  // Watch sessions by subject
  Stream<List<LabSession>> watchSessionsBySubject(String subjectId) {
    return _db.sessionsDao.watchSessionsBySubject(subjectId);
  }
}

