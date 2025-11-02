import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [Attendance])
class AttendanceDao extends DatabaseAccessor<AppDatabase> with _$AttendanceDaoMixin {
  AttendanceDao(AppDatabase db) : super(db);

  // Get attendance by session ID
  Future<AttendanceData?> getAttendanceBySession(String labSessionId) {
    return (select(attendance)..where((tbl) => tbl.labSessionId.equals(labSessionId)))
        .getSingleOrNull();
  }

  // Get all attendance records
  Future<List<AttendanceData>> getAllAttendance() => select(attendance).get();

  // Insert attendance
  Future<void> insertAttendance(AttendanceCompanion attendanceRecord) {
    return into(attendance).insert(attendanceRecord);
  }

  // Update attendance
  Future<void> updateAttendance(AttendanceData attendanceRecord) {
    return update(attendance).replace(attendanceRecord);
  }

  // Update attendance status
  Future<void> updateAttendanceStatus(String labSessionId, String status, String updatedAt) {
    return (update(attendance)..where((tbl) => tbl.labSessionId.equals(labSessionId)))
        .write(AttendanceCompanion(
      status: Value(status),
      updatedAt: Value(updatedAt),
    ));
  }

  // Delete attendance
  Future<void> deleteAttendance(String id) {
    return (delete(attendance)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Watch attendance by session
  Stream<AttendanceData?> watchAttendanceBySession(String labSessionId) {
    return (select(attendance)..where((tbl) => tbl.labSessionId.equals(labSessionId)))
        .watchSingleOrNull();
  }

  // Get attendance count by status
  Future<int> countAttendanceByStatus(String status) async {
    final query = selectOnly(attendance)
      ..addColumns([attendance.id.count()])
      ..where(attendance.status.equals(status));
    final result = await query.getSingleOrNull();
    return result?.read(attendance.id.count()) ?? 0;
  }
}

