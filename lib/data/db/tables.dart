import 'package:drift/drift.dart';

// Users table - single local profile
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get semester => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Subjects table
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text().withLength(min: 1, max: 16)();
  IntColumn get labsRequired => integer()();
  TextColumn get colorHex => text().nullable()(); // v2 migration example
  
  @override
  Set<Column> get primaryKey => {id};
}

// Lab sessions table
class LabSessions extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get plannedAt => text()(); // ISO8601
  TextColumn get slot => text().nullable()(); // e.g., "Morning", "Afternoon"
  TextColumn get location => text().nullable()();
  TextColumn get type => text()(); // 'regular' or 'makeup'
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [];
}

// Attendance table
class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get labSessionId => text()();
  TextColumn get status => text()(); // not_ready, due, attended, missed, sick_pending, sick_submitted, makeup_scheduled, makeup_attended
  TextColumn get note => text().nullable()();
  TextColumn get updatedAt => text()(); // ISO8601
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {labSessionId}, // One attendance record per session
  ];
}

// Sick notes table
class SickNotes extends Table {
  TextColumn get id => text()();
  TextColumn get labSessionId => text()();
  TextColumn get state => text()(); // pending, submitted, rejected
  TextColumn get filePath => text().nullable()();
  TextColumn get submittedAt => text().nullable()(); // ISO8601
  
  @override
  Set<Column> get primaryKey => {id};
}

// Exams table
class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get examDate => text()(); // ISO8601
  IntColumn get registered => integer()(); // 0 or 1 (boolean)
  
  @override
  Set<Column> get primaryKey => {id};
}

