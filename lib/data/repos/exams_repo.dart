import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../db/app_database.dart';

class ExamsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ExamsRepository(this._db);

  // Get all exams
  Future<Result<List<Exam>>> getAllExams() async {
    try {
      final exams = await _db.examsDao.getAllExams();
      return Success(exams);
    } catch (e) {
      return Failure('Failed to get exams: $e');
    }
  }

  // Get exams by subject
  Future<Result<List<Exam>>> getExamsBySubject(String subjectId) async {
    try {
      final exams = await _db.examsDao.getExamsBySubject(subjectId);
      return Success(exams);
    } catch (e) {
      return Failure('Failed to get exams: $e');
    }
  }

  // Get exam by ID
  Future<Result<Exam>> getExamById(String id) async {
    try {
      final exam = await _db.examsDao.getExamById(id);
      if (exam == null) {
        return const Failure('Exam not found');
      }
      return Success(exam);
    } catch (e) {
      return Failure('Failed to get exam: $e');
    }
  }

  // Create exam
  Future<Result<String>> createExam({
    required String subjectId,
    required DateTime examDate,
    bool registered = false,
  }) async {
    try {
      final id = _uuid.v4();
      await _db.examsDao.insertExam(
        ExamsCompanion.insert(
          id: id,
          subjectId: subjectId,
          examDate: AppDateUtils.toIso8601(examDate),
          registered: registered ? 1 : 0,
        ),
      );
      return Success(id);
    } catch (e) {
      return Failure('Failed to create exam: $e');
    }
  }

  // Update exam
  Future<Result<void>> updateExam(
    String id, {
    DateTime? examDate,
    bool? registered,
  }) async {
    try {
      final exam = await _db.examsDao.getExamById(id);
      if (exam == null) {
        return const Failure('Exam not found');
      }

      final updated = ExamsCompanion(
        id: Value(id),
        examDate: examDate != null ? Value(AppDateUtils.toIso8601(examDate)) : const Value.absent(),
        registered: registered != null ? Value(registered ? 1 : 0) : const Value.absent(),
      );

      await _db.examsDao.updateExamCompanion(updated);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update exam: $e');
    }
  }

  // Delete exam
  Future<Result<void>> deleteExam(String id) async {
    try {
      await _db.examsDao.deleteExam(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete exam: $e');
    }
  }

  // Watch all exams
  Stream<List<Exam>> watchAllExams() {
    return _db.examsDao.watchAllExams();
  }

  // Watch exams by subject
  Stream<List<Exam>> watchExamsBySubject(String subjectId) {
    return _db.examsDao.watchExamsBySubject(subjectId);
  }
}

