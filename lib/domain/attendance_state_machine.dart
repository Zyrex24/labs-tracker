import '../core/utils/date_utils.dart';
import 'attendance_state.dart';

/// Pure state machine for attendance status transitions
class AttendanceStateMachine {
  /// Determine current status based on session time and window
  static AttendanceStatus determineStatus({
    required DateTime plannedAt,
    required int windowHours,
    required AttendanceStatus currentStatus,
  }) {
    // If already in a terminal or progressed state, keep it
    if (_isTerminalState(currentStatus)) {
      return currentStatus;
    }
    
    // Check if within window
    if (AppDateUtils.isWithinWindow(plannedAt, windowHours)) {
      return AttendanceStatus.due;
    }
    
    // Before window
    if (AppDateUtils.isFuture(plannedAt)) {
      return AttendanceStatus.notReady;
    }
    
    // After window and not marked - consider missed
    if (AppDateUtils.isPast(plannedAt) && currentStatus == AttendanceStatus.notReady) {
      return AttendanceStatus.missed;
    }
    
    return currentStatus;
  }
  
  /// Check if a status is terminal (won't auto-change)
  static bool _isTerminalState(AttendanceStatus status) {
    return status == AttendanceStatus.attended ||
           status == AttendanceStatus.missed ||
           status == AttendanceStatus.sickPending ||
           status == AttendanceStatus.sickSubmitted ||
           status == AttendanceStatus.makeupScheduled ||
           status == AttendanceStatus.makeupAttended;
  }
  
  /// Validate if transition is allowed
  static bool canTransition({
    required AttendanceStatus from,
    required AttendanceStatus to,
  }) {
    return switch ((from, to)) {
      // From due
      (AttendanceStatus.due, AttendanceStatus.attended) => true,
      (AttendanceStatus.due, AttendanceStatus.missed) => true,
      (AttendanceStatus.due, AttendanceStatus.sickPending) => true,
      
      // From missed
      (AttendanceStatus.missed, AttendanceStatus.sickPending) => true,
      
      // From sick_pending
      (AttendanceStatus.sickPending, AttendanceStatus.sickSubmitted) => true,
      
      // From makeup_scheduled
      (AttendanceStatus.makeupScheduled, AttendanceStatus.makeupAttended) => true,
      
      // Allow reverting some states for corrections
      (AttendanceStatus.attended, AttendanceStatus.due) => true,
      (AttendanceStatus.missed, AttendanceStatus.due) => true,
      
      _ => false,
    };
  }
  
  /// Calculate eligibility for a subject
  static bool isEligible({
    required int attendedCount,
    required int makeupAttendedCount,
    required int labsRequired,
  }) {
    return (attendedCount + makeupAttendedCount) >= labsRequired;
  }
  
  /// Get remaining labs needed
  static int remainingLabs({
    required int attendedCount,
    required int makeupAttendedCount,
    required int labsRequired,
  }) {
    final completed = attendedCount + makeupAttendedCount;
    return labsRequired > completed ? labsRequired - completed : 0;
  }
}

