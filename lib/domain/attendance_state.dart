/// Attendance status enum
enum AttendanceStatus {
  notReady('not_ready'),
  due('due'),
  attended('attended'),
  missed('missed'),
  sickPending('sick_pending'),
  sickSubmitted('sick_submitted'),
  makeupScheduled('makeup_scheduled'),
  makeupAttended('makeup_attended');

  final String value;
  const AttendanceStatus(this.value);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceStatus.notReady,
    );
  }
}

/// Lab session type enum
enum SessionType {
  regular('regular'),
  makeup('makeup');

  final String value;
  const SessionType(this.value);

  static SessionType fromString(String value) {
    return SessionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionType.regular,
    );
  }
}

/// Sick note state enum
enum SickNoteState {
  pending('pending'),
  submitted('submitted'),
  rejected('rejected');

  final String value;
  const SickNoteState(this.value);

  static SickNoteState fromString(String value) {
    return SickNoteState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SickNoteState.pending,
    );
  }
}

