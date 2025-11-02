import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../db/app_database.dart';
import '../storage/file_service.dart';
import 'subjects_repo.dart';
import 'sessions_repo.dart';
import 'attendance_repo.dart';
import 'sick_notes_repo.dart';
import 'exams_repo.dart';
import 'backup_repo.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// File service provider
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

// Repository providers
final subjectsRepoProvider = Provider<SubjectsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SubjectsRepository(db);
});

final sessionsRepoProvider = Provider<SessionsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SessionsRepository(db);
});

final attendanceRepoProvider = Provider<AttendanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AttendanceRepository(db);
});

final sickNotesRepoProvider = Provider<SickNotesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final fileService = ref.watch(fileServiceProvider);
  return SickNotesRepository(db, fileService);
});

final examsRepoProvider = Provider<ExamsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExamsRepository(db);
});

final backupRepoProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final fileService = ref.watch(fileServiceProvider);
  return BackupRepository(db, fileService);
});

// Stream providers for watching data
final watchAllSubjectsProvider = StreamProvider<List<Subject>>((ref) {
  final repo = ref.watch(subjectsRepoProvider);
  return repo.watchAllSubjects();
});

final watchAllSessionsProvider = StreamProvider<List<LabSession>>((ref) {
  final repo = ref.watch(sessionsRepoProvider);
  return repo.watchAllSessions();
});

final watchAllExamsProvider = StreamProvider<List<Exam>>((ref) {
  final repo = ref.watch(examsRepoProvider);
  return repo.watchAllExams();
});

// Watch sessions by subject
final watchSessionsBySubjectProvider = StreamProvider.family<List<LabSession>, String>((ref, subjectId) {
  final repo = ref.watch(sessionsRepoProvider);
  return repo.watchSessionsBySubject(subjectId);
});

// Watch attendance by session
final watchAttendanceBySessionProvider = StreamProvider.family<AttendanceData?, String>((ref, sessionId) {
  final repo = ref.watch(attendanceRepoProvider);
  return repo.watchAttendanceBySession(sessionId);
});

// Watch sick note by session
final watchSickNoteBySessionProvider = StreamProvider.family<SickNote?, String>((ref, sessionId) {
  final repo = ref.watch(sickNotesRepoProvider);
  return repo.watchSickNoteBySession(sessionId);
});

// Settings provider (notification window hours)
final notificationWindowHoursProvider = StateProvider<int>((ref) => 2);

