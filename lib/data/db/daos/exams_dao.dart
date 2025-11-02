import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'exams_dao.g.dart';

@DriftAccessor(tables: [Exams])
class ExamsDao extends DatabaseAccessor<AppDatabase> with _$ExamsDaoMixin {
  ExamsDao(AppDatabase db) : super(db);

  // Get all exams
  Future<List<Exam>> getAllExams() {
    return (select(exams)..orderBy([(tbl) => OrderingTerm.asc(tbl.examDate)])).get();
  }

  // Get exams by subject
  Future<List<Exam>> getExamsBySubject(String subjectId) {
    return (select(exams)..where((tbl) => tbl.subjectId.equals(subjectId))).get();
  }

  // Get exam by ID
  Future<Exam?> getExamById(String id) {
    return (select(exams)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Insert exam
  Future<void> insertExam(ExamsCompanion exam) {
    return into(exams).insert(exam);
  }

  // Update exam
  Future<void> updateExam(Exam exam) {
    return update(exams).replace(exam);
  }

  // Update exam with companion
  Future<void> updateExamCompanion(ExamsCompanion companion) {
    return (update(exams)..where((tbl) => tbl.id.equals(companion.id.value))).write(companion);
  }

  // Toggle registered status
  Future<void> toggleRegistered(String id, bool registered) {
    return (update(exams)..where((tbl) => tbl.id.equals(id)))
        .write(ExamsCompanion(registered: Value(registered ? 1 : 0)));
  }

  // Delete exam
  Future<void> deleteExam(String id) {
    return (delete(exams)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Watch all exams
  Stream<List<Exam>> watchAllExams() {
    return (select(exams)..orderBy([(tbl) => OrderingTerm.asc(tbl.examDate)])).watch();
  }

  // Watch exams by subject
  Stream<List<Exam>> watchExamsBySubject(String subjectId) {
    return (select(exams)..where((tbl) => tbl.subjectId.equals(subjectId))).watch();
  }
}

