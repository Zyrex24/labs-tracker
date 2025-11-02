import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/attendance_state.dart';
import '../db/app_database.dart';
import '../storage/file_service.dart';

class SickNotesRepository {
  final AppDatabase _db;
  final FileService _fileService;
  final _uuid = const Uuid();

  SickNotesRepository(this._db, this._fileService);

  // Get sick note by session
  Future<Result<SickNote>> getSickNoteBySession(String labSessionId) async {
    try {
      final sickNote = await _db.sickNotesDao.getSickNoteBySession(labSessionId);
      if (sickNote == null) {
        return const Failure('Sick note not found');
      }
      return Success(sickNote);
    } catch (e) {
      return Failure('Failed to get sick note: $e');
    }
  }

  // Create sick note with file
  Future<Result<String>> createSickNote({
    required String labSessionId,
    required String sourceFilePath,
  }) async {
    try {
      final id = _uuid.v4();
      final extension = _fileService.getFileExtension(sourceFilePath);
      final newFileName = '$id$extension';
      
      // Copy file to attachments
      final copyResult = await _fileService.copyFileToAttachments(
        sourceFilePath,
        newFileName,
      );
      
      if (copyResult is Failure) {
        return Failure(copyResult.message);
      }
      
      final filePath = (copyResult as Success<String>).value;
      
      // Insert sick note
      await _db.sickNotesDao.insertSickNote(
        SickNotesCompanion.insert(
          id: id,
          labSessionId: labSessionId,
          state: SickNoteState.submitted.value,
          filePath: Value(filePath),
          submittedAt: Value(AppDateUtils.toIso8601(DateTime.now())),
        ),
      );
      
      return Success(id);
    } catch (e) {
      return Failure('Failed to create sick note: $e');
    }
  }

  // Update sick note state
  Future<Result<void>> updateSickNoteState(String id, SickNoteState state) async {
    try {
      await _db.sickNotesDao.updateSickNoteState(id, state.value);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update sick note: $e');
    }
  }

  // Delete sick note
  Future<Result<void>> deleteSickNote(String id) async {
    try {
      // Get sick note to delete file
      final sickNote = await _db.sickNotesDao.getSickNoteBySession(id);
      if (sickNote?.filePath != null) {
        await _fileService.deleteFile(sickNote!.filePath!);
      }
      
      await _db.sickNotesDao.deleteSickNote(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete sick note: $e');
    }
  }

  // Watch sick note by session
  Stream<SickNote?> watchSickNoteBySession(String labSessionId) {
    return _db.sickNotesDao.watchSickNoteBySession(labSessionId);
  }

  // Watch all sick notes
  Stream<List<SickNote>> watchAllSickNotes() {
    return _db.sickNotesDao.watchAllSickNotes();
  }
}

