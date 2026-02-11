import '../../features/resume/data/models/resume_models.dart';

class MarkdownService {
  static String convertToMarkdown(ResumeModel resume) {
    final buffer = StringBuffer();

    for (final section in resume.sections) {
      if (!section.isVisible) continue;

      switch (section.type) {
        case SectionType.header:
          _appendHeader(buffer, section.headerData ?? HeaderModel());
          break;
        case SectionType.summary:
          _appendSectionTitle(buffer, section.title);
          buffer.writeln(section.summaryData ?? '');
          buffer.writeln();
          break;
        case SectionType.workExperience:
          _appendSectionTitle(buffer, section.title);
          for (final exp in section.experienceData ?? <ExperienceModel>[]) {
            buffer.writeln('### ${exp.role} at ${exp.company}');
            buffer.writeln(
              '*${exp.startDate} - ${exp.isCurrent ? "Present" : exp.endDate}*',
            );
            if (exp.location.isNotEmpty) buffer.writeln('*${exp.location}*');
            buffer.writeln();
            for (final point in exp.descriptionPoints) {
              buffer.writeln('- $point');
            }
            buffer.writeln();
          }
          break;
        case SectionType.projects:
          _appendSectionTitle(buffer, section.title);
          for (final proj in section.projectData ?? <ProjectModel>[]) {
            buffer.writeln('### ${proj.name}');
            if (proj.role.isNotEmpty) buffer.writeln('*${proj.role}*');
            if (proj.description.isNotEmpty) buffer.writeln(proj.description);
            if (proj.technologies.isNotEmpty) {
              buffer.writeln(
                '\n**Technologies:** ${proj.technologies.join(", ")}',
              );
            }
            for (final point in proj.descriptionPoints) {
              buffer.writeln('- $point');
            }
            buffer.writeln();
          }
          break;
        case SectionType.education:
          _appendSectionTitle(buffer, section.title);
          for (final edu in section.educationData ?? <EducationModel>[]) {
            buffer.writeln('### ${edu.degree} in ${edu.fieldOfStudy}');
            buffer.writeln(
              '**${edu.institution}** | *${edu.startDate} - ${edu.endDate}*',
            );
            if (edu.description.isNotEmpty) buffer.writeln(edu.description);
            buffer.writeln();
          }
          break;
        case SectionType.skills:
          _appendSectionTitle(buffer, section.title);
          final skills =
              section.skillData
                  ?.map((s) => s.name)
                  .where((n) => n.isNotEmpty)
                  .join(' • ') ??
              '';
          buffer.writeln(skills);
          buffer.writeln();
          break;
        case SectionType.certifications:
        case SectionType.languages:
          _appendSectionTitle(buffer, section.title);
          final items = section.listData?.join(' • ') ?? '';
          buffer.writeln(items);
          buffer.writeln();
          break;
        case SectionType.custom:
          _appendSectionTitle(buffer, section.title);
          buffer.writeln(section.customData ?? '');
          buffer.writeln();
          break;
      }
    }

    return buffer.toString();
  }

  static void _appendSectionTitle(StringBuffer buffer, String title) {
    buffer.writeln('## ${title.toUpperCase()}');
    buffer.writeln('---');
  }

  static void _appendHeader(StringBuffer buffer, HeaderModel data) {
    buffer.writeln('# ${data.fullName.toUpperCase()}');
    buffer.writeln('### ${data.jobTitle}');
    buffer.writeln();

    final contactItems = <String>[];
    if (data.email.isNotEmpty) contactItems.add(data.email);
    if (data.phoneNumber.isNotEmpty) contactItems.add(data.phoneNumber);
    if (data.location.isNotEmpty) contactItems.add(data.location);

    if (contactItems.isNotEmpty) {
      buffer.writeln(contactItems.join(' | '));
    }

    final linkItems = <String>[];
    if (data.linkedin.isNotEmpty) linkItems.add(data.linkedin);
    if (data.github.isNotEmpty) linkItems.add(data.github);
    if (data.website.isNotEmpty) linkItems.add(data.website);

    if (linkItems.isNotEmpty) {
      buffer.writeln(linkItems.join(' | '));
    }

    buffer.writeln('\n---');
  }
}
