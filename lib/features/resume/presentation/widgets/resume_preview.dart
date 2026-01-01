import 'package:flutter/material.dart';
import 'package:resumate/features/resume/data/models/resume_models.dart';

class ResumePreview extends StatelessWidget {
  final ResumeModel resume;
  final bool isAtsView;

  const ResumePreview({
    super.key,
    required this.resume,
    required this.isAtsView,
  });

  @override
  Widget build(BuildContext context) {
    if (isAtsView) {
      return _buildAtsPreview();
    }
    return _buildStandardPreview();
  }

  Widget _buildAtsPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: Container(
          width: 800,
          color: Colors.white,
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: resume.sections.map((section) {
              return _AtsSection(section: section);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: resume.sections.map((section) {
              return _StandardSection(section: section);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AtsSection extends StatelessWidget {
  final SectionModel section;
  const _AtsSection({required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case SectionType.header:
        final d = section.headerData ?? HeaderModel();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d.fullName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '${d.jobTitle} | ${d.email} | ${d.phoneNumber} | ${d.location}',
            ),
            if (d.website.isNotEmpty ||
                d.linkedin.isNotEmpty ||
                d.github.isNotEmpty)
              Text(
                [
                  if (d.linkedin.isNotEmpty) d.linkedin,
                  if (d.github.isNotEmpty) d.github,
                  if (d.website.isNotEmpty) d.website,
                ].join(' | '),
              ),
            const SizedBox(height: 12),
          ],
        );
      case SectionType.summary:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text(section.summaryData ?? ''),
            const SizedBox(height: 12),
          ],
        );
      case SectionType.workExperience:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.experienceData ?? []).map(
              (exp) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${exp.company} - ${exp.role}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${exp.startDate} - ${exp.endDate}'),
                  ...exp.descriptionPoints.map((p) => Text('• $p')),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      case SectionType.projects:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.projectData ?? []).map(
              (proj) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proj.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(proj.description),
                  ...proj.descriptionPoints.map((p) => Text('• $p')),
                  if (proj.links.isNotEmpty)
                    Text(
                      proj.links.map((l) => '${l.label}: ${l.url}').join(' | '),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      case SectionType.education:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.educationData ?? []).map(
              (edu) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${edu.institution} - ${edu.degree}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${edu.startDate} - ${edu.endDate}'),
                  if (edu.description.isNotEmpty) Text(edu.description),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      case SectionType.skills:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text((section.skillData ?? []).map((s) => s.name).join(', ')),
            const SizedBox(height: 12),
          ],
        );
      case SectionType.certifications:
      case SectionType.languages:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text((section.listData ?? []).join(', ')),
            const SizedBox(height: 12),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(color: Colors.black, thickness: 1),
      ],
    );
  }
}

class _StandardSection extends StatelessWidget {
  final SectionModel section;
  const _StandardSection({required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case SectionType.header:
        final d = section.headerData ?? HeaderModel();
        return Column(
          children: [
            Text(
              d.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              d.jobTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                if (d.email.isNotEmpty) _contactItem(Icons.email, d.email),
                if (d.phoneNumber.isNotEmpty)
                  _contactItem(Icons.phone, d.phoneNumber),
                if (d.location.isNotEmpty)
                  _contactItem(Icons.location_on, d.location),
                if (d.website.isNotEmpty)
                  _contactItem(Icons.language, d.website),
                if (d.linkedin.isNotEmpty) _contactItem(Icons.link, d.linkedin),
                if (d.github.isNotEmpty) _contactItem(Icons.code, d.github),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 2, color: Colors.black),
            const SizedBox(height: 24),
          ],
        );
      case SectionType.summary:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text(
              section.summaryData ?? '',
              style: const TextStyle(height: 1.6, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        );
      case SectionType.workExperience:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.experienceData ?? []).map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.role,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                exp.company,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${exp.startDate} - ${exp.endDate}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...exp.descriptionPoints.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.projectData ?? []).map(
              (proj) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          proj.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (proj.links.isNotEmpty)
                          Expanded(
                            child: Text(
                              ' - ${proj.links.map((l) => l.label).join(" | ")}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proj.description,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    ...proj.descriptionPoints.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            ...(section.educationData ?? []).map(
              (edu) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          edu.degree,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${edu.startDate} - ${edu.endDate}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      edu.institution,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (edu.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          edu.description,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      case SectionType.skills:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text(
              (section.skillData ?? []).map((s) => s.name).join(' / '),
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
        );
      case SectionType.certifications:
      case SectionType.languages:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(section.title),
            Text(
              (section.listData ?? []).join(" • "),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 1.1,
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade800),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
