import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/resume/data/models/resume_models.dart';

/// ATS-Friendly PDF Export Service
///
/// This service generates PDFs optimized for Applicant Tracking Systems (ATS):
/// - Single-column layout (no tables or complex structures)
/// - Standard fonts (Roboto family)
/// - Clear section headers in UPPERCASE
/// - Plain text bullet points with • character
/// - Metadata for better parsing
/// - No headers/footers that could confuse ATS
/// - Contact info as plain text at the top
/// - Consistent date formatting
class ExportService {
  static Future<void> exportToPdf(ResumeModel resume, bool isAtsView) async {
    // Load fonts with Unicode support
    final robotoRegular = await PdfGoogleFonts.robotoRegular();
    final robotoBold = await PdfGoogleFonts.robotoBold();
    final robotoItalic = await PdfGoogleFonts.robotoItalic();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: robotoRegular,
        bold: robotoBold,
        italic: robotoItalic,
      ),
      // Add metadata for ATS parsing
      title: resume.title.isNotEmpty ? resume.title : 'Resume',
      author: _extractAuthorName(resume),
      subject: 'Professional Resume',
      keywords: _extractKeywords(resume),
      creator: 'ResuMate - ATS Resume Builder',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        // No header/footer for ATS compatibility
        header: null,
        footer: null,
        build: (context) {
          return resume.sections.map((section) {
            return _buildPdfSection(section);
          }).toList();
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${resume.title.isNotEmpty ? resume.title : 'Resume'}.pdf',
    );
  }

  /// Extract author name from header section
  static String _extractAuthorName(ResumeModel resume) {
    for (final section in resume.sections) {
      if (section.type == SectionType.header && section.headerData != null) {
        return section.headerData!.fullName;
      }
    }
    return 'Job Seeker';
  }

  /// Extract keywords from skills for metadata
  static String _extractKeywords(ResumeModel resume) {
    final keywords = <String>[];
    for (final section in resume.sections) {
      if (section.type == SectionType.skills && section.skillData != null) {
        keywords.addAll(section.skillData!.map((s) => s.name));
      }
    }
    return keywords.join(', ');
  }

  static pw.Widget _buildPdfSection(SectionModel section) {
    if (!section.isVisible) return pw.SizedBox();

    switch (section.type) {
      case SectionType.header:
        return _buildHeader(section.headerData ?? HeaderModel());
      case SectionType.summary:
        return _buildSummary(section);
      case SectionType.workExperience:
        return _buildExperience(section);
      case SectionType.projects:
        return _buildProjects(section);
      case SectionType.education:
        return _buildEducation(section);
      case SectionType.skills:
        return _buildSkills(section);
      case SectionType.certifications:
      case SectionType.languages:
        return _buildListSection(section);
      default:
        return pw.SizedBox();
    }
  }

  /// Build ATS-optimized header with contact info as plain text
  static pw.Widget _buildHeader(HeaderModel data) {
    final contactItems = <String>[];
    if (data.email.isNotEmpty) contactItems.add(data.email);
    if (data.phoneNumber.isNotEmpty) contactItems.add(data.phoneNumber);
    if (data.location.isNotEmpty) contactItems.add(data.location);

    final linkItems = <String>[];
    if (data.linkedin.isNotEmpty) linkItems.add(data.linkedin);
    if (data.github.isNotEmpty) linkItems.add(data.github);
    if (data.website.isNotEmpty) linkItems.add(data.website);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Name - prominent and centered
        pw.Text(
          data.fullName.toUpperCase(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        pw.SizedBox(height: 4),

        // Job title
        if (data.jobTitle.isNotEmpty)
          pw.Text(
            data.jobTitle,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 12),
          ),
        pw.SizedBox(height: 8),

        // Contact info - plain text, separated by pipes for ATS
        if (contactItems.isNotEmpty)
          pw.Text(
            contactItems.join('  |  '),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10),
          ),

        // Links - plain text URLs for ATS parsing
        if (linkItems.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            linkItems.join('  |  '),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],

        pw.SizedBox(height: 12),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Build professional summary section
  static pw.Widget _buildSummary(SectionModel section) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          section.summaryData ?? '',
          style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// Build work experience section with ATS-friendly bullet points
  static pw.Widget _buildExperience(SectionModel section) {
    final experiences = section.experienceData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...experiences.map(
          (exp) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Role and dates on same line
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        exp.role,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatDateRange(
                        exp.startDate,
                        exp.endDate,
                        exp.isCurrent,
                      ),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),

                // Company and location
                pw.Text(
                  exp.location.isNotEmpty
                      ? '${exp.company}, ${exp.location}'
                      : exp.company,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 4),

                // Bullet points - using • for ATS compatibility
                ...exp.descriptionPoints.map(
                  (point) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2, left: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(
                            point,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              lineSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build projects section
  static pw.Widget _buildProjects(SectionModel section) {
    final projects = section.projectData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...projects.map(
          (proj) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Project name
                pw.Text(
                  proj.name,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),

                // Role if present
                if (proj.role.isNotEmpty)
                  pw.Text(
                    proj.role,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),

                // Description
                if (proj.description.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    proj.description,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],

                // Technologies as comma-separated list
                if (proj.technologies.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Technologies: ${proj.technologies.join(', ')}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],

                // Bullet points
                if (proj.descriptionPoints.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  ...proj.descriptionPoints.map(
                    (point) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2, left: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '• ',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              point,
                              style: const pw.TextStyle(
                                fontSize: 10,
                                lineSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build education section
  static pw.Widget _buildEducation(SectionModel section) {
    final education = section.educationData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...education.map(
          (edu) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        edu.degree.isNotEmpty
                            ? '${edu.degree}${edu.fieldOfStudy.isNotEmpty ? ' in ${edu.fieldOfStudy}' : ''}'
                            : edu.fieldOfStudy,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatDateRange(edu.startDate, edu.endDate, false),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Text(
                  edu.institution,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (edu.gpa.isNotEmpty)
                  pw.Text(
                    'GPA: ${edu.gpa}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                if (edu.description.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(
                      edu.description,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build skills section - comma-separated for ATS parsing
  static pw.Widget _buildSkills(SectionModel section) {
    final skills = section.skillData ?? [];

    // Group skills by level if levels are provided
    final skillNames = skills
        .map((s) => s.name)
        .where((n) => n.isNotEmpty)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          skillNames.join('  •  '),
          style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// Build generic list section (certifications, languages)
  static pw.Widget _buildListSection(SectionModel section) {
    final items = section.listData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          items.join('  •  '),
          style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// Build section title with UPPERCASE for ATS readability
  static pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 6),
      ],
    );
  }

  /// Format date range consistently for ATS
  static String _formatDateRange(String start, String end, bool isCurrent) {
    if (start.isEmpty && end.isEmpty) return '';
    if (isCurrent || end.toLowerCase() == 'present') {
      return '$start - Present';
    }
    return '$start - $end';
  }
}
