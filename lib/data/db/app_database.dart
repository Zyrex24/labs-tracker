import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import '../../core/constants/app_constants.dart';
import 'tables.dart';
import 'daos/users_dao.dart';
import 'daos/subjects_dao.dart';
import 'daos/sessions_dao.dart';
import 'daos/attendance_dao.dart';
import 'daos/sick_notes_dao.dart';
import 'daos/exams_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Subjects,
    LabSessions,
    Attendance,
    SickNotes,
    Exams,
  ],
  daos: [
    UsersDao,
    SubjectsDao,
    SessionsDao,
    AttendanceDao,
    SickNotesDao,
    ExamsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Seed default user
        await into(users).insert(
          UsersCompanion.insert(
            id: AppConstants.defaultUserId,
            name: AppConstants.defaultUserName,
            semester: AppConstants.defaultSemester,
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          // Example migration: add colorHex column to subjects
          await m.addColumn(subjects, subjects.colorHex);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
        if (details.wasCreated) {
          // Database was just created
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    
    // Setup sqlite3 for Android
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    // Make sqlite3 pick a more suitable location for temporary files
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    
    return NativeDatabase.createInBackground(file);
  });
}

