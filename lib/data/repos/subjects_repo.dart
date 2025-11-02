import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../db/app_database.dart';

class SubjectsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SubjectsRepository(this._db);

  // Get all subjects
  Future<Result<List<Subject>>> getAllSubjects() async {
    try {
      final subjects = await _db.subjectsDao.getAllSubjects();
      return Success(subjects);
    } catch (e) {
      return Failure('Failed to get subjects: $e');
    }
  }

  // Get subject by ID
  Future<Result<Subject>> getSubjectById(String id) async {
    try {
      final subject = await _db.subjectsDao.getSubjectById(id);
      if (subject == null) {
        return const Failure('Subject not found');
      }
      return Success(subject);
    } catch (e) {
      return Failure('Failed to get subject: $e');
    }
  }

  // Create subject
  Future<Result<String>> createSubject({
    required String name,
    required String code,
    required int labsRequired,
    String? colorHex,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.subjectsDao.insertSubject(
        SubjectsCompanion.insert(
          id: id,
          name: name,
          code: code,
          labsRequired: labsRequired,
          colorHex: Value(colorHex),
        ),
      );
      return Success(id);
    } catch (e) {
      return Failure('Failed to create subject: $e');
    }
  }

  // Update subject
  Future<Result<void>> updateSubject(Subject subject) async {
    try {
      await _db.subjectsDao.updateSubject(subject);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update subject: $e');
    }
  }

  // Delete subject
  Future<Result<void>> deleteSubject(String id) async {
    try {
      await _db.subjectsDao.deleteSubject(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete subject: $e');
    }
  }

  // Watch all subjects
  Stream<List<Subject>> watchAllSubjects() {
    return _db.subjectsDao.watchAllSubjects();
  }

  // Watch subject by ID
  Stream<Subject?> watchSubjectById(String id) {
    return _db.subjectsDao.watchSubjectById(id);
  }
}

