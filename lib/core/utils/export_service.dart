import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/resume/data/models/resume_models.dart';

class ExportService {
  static Future<void> exportToPdf(ResumeModel resume, bool isAtsView) async {
    final bytes = await generatePdfBytes(resume, isAtsView);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${resume.title.isNotEmpty ? resume.title : 'Resume'}.pdf',
    );
  }

  static Future<Uint8List> generatePdfBytes(
    ResumeModel resume,
    bool isAtsView,
  ) async {
    final arabicRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/arial.ttf'),
    );
    final arabicBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/arial_bold.ttf'),
    );
    final arabicItalic = pw.Font.ttf(
      await rootBundle.load('assets/fonts/arial_italic.ttf'),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: arabicRegular,
        bold: arabicBold,
        italic: arabicItalic,
      ),
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
        build: (context) {
          return resume.sections.map((section) {
            return _buildPdfSection(section);
          }).toList();
        },
      ),
    );

    return await pdf.save();
  }

  static String _reshapeArabicText(String text) {
    return ArabicReshaper.instance.reshape(text);
  }

  static String _extractAuthorName(ResumeModel resume) {
    for (final section in resume.sections) {
      if (section.type == SectionType.header && section.headerData != null) {
        return section.headerData!.fullName;
      }
    }
    return 'Job Seeker';
  }

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
        pw.Text(
          _reshapeArabicText(data.fullName.toUpperCase()),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2,
            lineSpacing: 0.8,
            height: 0.9,
          ),
        ),
        pw.SizedBox(height: 2),
        if (data.jobTitle.isNotEmpty)
          pw.Text(
            _reshapeArabicText(data.jobTitle),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 12,
              lineSpacing: 0.8,
              height: 0.9,
            ),
          ),
        pw.SizedBox(height: 4),
        if (contactItems.isNotEmpty)
          pw.Text(
            contactItems.map((item) => _reshapeArabicText(item)).join('  |  '),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 10,
              lineSpacing: 0.8,
              height: 0.9,
            ),
          ),
        if (linkItems.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            linkItems.map((item) => _reshapeArabicText(item)).join('  |  '),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 9,
              lineSpacing: 0.8,
              height: 0.9,
            ),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 2),
      ],
    );
  }

  static pw.Widget _buildSummary(SectionModel section) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          _reshapeArabicText(section.summaryData ?? ''),
          style: const pw.TextStyle(
            fontSize: 10,
            lineSpacing: 0.8,
            height: 0.9,
          ),
        ),
        pw.SizedBox(height: 2),
      ],
    );
  }

  static pw.Widget _buildExperience(SectionModel section) {
    final experiences = section.experienceData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...experiences.map(
          (exp) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        _reshapeArabicText(exp.role),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          lineSpacing: 0.8,
                          height: 0.9,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatDateRange(
                        exp.startDate,
                        exp.endDate,
                        exp.isCurrent,
                      ),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        lineSpacing: 0.8,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  exp.location.isNotEmpty
                      ? '${_reshapeArabicText(exp.company)}, ${_reshapeArabicText(exp.location)}'
                      : _reshapeArabicText(exp.company),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    lineSpacing: 0.8,
                    height: 0.9,
                  ),
                ),
                pw.SizedBox(height: 2),
                ...exp.descriptionPoints.map(
                  (point) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 1, left: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '• ',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            lineSpacing: 0.8,
                            height: 0.9,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            _reshapeArabicText(point),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              lineSpacing: 0.8,
                              height: 0.9,
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

  static pw.Widget _buildProjects(SectionModel section) {
    final projects = section.projectData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...projects.map(
          (proj) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Project name with links
                pw.Row(
                  children: [
                    pw.Text(
                      _reshapeArabicText(proj.name),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    if (proj.links.isNotEmpty) ...[
                      pw.SizedBox(width: 6),
                      pw.Text(' - ', style: const pw.TextStyle(fontSize: 10)),
                      ...proj.links.expand(
                        (link) => [
                          if (link != proj.links.first)
                            pw.Text(
                              ' | ',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          pw.UrlLink(
                            destination: link.url,
                            child: pw.Text(
                              link.label.isNotEmpty ? link.label : 'Link',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                decoration: pw.TextDecoration.underline,
                                color: PdfColors.blue700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // Role if present
                if (proj.role.isNotEmpty)
                  pw.Text(
                    _reshapeArabicText(proj.role),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      lineSpacing: 0.8,
                      height: 0.9,
                    ),
                  ),
                if (proj.description.isNotEmpty)
                  pw.Text(
                    _reshapeArabicText(proj.description),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      lineSpacing: 0.8,
                      height: 0.9,
                    ),
                  ),
                if (proj.technologies.isNotEmpty)
                  pw.Text(
                    'Technologies: ${proj.technologies.map((tech) => _reshapeArabicText(tech)).join(', ')}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      lineSpacing: 0.8,
                      height: 0.9,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildEducation(SectionModel section) {
    final education = section.educationData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        ...education.map(
          (edu) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        _reshapeArabicText(
                          edu.degree.isNotEmpty
                              ? '${edu.degree}${edu.fieldOfStudy.isNotEmpty ? ' in ${edu.fieldOfStudy}' : ''}'
                              : edu.fieldOfStudy,
                        ),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          lineSpacing: 0.8,
                          height: 0.9,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatDateRange(edu.startDate, edu.endDate, false),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        lineSpacing: 0.8,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  _reshapeArabicText(edu.institution),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    lineSpacing: 0.8,
                    height: 0.9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSkills(SectionModel section) {
    final skills = section.skillData ?? [];
    final skillNames = skills
        .map((s) => s.name)
        .where((n) => n.isNotEmpty)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          skillNames.map((skill) => _reshapeArabicText(skill)).join('  •  '),
          style: const pw.TextStyle(
            fontSize: 10,
            lineSpacing: 0.8,
            height: 0.9,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildListSection(SectionModel section) {
    final items = section.listData ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(section.title),
        pw.Text(
          items.map((item) => _reshapeArabicText(item)).join('  •  '),
          style: const pw.TextStyle(
            fontSize: 10,
            lineSpacing: 0.8,
            height: 0.9,
          ),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _reshapeArabicText(title.toUpperCase()),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
            lineSpacing: 0.8,
            height: 0.9,
          ),
        ),
        pw.Divider(thickness: 1, height: 2),
        pw.SizedBox(height: 3),
      ],
    );
  }

  static String _formatDateRange(String start, String end, bool isCurrent) {
    if (start.isEmpty && end.isEmpty) return '';
    if (isCurrent || end.toLowerCase() == 'present') {
      return '$start - Present';
    }
    return '$start - $end';
  }
}
