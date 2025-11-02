import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../db/app_database.dart';
import '../storage/file_service.dart';

class BackupRepository {
  final AppDatabase _db;
  final FileService _fileService;

  BackupRepository(this._db, this._fileService);

  /// Export all data to a ZIP file
  Future<Result<String>> exportBackup() async {
    try {
      // Create temp directory for export
      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory(p.join(tempDir.path, 'labs_tracker_export_${DateTime.now().millisecondsSinceEpoch}'));
      await exportDir.create(recursive: true);

      // Create attachments directory
      final attachmentsDir = Directory(p.join(exportDir.path, 'attachments'));
      await attachmentsDir.create();

      // Export database data
      final data = await _exportDatabaseData();
      final dataFile = File(p.join(exportDir.path, 'data.json'));
      await dataFile.writeAsString(jsonEncode(data));

      // Copy attachments
      await _copyAttachments(attachmentsDir);

      // Create ZIP
      final zipPath = p.join(tempDir.path, 'labs_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addDirectory(exportDir);
      encoder.close();

      // Clean up temp export directory
      await exportDir.delete(recursive: true);

      return Success(zipPath);
    } catch (e) {
      return Failure('Failed to export backup: $e');
    }
  }

  /// Share backup ZIP file
  Future<Result<void>> shareBackup(String zipPath) async {
    try {
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Labs Tracker Backup',
        text: 'Backup created on ${AppDateUtils.formatDate(DateTime.now())}',
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to share backup: $e');
    }
  }

  /// Import data from a ZIP file
  Future<Result<void>> importBackup(String zipPath) async {
    try {
      // Create temp directory for import
      final tempDir = await getTemporaryDirectory();
      final importDir = Directory(p.join(tempDir.path, 'labs_tracker_import_${DateTime.now().millisecondsSinceEpoch}'));
      await importDir.create(recursive: true);

      // Extract ZIP
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(p.join(importDir.path, filename));
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        }
      }

      // Read data.json
      final dataFile = File(p.join(importDir.path, 'data.json'));
      if (!await dataFile.exists()) {
        return const Failure('Invalid backup file: data.json not found');
      }

      final jsonString = await dataFile.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Import data in a transaction
      await _importDatabaseData(data);

      // Copy attachments to app directory
      final attachmentsDir = Directory(p.join(importDir.path, 'attachments'));
      if (await attachmentsDir.exists()) {
        await _importAttachments(attachmentsDir);
      }

      // Clean up temp import directory
      await importDir.delete(recursive: true);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to import backup: $e');
    }
  }

  /// Export database data to JSON
  Future<Map<String, dynamic>> _exportDatabaseData() async {
    final users = await _db.usersDao.getAllUsers();
    final subjects = await _db.subjectsDao.getAllSubjects();
    final sessions = await _db.sessionsDao.getAllSessions();
    final attendance = await _db.attendanceDao.getAllAttendance();
    final sickNotes = await _db.sickNotesDao.getAllSickNotes();
    final exams = await _db.examsDao.getAllExams();

    return {
      'version': 1,
      'exportedAt': AppDateUtils.toIso8601(DateTime.now()),
      'users': users.map((u) => _userToJson(u)).toList(),
      'subjects': subjects.map((s) => _subjectToJson(s)).toList(),
      'lab_sessions': sessions.map((s) => _sessionToJson(s)).toList(),
      'attendance': attendance.map((a) => _attendanceToJson(a)).toList(),
      'sick_notes': sickNotes.map((s) => _sickNoteToJson(s)).toList(),
      'exams': exams.map((e) => _examToJson(e)).toList(),
    };
  }

  /// Import database data from JSON
  Future<void> _importDatabaseData(Map<String, dynamic> data) async {
    await _db.transaction(() async {
      // Clear existing data
      await _db.delete(_db.users).go();
      await _db.delete(_db.subjects).go();
      await _db.delete(_db.labSessions).go();
      await _db.delete(_db.attendance).go();
      await _db.delete(_db.sickNotes).go();
      await _db.delete(_db.exams).go();

      // Import users
      if (data['users'] != null) {
        for (final userJson in data['users']) {
          await _db.usersDao.insertUser(_userFromJson(userJson));
        }
      }

      // Import subjects
      if (data['subjects'] != null) {
        for (final subjectJson in data['subjects']) {
          await _db.subjectsDao.insertSubject(_subjectFromJson(subjectJson));
        }
      }

      // Import sessions
      if (data['lab_sessions'] != null) {
        for (final sessionJson in data['lab_sessions']) {
          await _db.sessionsDao.insertSession(_sessionFromJson(sessionJson));
        }
      }

      // Import attendance
      if (data['attendance'] != null) {
        for (final attendanceJson in data['attendance']) {
          await _db.attendanceDao.insertAttendance(_attendanceFromJson(attendanceJson));
        }
      }

      // Import sick notes
      if (data['sick_notes'] != null) {
        for (final sickNoteJson in data['sick_notes']) {
          await _db.sickNotesDao.insertSickNote(_sickNoteFromJson(sickNoteJson));
        }
      }

      // Import exams
      if (data['exams'] != null) {
        for (final examJson in data['exams']) {
          await _db.examsDao.insertExam(_examFromJson(examJson));
        }
      }
    });
  }

  /// Copy attachments to backup directory
  Future<void> _copyAttachments(Directory attachmentsDir) async {
    final sickNotes = await _db.sickNotesDao.getAllSickNotes();
    for (final sickNote in sickNotes) {
      if (sickNote.filePath != null) {
        final sourceFile = File(sickNote.filePath!);
        if (await sourceFile.exists()) {
          final filename = p.basename(sickNote.filePath!);
          final destFile = File(p.join(attachmentsDir.path, filename));
          await sourceFile.copy(destFile.path);
        }
      }
    }
  }

  /// Import attachments from backup directory
  Future<void> _importAttachments(Directory attachmentsDir) async {
    final appDir = await _fileService.getAttachmentsDirectory();
    final files = await attachmentsDir.list().toList();

    for (final file in files) {
      if (file is File) {
        final filename = p.basename(file.path);
        final destFile = File(p.join(appDir.path, filename));
        await file.copy(destFile.path);
      }
    }
  }

  // JSON serialization helpers
  Map<String, dynamic> _userToJson(User user) => {
        'id': user.id,
        'name': user.name,
        'semester': user.semester,
      };

  UsersCompanion _userFromJson(Map<String, dynamic> json) => UsersCompanion.insert(
        id: json['id'],
        name: json['name'],
        semester: json['semester'],
      );

  Map<String, dynamic> _subjectToJson(Subject subject) => {
        'id': subject.id,
        'name': subject.name,
        'code': subject.code,
        'labs_required': subject.labsRequired,
        'color_hex': subject.colorHex,
      };

  SubjectsCompanion _subjectFromJson(Map<String, dynamic> json) => SubjectsCompanion.insert(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        labsRequired: json['labs_required'],
        colorHex: Value(json['color_hex']),
      );

  Map<String, dynamic> _sessionToJson(LabSession session) => {
        'id': session.id,
        'subject_id': session.subjectId,
        'planned_at': session.plannedAt,
        'slot': session.slot,
        'location': session.location,
        'type': session.type,
      };

  LabSessionsCompanion _sessionFromJson(Map<String, dynamic> json) => LabSessionsCompanion.insert(
        id: json['id'],
        subjectId: json['subject_id'],
        plannedAt: json['planned_at'],
        slot: Value(json['slot']),
        location: Value(json['location']),
        type: json['type'],
      );

  Map<String, dynamic> _attendanceToJson(AttendanceData attendance) => {
        'id': attendance.id,
        'lab_session_id': attendance.labSessionId,
        'status': attendance.status,
        'note': attendance.note,
        'updated_at': attendance.updatedAt,
      };

  AttendanceCompanion _attendanceFromJson(Map<String, dynamic> json) => AttendanceCompanion.insert(
        id: json['id'],
        labSessionId: json['lab_session_id'],
        status: json['status'],
        note: Value(json['note']),
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> _sickNoteToJson(SickNote sickNote) => {
        'id': sickNote.id,
        'lab_session_id': sickNote.labSessionId,
        'state': sickNote.state,
        'file_path': sickNote.filePath,
        'submitted_at': sickNote.submittedAt,
      };

  SickNotesCompanion _sickNoteFromJson(Map<String, dynamic> json) => SickNotesCompanion.insert(
        id: json['id'],
        labSessionId: json['lab_session_id'],
        state: json['state'],
        filePath: Value(json['file_path']),
        submittedAt: Value(json['submitted_at']),
      );

  Map<String, dynamic> _examToJson(Exam exam) => {
        'id': exam.id,
        'subject_id': exam.subjectId,
        'exam_date': exam.examDate,
        'registered': exam.registered,
      };

  ExamsCompanion _examFromJson(Map<String, dynamic> json) => ExamsCompanion.insert(
        id: json['id'],
        subjectId: json['subject_id'],
        examDate: json['exam_date'],
        registered: json['registered'],
      );
}

