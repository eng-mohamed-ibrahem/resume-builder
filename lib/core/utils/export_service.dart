import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/resume/data/models/resume_models.dart';

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
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return resume.sections.map((section) {
            return _buildPdfSection(section, isAtsView);
          }).toList();
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildPdfSection(SectionModel section, bool isAtsView) {
    if (!section.isVisible) return pw.SizedBox();

    switch (section.type) {
      case SectionType.header:
        final d = section.headerData ?? HeaderModel();
        return pw.Column(
          children: [
            pw.Text(
              isAtsView ? d.fullName.toUpperCase() : d.fullName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              d.jobTitle,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (d.email.isNotEmpty) _contactItem(d.email),
                if (d.phoneNumber.isNotEmpty) _contactItem(d.phoneNumber),
                if (d.location.isNotEmpty) _contactItem(d.location),
              ],
            ),
            if (d.website.isNotEmpty ||
                d.linkedin.isNotEmpty ||
                d.github.isNotEmpty)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (d.website.isNotEmpty) _contactItem(d.website),
                  if (d.linkedin.isNotEmpty) _contactItem(d.linkedin),
                  if (d.github.isNotEmpty) _contactItem(d.github),
                ],
              ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 12),
          ],
        );
      case SectionType.summary:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            pw.Text(
              section.summaryData ?? '',
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2),
            ),
            pw.SizedBox(height: 15),
          ],
        );
      case SectionType.workExperience:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            ...(section.experienceData ?? []).map(
              (exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                exp.role,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              pw.Text(
                                exp.company,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          '${exp.startDate} - ${exp.endDate}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    ...exp.descriptionPoints.map(
                      (p) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '• ',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                p,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  lineSpacing: 1.1,
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
      case SectionType.projects:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            ...(section.projectData ?? []).map(
              (proj) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          proj.name,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        if (proj.links.isNotEmpty)
                          pw.Text(
                            ' (${proj.links.map((l) => l.label).join(" | ")})',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.blue800,
                            ),
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      proj.description,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    ...proj.descriptionPoints.map(
                      (p) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '• ',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                p,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  lineSpacing: 1.1,
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
      case SectionType.education:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            ...(section.educationData ?? []).map(
              (edu) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          edu.degree,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        pw.Text(
                          '${edu.startDate} - ${edu.endDate}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      edu.institution,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    if (edu.description.isNotEmpty)
                      pw.Text(
                        edu.description,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      case SectionType.skills:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            pw.Text(
              (section.skillData ?? []).map((s) => s.name).join(' / '),
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 15),
          ],
        );
      case SectionType.certifications:
      case SectionType.languages:
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title, isAtsView),
            pw.Text(
              (section.listData ?? []).join(' • '),
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 15),
          ],
        );
      default:
        return pw.SizedBox();
    }
  }

  static pw.Widget _sectionTitle(String title, bool isAtsView) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 6),
      ],
    );
  }

  static pw.Widget _contactItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }
}
