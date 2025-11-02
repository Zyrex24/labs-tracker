import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../data/repos/attendance_repo.dart';
import '../../domain/attendance_state_machine.dart';

class SummaryScreen extends HookConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(watchAllSubjectsProvider);
    final examsAsync = ref.watch(watchAllExamsProvider);
    final isGeneratingPdf = useState(false);

    return GlassScaffold(
      title: 'Summary',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isGeneratingPdf.value
            ? null
            : () async {
                isGeneratingPdf.value = true;
                try {
                  await _generateAndSharePdf(context, ref);
                } finally {
                  isGeneratingPdf.value = false;
                }
              },
        backgroundColor: Colors.white.withOpacity(0.2),
        icon: Icon(
          Icons.picture_as_pdf_rounded,
          color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
        ),
        label: Text(
          'Export PDF',
          style: TextStyle(
            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall summary header
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester Summary',
                    style: GlassTheme.titleLarge.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your lab attendance and exam status',
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Per-subject stats
            subjectsAsync.when(
              data: (subjects) {
                if (subjects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No subjects added yet',
                        style: GlassTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: subjects.map((subject) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectStatsCard(subject: subject),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Exams summary
            examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return const SizedBox.shrink();
                }

                final registeredCount = exams.where((e) => e.registered == 1).length;

                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Exams',
                            style: GlassTheme.titleMedium.copyWith(
                              color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Total',
                            value: exams.length.toString(),
                          ),
                          _StatItem(
                            label: 'Registered',
                            value: registeredCount.toString(),
                          ),
                          _StatItem(
                            label: 'Pending',
                            value: (exams.length - registeredCount).toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSharePdf(BuildContext context, WidgetRef ref) async {
    try {
      final subjects = await ref.read(subjectsRepoProvider).getAllSubjects();
      if (subjects.isFailure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load subjects')),
          );
        }
        return;
      }

      final exams = await ref.read(examsRepoProvider).getAllExams();
      final attendanceRepo = ref.read(attendanceRepoProvider);

      final pdf = pw.Document();

      // Build PDF content
      final subjectStats = <Subject, SubjectStats>{};
      for (final subject in subjects.valueOrNull ?? []) {
        final stats = await attendanceRepo.calculateSubjectStats(subject.id);
        if (stats.isSuccess) {
          subjectStats[subject] = stats.valueOrNull!;
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Labs Tracker - Semester Summary',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated: ${AppDateUtils.formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 24),

                // Subjects
                pw.Text(
                  'Subjects',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),

                ...subjectStats.entries.map((entry) {
                  final subject = entry.key;
                  final stats = entry.value;
                  final totalAttended = stats.attended + stats.makeupAttended;
                  final isEligible = AttendanceStateMachine.isEligible(
                    attendedCount: stats.attended,
                    makeupAttendedCount: stats.makeupAttended,
                    labsRequired: subject.labsRequired,
                  );
                  final remaining = AttendanceStateMachine.remainingLabs(
                    attendedCount: stats.attended,
                    makeupAttendedCount: stats.makeupAttended,
                    labsRequired: subject.labsRequired,
                  );

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${subject.code} - ${subject.name}',
                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: isEligible ? PdfColors.green100 : PdfColors.red100,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              ),
                              child: pw.Text(
                                isEligible ? 'ELIGIBLE' : 'INELIGIBLE',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: isEligible ? PdfColors.green900 : PdfColors.red900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            _pdfStatItem('Attended', totalAttended.toString()),
                            _pdfStatItem('Required', subject.labsRequired.toString()),
                            _pdfStatItem('Remaining', remaining.toString()),
                            _pdfStatItem('Missed', stats.missed.toString()),
                            _pdfStatItem('Sick Notes', stats.sickNotes.toString()),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 24),

                // Exams
                if (exams.isSuccess && (exams.valueOrNull ?? []).isNotEmpty) ...[
                  pw.Text(
                    'Exams',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _pdfTableCell('Subject', isHeader: true),
                          _pdfTableCell('Date', isHeader: true),
                          _pdfTableCell('Status', isHeader: true),
                        ],
                      ),
                      ...(exams.valueOrNull ?? []).map((exam) {
                        final subject = (subjects.valueOrNull ?? []).firstWhere(
                          (s) => s.id == exam.subjectId,
                          orElse: () => Subject(id: '', name: 'Unknown', code: '', labsRequired: 0),
                        );
                        final examDate = AppDateUtils.fromIso8601(exam.examDate);
                        return pw.TableRow(
                          children: [
                            _pdfTableCell(subject.code),
                            _pdfTableCell(AppDateUtils.formatDate(examDate)),
                            _pdfTableCell(exam.registered == 1 ? 'Registered' : 'Not Registered'),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );

      // Share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'labs_tracker_summary_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  pw.Widget _pdfStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

class _SubjectStatsCard extends HookConsumerWidget {
  final Subject subject;

  const _SubjectStatsCard({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = useMemoized(
      () => ref.read(attendanceRepoProvider).calculateSubjectStats(subject.id),
      [subject.id],
    );
    final statsFuture = useFuture(statsAsync);

    if (statsFuture.data == null) {
      return const GlassCard(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
      );
    }

    final result = statsFuture.data!;
    if (result.isFailure) {
      return GlassCard(
        child: Text(
          'Error loading stats',
          style: TextStyle(
            color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
          ),
        ),
      );
    }

    final stats = result.valueOrNull!;
    final totalAttended = stats.attended + stats.makeupAttended;
    final isEligible = AttendanceStateMachine.isEligible(
      attendedCount: stats.attended,
      makeupAttendedCount: stats.makeupAttended,
      labsRequired: subject.labsRequired,
    );
    final remaining = AttendanceStateMachine.remainingLabs(
      attendedCount: stats.attended,
      makeupAttendedCount: stats.makeupAttended,
      labsRequired: subject.labsRequired,
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: GlassTheme.titleMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.code,
                      style: GlassTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isEligible ? const Color(0x2E4CD964) : const Color(0x2EFF3B30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEligible ? const Color(0xA64CD964) : const Color(0xA6FF3B30),
                  ),
                ),
                child: Text(
                  isEligible ? 'ELIGIBLE' : 'INELIGIBLE',
                  style: GlassTheme.caption.copyWith(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Attended', value: totalAttended.toString()),
              _StatItem(label: 'Required', value: subject.labsRequired.toString()),
              _StatItem(label: 'Remaining', value: remaining.toString()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Missed', value: stats.missed.toString()),
              _StatItem(label: 'Sick Notes', value: stats.sickNotes.toString()),
              _StatItem(label: 'Make-ups', value: stats.makeups.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GlassTheme.titleLarge.copyWith(
            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GlassTheme.caption.copyWith(
            color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
          ),
        ),
      ],
    );
  }
}

