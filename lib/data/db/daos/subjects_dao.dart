import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'subjects_dao.g.dart';

@DriftAccessor(tables: [Subjects])
class SubjectsDao extends DatabaseAccessor<AppDatabase> with _$SubjectsDaoMixin {
  SubjectsDao(AppDatabase db) : super(db);

  // Get all subjects
  Future<List<Subject>> getAllSubjects() => select(subjects).get();

  // Get subject by ID
  Future<Subject?> getSubjectById(String id) {
    return (select(subjects)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Insert subject
  Future<void> insertSubject(SubjectsCompanion subject) {
    return into(subjects).insert(subject);
  }

  // Update subject
  Future<void> updateSubject(Subject subject) {
    return update(subjects).replace(subject);
  }

  // Delete subject
  Future<void> deleteSubject(String id) {
    return (delete(subjects)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Watch all subjects
  Stream<List<Subject>> watchAllSubjects() => select(subjects).watch();

  // Watch subject by ID
  Stream<Subject?> watchSubjectById(String id) {
    return (select(subjects)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }
}

