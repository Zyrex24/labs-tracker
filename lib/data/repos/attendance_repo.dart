import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/attendance_state.dart';
import '../../domain/attendance_state_machine.dart';
import '../db/app_database.dart';

class AttendanceRepository {
  final AppDatabase _db;

  AttendanceRepository(this._db);

  // Get attendance by session
  Future<Result<AttendanceData>> getAttendanceBySession(String labSessionId) async {
    try {
      final attendance = await _db.attendanceDao.getAttendanceBySession(labSessionId);
      if (attendance == null) {
        return const Failure('Attendance not found');
      }
      return Success(attendance);
    } catch (e) {
      return Failure('Failed to get attendance: $e');
    }
  }

  // Update attendance status
  Future<Result<void>> updateAttendanceStatus({
    required String labSessionId,
    required AttendanceStatus status,
  }) async {
    try {
      final updatedAt = AppDateUtils.toIso8601(DateTime.now());
      await _db.attendanceDao.updateAttendanceStatus(
        labSessionId,
        status.value,
        updatedAt,
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update attendance: $e');
    }
  }

  // Mark attended
  Future<Result<void>> markAttended(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.attended,
    );
  }

  // Mark missed
  Future<Result<void>> markMissed(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.missed,
    );
  }

  // Mark sick pending
  Future<Result<void>> markSickPending(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.sickPending,
    );
  }

  // Mark sick submitted
  Future<Result<void>> markSickSubmitted(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.sickSubmitted,
    );
  }

  // Mark makeup scheduled
  Future<Result<void>> markMakeupScheduled(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.makeupScheduled,
    );
  }

  // Mark makeup attended
  Future<Result<void>> markMakeupAttended(String labSessionId) async {
    return updateAttendanceStatus(
      labSessionId: labSessionId,
      status: AttendanceStatus.makeupAttended,
    );
  }

  // Get attendance count by status
  Future<Result<int>> countAttendanceByStatus(AttendanceStatus status) async {
    try {
      final count = await _db.attendanceDao.countAttendanceByStatus(status.value);
      return Success(count);
    } catch (e) {
      return Failure('Failed to count attendance: $e');
    }
  }

  // Watch attendance by session
  Stream<AttendanceData?> watchAttendanceBySession(String labSessionId) {
    return _db.attendanceDao.watchAttendanceBySession(labSessionId);
  }

  // Calculate subject stats
  Future<Result<SubjectStats>> calculateSubjectStats(String subjectId) async {
    try {
      // Get all sessions for subject
      final sessions = await _db.sessionsDao.getSessionsBySubject(subjectId);
      
      int attended = 0;
      int missed = 0;
      int sickNotes = 0;
      int makeups = 0;
      int makeupAttended = 0;
      
      for (final session in sessions) {
        final attendance = await _db.attendanceDao.getAttendanceBySession(session.id);
        if (attendance != null) {
          final status = AttendanceStatus.fromString(attendance.status);
          switch (status) {
            case AttendanceStatus.attended:
              attended++;
              break;
            case AttendanceStatus.missed:
              missed++;
              break;
            case AttendanceStatus.sickSubmitted:
              sickNotes++;
              break;
            case AttendanceStatus.makeupScheduled:
              makeups++;
              break;
            case AttendanceStatus.makeupAttended:
              makeupAttended++;
              break;
            default:
              break;
          }
        }
      }
      
      return Success(SubjectStats(
        attended: attended,
        missed: missed,
        sickNotes: sickNotes,
        makeups: makeups,
        makeupAttended: makeupAttended,
      ));
    } catch (e) {
      return Failure('Failed to calculate stats: $e');
    }
  }
}

class SubjectStats {
  final int attended;
  final int missed;
  final int sickNotes;
  final int makeups;
  final int makeupAttended;

  SubjectStats({
    required this.attended,
    required this.missed,
    required this.sickNotes,
    required this.makeups,
    required this.makeupAttended,
  });
}

