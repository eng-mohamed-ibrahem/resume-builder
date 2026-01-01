import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';

import '../../features/resume/data/models/resume_models.dart';

class ResumeParserService {
  final _uuid = const Uuid();

  Future<ResumeModel?> parseFileBytes(Uint8List bytes, String fileName) async {
    try {
      final List<String> lines = [];
      final lowerName = fileName.toLowerCase();

      if (lowerName.endsWith('.pdf')) {
        lines.addAll(await _extractPdfText(bytes));
      } else if (lowerName.endsWith('.docx')) {
        lines.addAll(await _extractDocxText(bytes));
      }

      if (lines.isEmpty) return null;

      return _parseTextToResume(lines);
    } catch (e) {
      debugPrint('Error parsing file: $e');
      return null;
    }
  }

  Future<List<String>> _extractPdfText(Uint8List bytes) async {
    final List<String> lines = [];
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    for (int i = 0; i < document.pages.count; i++) {
      // Extract text with formatting information
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final List<TextLine> textLines = extractor.extractTextLines(
        startPageIndex: i,
      );

      for (final TextLine line in textLines) {
        if (line.text.trim().isNotEmpty) {
          lines.add(line.text.trim());
        }
      }
    }

    document.dispose();
    return lines;
  }

  Future<List<String>> _extractDocxText(Uint8List bytes) async {
    try {
      // Extract text with better structure preservation
      final text = docxToText(bytes);
      final lines = text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      return _processDocxLines(lines);
    } catch (e) {
      debugPrint('Error extracting DOCX text: $e');
      return [];
    }
  }

  List<String> _processDocxLines(List<String> rawLines) {
    final processed = <String>[];

    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i];

      // Skip empty lines
      if (line.isEmpty) {
        continue;
      }

      // Check if this might be a section header (all caps, short, etc.)
      if (_isLikelySectionHeader(line)) {
        processed.add(line);
        continue;
      }

      // Merge with next line if it seems like a continuation
      if (i < rawLines.length - 1 &&
          _shouldMergeDocxLines(line, rawLines[i + 1])) {
        processed.add('$line ${rawLines[i + 1]}');
        i++; // Skip next line as we merged it
      } else {
        processed.add(line);
      }
    }

    return processed;
  }

  bool _isLikelySectionHeader(String line) {
    final upperLine = line.toUpperCase();

    // Common section header patterns
    if (RegExp(
      r'^(SUMMARY|EXPERIENCE|EDUCATION|SKILLS|PROJECTS|CERTIFICATIONS|LANGUAGES)$',
    ).hasMatch(upperLine)) {
      return true;
    }

    // All caps and short (likely a header)
    if (line.length < 30 && line == line.toUpperCase() && !line.contains('.')) {
      return true;
    }

    return false;
  }

  bool _shouldMergeDocxLines(String current, String next) {
    // Don't merge if next is a section header
    if (_isLikelySectionHeader(next)) {
      return false;
    }

    // Don't merge if current ends with punctuation
    if (current.endsWith('.') ||
        current.endsWith(':') ||
        current.endsWith(';')) {
      return false;
    }

    // Merge if next starts with lowercase
    if (next.isNotEmpty && next[0] == next[0].toLowerCase()) {
      return true;
    }

    // Merge if current is short and doesn't look like a title
    if (current.length < 20 && !current.contains(RegExp(r'\d'))) {
      return true;
    }

    return false;
  }

  ResumeModel _parseTextToResume(List<String> rawLines) {
    // 1. Initial cleanup and simple normalization
    final cleaned = rawLines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 2. Sophisticated line merging
    final lines = _mergeBrokenLines(cleaned);

    final sections = <SectionModel>[];
    String name = '';
    String email = '';
    String phone = '';
    String location = '';
    String website = '';
    String linkedin = '';
    String github = '';
    String jobTitle = '';

    // Attempt to extract header (usually first few lines)
    int headerLimit = lines.length > 10 ? 10 : lines.length;
    for (int i = 0; i < headerLimit; i++) {
      final line = lines[i];

      // Name heuristic: short line, no digits, no symbols, first few lines
      if (name.isEmpty &&
          line.split(' ').length <= 4 &&
          !RegExp(r'\d|[@:]').hasMatch(line)) {
        name = line;
      }

      // Extract email
      if (line.contains('@') && email.isEmpty) {
        final match = RegExp(
          r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
        ).firstMatch(line);
        if (match != null) email = match.group(0) ?? '';
      }

      // Extract phone
      if (phone.isEmpty && RegExp(r'\d').hasMatch(line)) {
        final match = RegExp(r'(\+?\d[\d -]{7,}\d)').firstMatch(line);
        if (match != null) phone = match.group(0) ?? '';
      }

      // Extract location (keywords like "location", "lives in", etc.)
      if (location.isEmpty &&
          (RegExp(
            r'location:|lives in|resides in|based in|from|in:',
            caseSensitive: false,
          ).hasMatch(line))) {
        final match = RegExp(
          r':\s*(.*)|in\s+(.*)',
          caseSensitive: false,
        ).firstMatch(line);
        if (match != null) {
          location = (match.group(1) ?? match.group(2) ?? '').trim();
        }
      }

      // Extract website
      if (website.isEmpty &&
          (RegExp(r'https?://|www\.', caseSensitive: false).hasMatch(line))) {
        final match = RegExp(r'https?://[^\s<>"{}[\]\\`|]+').firstMatch(line);
        if (match != null) website = match.group(0) ?? '';
      }

      // Extract LinkedIn
      if (linkedin.isEmpty &&
          (RegExp(r'linkedin', caseSensitive: false).hasMatch(line))) {
        final match = RegExp(
          r'https?://[^\s<>"{}[\]\\`|]*linkedin[^\s<>"{}[\]\\`|]*',
        ).firstMatch(line);
        if (match != null) linkedin = match.group(0) ?? '';
      }

      // Extract GitHub
      if (github.isEmpty &&
          (RegExp(r'github', caseSensitive: false).hasMatch(line))) {
        final match = RegExp(
          r'https?://[^\s<>"{}[\]\\`|]*github[^\s<>"{}[\]\\`|]*',
        ).firstMatch(line);
        if (match != null) github = match.group(0) ?? '';
      }

      // Extract job title (if it's not the name line)
      if (jobTitle.isEmpty &&
          name.isNotEmpty &&
          line != name &&
          !RegExp(
            r'@|phone|email|linkedin|github|location',
            caseSensitive: false,
          ).hasMatch(line)) {
        // Check if this looks like a job title (usually short, descriptive)
        if (line.length < 50 &&
            !RegExp(
              r'\d|@|http|www|\.com|\.org|\.net',
              caseSensitive: false,
            ).hasMatch(line)) {
          jobTitle = line;
        }
      }
    }

    sections.add(
      SectionModel(
        id: 'header',
        title: 'Header',
        type: SectionType.header,
        headerData: HeaderModel(
          fullName: name,
          jobTitle: jobTitle,
          email: email,
          phoneNumber: phone,
          location: location,
          website: website,
          linkedin: linkedin,
          github: github,
        ),
      ),
    );

    // 3. Section Identification with enhanced detection
    final sectionMap = <String, List<String>>{
      'summary': [],
      'experience': [],
      'education': [],
      'skills': [],
      'projects': [],
      'certifications': [],
      'languages': [],
    };

    String currentSection = '';
    bool inHeaderSection = true;

    // Process lines and identify sections
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase().trim();

      // Check if we're still in the header section (first 8-10 lines)
      if (inHeaderSection && i < 10) {
        // Look for contact info patterns
        if (RegExp(
              r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            ).hasMatch(line) ||
            RegExp(r'\+?\d[\d -]{7,}\d').hasMatch(line) ||
            RegExp(
              r'(linkedin|github|portfolio)',
              caseSensitive: false,
            ).hasMatch(line)) {
          continue; // Skip contact info lines
        }

        // If we find a clear section header, we're past the header
        if (_isSectionHeader(lower) != null) {
          inHeaderSection = false;
        }
      }

      if (!inHeaderSection) {
        final isSectionHeader = _isSectionHeader(lower);

        if (isSectionHeader != null) {
          currentSection = isSectionHeader;
          continue;
        }

        if (currentSection.isNotEmpty &&
            sectionMap.containsKey(currentSection)) {
          sectionMap[currentSection]?.add(line);
        }
      }
    }

    // 4. Build Section Models with enhanced heuristics
    _processSummary(sections, sectionMap['summary']!);
    _processExperience(sections, sectionMap['experience']!);
    _processEducation(sections, sectionMap['education']!);
    _processSkills(sections, sectionMap['skills']!);
    _processProjects(sections, sectionMap['projects']!);
    _processCertifications(sections, sectionMap['certifications']!);
    _processLanguages(sections, sectionMap['languages']!);

    return ResumeModel(id: 'temp_${_uuid.v4()}', sections: sections);
  }

  List<String> _mergeBrokenLines(List<String> rawLines) {
    if (rawLines.isEmpty) return [];

    final merged = <String>[];
    String current = rawLines[0];

    for (int i = 1; i < rawLines.length; i++) {
      final line = rawLines[i];

      // Heuristics for merging:
      // 1. Current line is short and doesn't end with sentence terminator
      // 2. Next line doesn't start with a bullet or capital letter (often)
      // 3. Next line isn't a section header
      if (_shouldMerge(current, line)) {
        current = '$current $line';
      } else {
        merged.add(current);
        current = line;
      }
    }
    merged.add(current);
    return merged;
  }

  bool _shouldMerge(String current, String next) {
    if (_isSectionHeader(next.toLowerCase()) != null) {
      return false;
    }
    if (next.startsWith('•') || next.startsWith('-') || next.startsWith('*')) {
      return false;
    }

    // If current is very short and doesn't look like a title
    if (current.length < 40 &&
        !current.endsWith('.') &&
        !current.endsWith(':')) {
      // If next starts with lowercase, definitely merge
      if (next.isNotEmpty &&
          next[0].toLowerCase() == next[0] &&
          next[0] != next[0].toUpperCase()) {
        return true;
      }
      // If current doesn't have much punctuation
      if (!current.contains(RegExp(r'[.!?]'))) {
        return true;
      }
    }

    return false;
  }

  String? _isSectionHeader(String lower) {
    if (lower.length > 50) return null; // Headers are usually short

    // Enhanced patterns with more variations
    if (RegExp(
      r'^summary$|^professional summary$|^profile$|^about me$|^objective$|^career summary$|^executive summary$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'summary';
    }

    if (RegExp(
      r'^experience$|^work experience$|^employment$|^work history$|^professional experience$|^career history$|^job experience$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'experience';
    }

    if (RegExp(
      r'^projects$|^personal projects$|^technical projects$|^project experience$|^key projects$|^featured projects$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'projects';
    }

    if (RegExp(
      r'^education$|^academic$|^educational background$|^academic background$|^education history$|^qualifications$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'education';
    }

    if (RegExp(
      r'^skills$|^technical skills$|^expertise$|^competencies$|^core competencies$|^skill set$|^technical proficiencies$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'skills';
    }

    if (RegExp(
      r'^certifications$|^certificates$|^professional certifications$|^credentials$|^licenses$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'certifications';
    }

    if (RegExp(
      r'^languages$|^language proficiency$|^languages spoken$|^foreign languages$',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return 'languages';
    }

    return null;
  }

  void _processSummary(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) {
      return;
    }
    sections.add(
      SectionModel(
        id: 'summary',
        title: 'Summary',
        type: SectionType.summary,
        summaryData: data.join(' '),
      ),
    );
  }

  void _processExperience(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) return;

    final experiences = <ExperienceModel>[];
    ExperienceModel? currentExperience;
    final descriptionPoints = <String>[];

    for (final line in data) {
      // Check if this line looks like a job title/company line
      if (_isJobHeader(line)) {
        // Save previous experience if exists
        if (currentExperience != null && descriptionPoints.isNotEmpty) {
          experiences.add(
            currentExperience.copyWith(
              descriptionPoints: List.from(descriptionPoints),
            ),
          );
          descriptionPoints.clear();
        }

        // Parse job header
        final parts = _parseJobHeader(line);
        currentExperience = ExperienceModel(
          id: _uuid.v4(),
          company: parts['company'] ?? 'Unknown Company',
          role: parts['role'] ?? 'Unknown Role',
          location: parts['location'] ?? '',
          startDate: parts['startDate'] ?? '',
          endDate: parts['endDate'] ?? '',
          descriptionPoints: [],
        );
      } else if (currentExperience != null) {
        // Add as description point
        if (line.trim().isNotEmpty) {
          descriptionPoints.add(line.trim());
        }
      }
    }

    // Add the last experience
    if (currentExperience != null && descriptionPoints.isNotEmpty) {
      experiences.add(
        currentExperience.copyWith(
          descriptionPoints: List.from(descriptionPoints),
        ),
      );
    }

    // If no experiences were parsed, create a default one
    if (experiences.isEmpty) {
      final points = data.where((content) => content.length > 5).toList();
      experiences.add(
        ExperienceModel(
          id: _uuid.v4(),
          company: 'Professional History',
          role: 'Extracted Role',
          startDate: '',
          endDate: '',
          descriptionPoints: points,
        ),
      );
    }

    sections.add(
      SectionModel(
        id: 'experience',
        title: 'Work Experience',
        type: SectionType.workExperience,
        experienceData: experiences,
      ),
    );
  }

  bool _isJobHeader(String line) {
    // Job headers often contain company names, locations, and dates
    return RegExp(r'[A-Z][a-z]+.*\d{4}|.*\|.*|.*@.*|.*-.*').hasMatch(line) &&
        line.length < 100;
  }

  Map<String, String> _parseJobHeader(String line) {
    final result = <String, String>{};

    // Extract dates (various formats)
    final dateMatch = RegExp(
      r'(\d{1,2}/\d{1,2}/\d{4}|\d{4}|\w+ \d{4}|\w+ \d{4} - \w+ \d{4}|\d{4} - \d{4}|\w+ \d{4} - Present)',
    ).firstMatch(line);
    if (dateMatch != null) {
      final dateStr = dateMatch.group(0) ?? '';
      if (dateStr.contains(' - ')) {
        final parts = dateStr.split(' - ');
        result['startDate'] = parts[0];
        result['endDate'] = parts[1];
      } else {
        result['startDate'] = dateStr;
      }
    }

    // Clean line of dates for further processing
    String cleanLine = line;
    if (dateMatch != null) {
      cleanLine = cleanLine.replaceAll(dateMatch.group(0)!, '').trim();
    }

    // Look for common separators and patterns
    if (cleanLine.contains(' at ') ||
        cleanLine.contains(' - ') ||
        cleanLine.contains(' | ')) {
      if (cleanLine.contains(' at ')) {
        // Format: "Role at Company" or "Role at Company, Location"
        final parts = cleanLine.split(' at ');
        result['role'] = parts[0].trim();
        String companyAndLocation = parts[1].trim();
        if (companyAndLocation.contains(',')) {
          final companyParts = companyAndLocation.split(',');
          result['company'] = companyParts[0].trim();
          result['location'] = companyParts[1].trim();
        } else {
          result['company'] = companyAndLocation;
        }
      } else if (cleanLine.contains(' - ')) {
        // Format: "Company - Role" or "Role - Company"
        final parts = cleanLine.split(' - ');
        if (parts.length >= 2) {
          // Try to determine which is company vs role based on common patterns
          String part1 = parts[0].trim();
          String part2 = parts[1].trim();

          // If part1 looks more like a company (contains common company words)
          if (RegExp(
                r'Inc|LLC|Corp|Company|Ltd|Group|Technologies|Systems|Solutions|Studio|Studio',
                caseSensitive: false,
              ).hasMatch(part1) ||
              part1.toUpperCase() == part1) {
            result['company'] = part1;
            result['role'] = part2;
          } else {
            result['role'] = part1;
            result['company'] = part2;
          }
        }
      } else if (cleanLine.contains(' | ')) {
        // Format: "Role | Company" or "Company | Role"
        final parts = cleanLine.split(' | ');
        if (parts.length >= 2) {
          String part1 = parts[0].trim();
          String part2 = parts[1].trim();

          // Try to determine which is company vs role based on common patterns
          if (RegExp(
                r'Inc|LLC|Corp|Company|Ltd|Group|Technologies|Systems|Solutions|Studio',
                caseSensitive: false,
              ).hasMatch(part1) ||
              part1.toUpperCase() == part1) {
            result['company'] = part1;
            result['role'] = part2;
          } else {
            result['role'] = part1;
            result['company'] = part2;
          }
        }
      }
    } else {
      // If no clear separator, try to identify based on capitalization and common patterns
      final words = cleanLine.split(' ');
      if (words.length > 2) {
        // Look for common role words at the beginning
        final commonRoles = [
          'Software',
          'Senior',
          'Lead',
          'Principal',
          'Junior',
          'Junior',
          'Engineer',
          'Developer',
          'Manager',
          'Director',
          'Analyst',
          'Designer',
          'Consultant',
          'Architect',
          'Specialist',
          'Coordinator',
          'Administrator',
          'Assistant',
        ];

        bool foundRole = false;
        String role = '';
        String company = '';

        for (int i = 0; i < words.length; i++) {
          if (commonRoles.any((r) => words[i].startsWith(r))) {
            role += (role.isEmpty ? '' : ' ') + words[i];
            foundRole = true;
          } else if (foundRole) {
            company += (company.isEmpty ? '' : ' ') + words[i];
          } else {
            // Before finding a role, assume it's part of the company name
            company += (company.isEmpty ? '' : ' ') + words[i];
          }
        }

        if (foundRole && role.isNotEmpty && company.isNotEmpty) {
          result['role'] = role;
          result['company'] = company;
        } else {
          // Fallback: if we couldn't identify role, use the whole line as role
          result['role'] = cleanLine;
          result['company'] = 'Company';
        }
      } else {
        result['role'] = cleanLine;
        result['company'] = 'Company';
      }
    }

    // Set defaults if not found
    if (!result.containsKey('role')) result['role'] = 'Role';
    if (!result.containsKey('company')) result['company'] = 'Company';
    if (!result.containsKey('location')) result['location'] = '';

    return result;
  }

  void _processEducation(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) return;

    final educationList = <EducationModel>[];
    EducationModel? currentEducation;
    final descriptionLines = <String>[];

    for (final line in data) {
      if (_isEducationHeader(line)) {
        // Save previous education if exists
        if (currentEducation != null && descriptionLines.isNotEmpty) {
          educationList.add(
            currentEducation.copyWith(description: descriptionLines.join('\n')),
          );
          descriptionLines.clear();
        }

        // Parse education header
        final parts = _parseEducationHeader(line);
        currentEducation = EducationModel(
          id: _uuid.v4(),
          institution: parts['institution'] ?? 'Unknown Institution',
          degree: parts['degree'] ?? 'Degree',
          fieldOfStudy: parts['fieldOfStudy'] ?? '',
          startDate: parts['startDate'] ?? '',
          endDate: parts['endDate'] ?? '',
          gpa: '', // GPA extraction would require more specific parsing
          description: '',
        );
      } else if (currentEducation != null) {
        // Add as description line
        if (line.trim().isNotEmpty) {
          descriptionLines.add(line.trim());
        }
      }
    }

    // Add the last education
    if (currentEducation != null && descriptionLines.isNotEmpty) {
      educationList.add(
        currentEducation.copyWith(description: descriptionLines.join('\n')),
      );
    }

    // If no education was parsed, create a default one
    if (educationList.isEmpty) {
      educationList.add(
        EducationModel(
          id: _uuid.v4(),
          institution: data.first,
          degree: data.length > 1 ? data[1] : 'Degree',
          fieldOfStudy: '',
          startDate: '',
          endDate: '',
          description: data.skip(2).join('\n'),
        ),
      );
    }

    sections.add(
      SectionModel(
        id: 'education',
        title: 'Education',
        type: SectionType.education,
        educationData: educationList,
      ),
    );
  }

  bool _isEducationHeader(String line) {
    // Education headers often contain university names and degrees
    return RegExp(
          r'(University|College|Institute|School|Bachelor|Master|PhD|B\.S\.|M\.S\.|B\.A\.|M\.A\.)',
          caseSensitive: false,
        ).hasMatch(line) ||
        RegExp(r'\d{4}').hasMatch(line);
  }

  Map<String, String> _parseEducationHeader(String line) {
    final result = <String, String>{};

    // Extract dates
    final dateMatch = RegExp(
      r'(\d{4}|\w+ \d{4}|\w+ \d{4} - \w+ \d{4}|\d{4} - \d{4}|\w+ \d{4} - Present)',
    ).firstMatch(line);
    if (dateMatch != null) {
      final dateStr = dateMatch.group(0) ?? '';
      if (dateStr.contains(' - ')) {
        final parts = dateStr.split(' - ');
        result['startDate'] = parts[0];
        result['endDate'] = parts[1];
      } else {
        result['endDate'] = dateStr;
      }
    }

    // Clean line of dates for further processing
    String cleanLine = line;
    if (dateMatch != null) {
      cleanLine = cleanLine.replaceAll(dateMatch.group(0)!, '').trim();
    }

    // Extract degree information
    final degreeMatch = RegExp(
      r'(Bachelor[^,]*|B\.S\.[^,]*|B\.A\.[^,]*|Master[^,]*|M\.S\.[^,]*|M\.A\.[^,]*|PhD[^,]*|Doctor[^,]*|Associate[^,]*|Diploma[^,]*)',
      caseSensitive: false,
    ).firstMatch(cleanLine);
    if (degreeMatch != null) {
      result['degree'] = degreeMatch.group(0)?.trim() ?? '';
    }

    // Extract field of study (common patterns)
    final fieldMatch = RegExp(
      r'(in\s+([A-Za-z\s]+)|:\s*([A-Za-z\s]+))',
      caseSensitive: false,
    ).firstMatch(cleanLine);
    if (fieldMatch != null) {
      result['fieldOfStudy'] =
          (fieldMatch.group(2) ?? fieldMatch.group(3))?.trim() ?? '';
    }

    // Extract institution name (remove degree and dates)
    String institution = cleanLine;
    if (result['degree'] != null) {
      institution = institution
          .replaceAll(
            RegExp(
              r'(Bachelor|B\.S\.|B\.A\.|Master|M\.S\.|M\.A\.|PhD|Doctor|Associate|Diploma).*',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
    }
    if (result['fieldOfStudy'] != null) {
      institution = institution
          .replaceAll(RegExp(r'in\s+.*', caseSensitive: false), '')
          .trim();
    }
    institution = institution.replaceAll(RegExp(r'[-|,]'), '').trim();

    // Look for common institution keywords
    if (institution.isEmpty) {
      final institutionMatch = RegExp(
        r'(University|College|Institute|School|Academy|Institut|Escuela|Facultad)[\w\s,]*',
        caseSensitive: false,
      ).firstMatch(cleanLine);
      if (institutionMatch != null) {
        institution = institutionMatch.group(0)?.trim() ?? '';
      } else {
        institution = cleanLine.trim();
      }
    }

    result['institution'] = institution.isNotEmpty
        ? institution
        : 'Unknown Institution';

    return result;
  }

  void _processSkills(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) return;

    final allSkills = <String>{};

    for (var line in data) {
      // Remove common headers or descriptors
      String cleanLine = line
          .replaceAll(
            RegExp(
              r'^Skills:|^Technical Skills:|^Core Skills:',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      // Handle various separators: comma, pipe, semicolon, bullet points
      if (cleanLine.contains(RegExp(r'[,;|•·]'))) {
        final parts = cleanLine.split(RegExp(r'[,;|•·]'));
        for (var part in parts) {
          part = part.trim();
          if (part.isNotEmpty && !part.toLowerCase().contains('skills')) {
            allSkills.add(part);
          }
        }
      } else if (cleanLine.contains(' and ')) {
        // Handle "X and Y" patterns
        final parts = cleanLine.split(' and ');
        for (var part in parts) {
          part = part.trim();
          if (part.isNotEmpty && !part.toLowerCase().contains('skills')) {
            allSkills.add(part);
          }
        }
      } else if (cleanLine.isNotEmpty &&
          !cleanLine.toLowerCase().contains('skills')) {
        // Add as single skill if it's not a header
        allSkills.add(cleanLine);
      }
    }

    sections.add(
      SectionModel(
        id: 'skills',
        title: 'Skills',
        type: SectionType.skills,
        skillData: allSkills
            .map((s) => SkillModel(id: _uuid.v4(), name: s))
            .toList(),
      ),
    );
  }

  void _processProjects(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) return;

    final projects = <ProjectModel>[];
    ProjectModel? currentProject;
    final descriptionPoints = <String>[];

    for (final line in data) {
      // Check if this line looks like a project title (often bold or capitalized)
      if (_isProjectHeader(line)) {
        // Save previous project if exists
        if (currentProject != null && descriptionPoints.isNotEmpty) {
          projects.add(
            currentProject.copyWith(
              descriptionPoints: List.from(descriptionPoints),
            ),
          );
          descriptionPoints.clear();
        }

        // Create new project
        currentProject = ProjectModel(
          id: _uuid.v4(),
          name: line.trim(),
          description: '',
          descriptionPoints: [],
        );
      } else if (currentProject != null) {
        // Add as description point
        if (line.trim().isNotEmpty) {
          descriptionPoints.add(line.trim());
        }
      }
    }

    // Add the last project
    if (currentProject != null && descriptionPoints.isNotEmpty) {
      projects.add(
        currentProject.copyWith(
          descriptionPoints: List.from(descriptionPoints),
        ),
      );
    }

    // If no projects were identified, create a default one
    if (projects.isEmpty) {
      projects.add(
        ProjectModel(
          id: _uuid.v4(),
          name: 'Project',
          description: data.join('\n'),
          descriptionPoints: data,
        ),
      );
    }

    sections.add(
      SectionModel(
        id: 'projects',
        title: 'Projects',
        type: SectionType.projects,
        projectData: projects,
      ),
    );
  }

  bool _isProjectHeader(String line) {
    // Project headers are often short, descriptive, and may have certain characteristics
    return line.length < 60 &&
        !RegExp(
          r'\d{4}|http|@|email|phone',
          caseSensitive: false,
        ).hasMatch(line) &&
        (line.toUpperCase() == line || // All caps
            line.split(' ').length <= 6 || // Short title
            RegExp(
              r'^\d\.|•\s|-\s',
              caseSensitive: false,
            ).hasMatch(line)); // Numbered or bulleted
  }

  void _processCertifications(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) return;
    sections.add(
      SectionModel(
        id: 'certifications',
        title: 'Certifications',
        type: SectionType.certifications,
        listData: data,
      ),
    );
  }

  void _processLanguages(List<SectionModel> sections, List<String> data) {
    if (data.isEmpty) {
      return;
    }
    sections.add(
      SectionModel(
        id: 'languages',
        title: 'Languages',
        type: SectionType.languages,
        listData: data,
      ),
    );
  }
}
