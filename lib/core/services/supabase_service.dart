import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/resume/data/models/resume_models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
      emailRedirectTo: 'https://eng-mohamed-ibrahem.github.io/resume-builder/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  String? get userProfileImage => currentUser?.userMetadata?['avatar_url'];

  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  // Resume Operations
  Future<List<Map<String, dynamic>>> getUserResumes() async {
    if (currentUser == null) return [];

    final response = await _client
        .from('resumes')
        .select()
        .eq('user_id', currentUser!.id)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createResume(
    String title,
    Map<String, dynamic>? resumeData,
  ) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final response = await _client
        .from('resumes')
        .insert({
          'user_id': currentUser!.id,
          'title': title,
          'template_name': 'modern',
        })
        .select()
        .single();

    // If resume data is provided, create sections and save data
    if (resumeData != null) {
      await _saveResumeSections(response['id'], resumeData);
    }

    return response;
  }

  Future<void> updateResume(String resumeId, Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _client
        .from('resumes')
        .update(data)
        .eq('id', resumeId)
        .eq('user_id', currentUser!.id);
  }

  Future<void> deleteResume(String resumeId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _client
        .from('resumes')
        .delete()
        .eq('id', resumeId)
        .eq('user_id', currentUser!.id);
  }

  Future<void> saveResumeData(
    String resumeId,
    Map<String, dynamic> resumeData,
  ) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _saveResumeSections(resumeId, resumeData);
  }

  Future<Map<String, dynamic>> getResumeData(String resumeId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    // Get all sections for this resume
    final sections = await _client
        .from('resume_sections')
        .select()
        .eq('resume_id', resumeId)
        .order('section_order', ascending: true);

    final Map<String, dynamic> resumeData = {};

    for (final section in sections) {
      final sectionType = section['section_type'];
      final sectionId = section['id'];

      switch (sectionType) {
        case 'header':
          final headerData = await _client
              .from('header_sections')
              .select()
              .eq('section_id', sectionId)
              .maybeSingle();
          if (headerData != null) {
            resumeData['header'] = {
              'fullName': headerData['full_name'] ?? '',
              'jobTitle': headerData['job_title'] ?? '',
              'email': headerData['email'] ?? '',
              'phoneNumber': headerData['phone_number'] ?? '',
              'location': headerData['location'] ?? '',
              'website': headerData['website'] ?? '',
              'linkedin': headerData['linkedin'] ?? '',
              'github': headerData['github'] ?? '',
            };
          }
          break;

        case 'summary':
          final summaryData = await _client
              .from('summary_sections')
              .select()
              .eq('section_id', sectionId)
              .maybeSingle();
          if (summaryData != null) {
            resumeData['summary'] = summaryData['content'] ?? '';
          }
          break;

        case 'work_experience':
          final experiences = await _client
              .from('work_experiences')
              .select('*, experience_points(*)')
              .eq('section_id', sectionId)
              .order('created_at', ascending: false);

          resumeData['experience'] = experiences
              .map(
                (exp) => {
                  'id': exp['id'],
                  'company': exp['company'] ?? '',
                  'role': exp['role'] ?? '',
                  'startDate': exp['start_date'] ?? '',
                  'endDate': exp['end_date'] ?? '',
                  'location': exp['location'] ?? '',
                  'description': exp['description'] ?? '',
                  'isCurrent':
                      exp['end_date'] == 'Present' ||
                      exp['end_date'] == null ||
                      exp['end_date'] == '',
                  'descriptionPoints':
                      (exp['experience_points'] as List<dynamic>?)
                          ?.map((point) => point['point_text'] as String)
                          .toList() ??
                      [],
                },
              )
              .toList();
          break;

        case 'education':
          final education = await _client
              .from('education_entries')
              .select()
              .eq('section_id', sectionId)
              .order('created_at', ascending: false);

          resumeData['education'] = education
              .map(
                (edu) => {
                  'id': edu['id'],
                  'institution': edu['institution'] ?? '',
                  'degree': edu['degree'] ?? '',
                  'fieldOfStudy': edu['field_of_study'] ?? '',
                  'startDate': edu['start_date'] ?? '',
                  'endDate': edu['end_date'] ?? '',
                  'gpa': edu['gpa'] ?? '',
                  'description': edu['description'] ?? '',
                },
              )
              .toList();
          break;

        case 'skills':
          final skills = await _client
              .from('skills')
              .select()
              .eq('section_id', sectionId);

          resumeData['skills'] = skills
              .map(
                (skill) => {
                  'id': skill['id'],
                  'name': skill['name'] ?? '',
                  'skillLevel': skill['skill_level'] ?? '',
                  'category': skill['category'] ?? '',
                },
              )
              .toList();
          break;

        case 'projects':
          final projects = await _client
              .from('projects')
              .select('*, project_points(*), project_links(*)')
              .eq('section_id', sectionId)
              .order('created_at', ascending: true);

          resumeData['projects'] = projects
              .map(
                (proj) => {
                  'id': proj['id'],
                  'name': proj['name'] ?? '',
                  'description': proj['description'] ?? '',
                  'technologies': proj['technologies'] ?? [],
                  'projectUrl': proj['project_url'] ?? '',
                  'githubUrl': proj['github_url'] ?? '',
                  'startDate': proj['start_date'] ?? '',
                  'endDate': proj['end_date'] ?? '',
                  'descriptionPoints':
                      (proj['project_points'] as List<dynamic>?)
                          ?.map((point) => point['point_text'] as String)
                          .toList() ??
                      [],
                  'links':
                      (proj['project_links'] as List<dynamic>?)
                          ?.map(
                            (link) => {
                              'label': link['label'] ?? '',
                              'url': link['url'] ?? '',
                            },
                          )
                          .toList() ??
                      [],
                },
              )
              .toList();
          break;

        case 'certifications':
          final certifications = await _client
              .from('certifications')
              .select()
              .eq('section_id', sectionId);

          resumeData['certifications'] = certifications
              .map(
                (cert) => {
                  'id': cert['id'],
                  'name': cert['name'] ?? '',
                  'issuer': cert['issuer'] ?? '',
                  'issueDate': cert['issue_date'] ?? '',
                  'expiryDate': cert['expiry_date'] ?? '',
                  'credentialId': cert['credential_id'] ?? '',
                  'credentialUrl': cert['credential_url'] ?? '',
                },
              )
              .toList();
          break;

        case 'languages':
          final languages = await _client
              .from('languages')
              .select()
              .eq('section_id', sectionId);

          resumeData['languages'] = languages
              .map(
                (lang) => {
                  'id': lang['id'],
                  'name': lang['name'] ?? '',
                  'proficiency': lang['proficiency'] ?? '',
                },
              )
              .toList();
          break;
      }
    }

    return resumeData;
  }

  Future<void> _saveResumeSections(
    String resumeId,
    Map<String, dynamic> resumeData,
  ) async {
    // Clear existing sections
    await _client.from('resume_sections').delete().eq('resume_id', resumeId);

    int sectionOrder = 0;

    // Save header section
    if (resumeData.containsKey('header')) {
      final headerData = resumeData['header'] as Map<String, dynamic>;
      final section = await _createSection(
        resumeId,
        'header',
        'Header',
        sectionOrder++,
      );

      await _client.from('header_sections').insert({
        'section_id': section['id'],
        'full_name': headerData['fullName'] ?? '',
        'job_title': headerData['jobTitle'] ?? '',
        'email': headerData['email'] ?? '',
        'phone_number': headerData['phoneNumber'] ?? '',
        'location': headerData['location'] ?? '',
        'website': headerData['website'] ?? '',
        'linkedin': headerData['linkedin'] ?? '',
        'github': headerData['github'] ?? '',
      });
    }

    // Save summary section
    if (resumeData.containsKey('summary')) {
      final summaryContent = resumeData['summary'] as String;
      final section = await _createSection(
        resumeId,
        'summary',
        'Summary',
        sectionOrder++,
      );

      await _client.from('summary_sections').insert({
        'section_id': section['id'],
        'content': summaryContent,
      });
    }

    // Save experience section
    if (resumeData.containsKey('experience')) {
      final experiences = resumeData['experience'] as List<dynamic>;
      if (experiences.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'work_experience',
          'Work Experience',
          sectionOrder++,
        );

        for (final exp in experiences) {
          final expData = exp as Map<String, dynamic>;
          final experience = await _client
              .from('work_experiences')
              .insert({
                'section_id': section['id'],
                'company': expData['company'] ?? '',
                'role': expData['role'] ?? '',
                'start_date': expData['startDate'] ?? '',
                'end_date': expData['endDate'] ?? '',
                'location': expData['location'] ?? '',
                'description': expData['description'] ?? '',
              })
              .select()
              .single();

          // Save experience points
          final points = expData['descriptionPoints'] as List<dynamic>? ?? [];
          for (int i = 0; i < points.length; i++) {
            await _client.from('experience_points').insert({
              'experience_id': experience['id'],
              'point_text': points[i],
              'point_order': i,
            });
          }
        }
      }
    }

    // Save education section
    if (resumeData.containsKey('education')) {
      final education = resumeData['education'] as List<dynamic>;
      if (education.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'education',
          'Education',
          sectionOrder++,
        );

        for (final edu in education) {
          final eduData = edu as Map<String, dynamic>;
          await _client.from('education_entries').insert({
            'section_id': section['id'],
            'institution': eduData['institution'] ?? '',
            'degree': eduData['degree'] ?? '',
            'field_of_study': eduData['fieldOfStudy'] ?? '',
            'start_date': eduData['startDate'] ?? '',
            'end_date': eduData['endDate'] ?? '',
            'gpa': eduData['gpa'] ?? '',
            'description': eduData['description'] ?? '',
          });
        }
      }
    }

    // Save skills section
    if (resumeData.containsKey('skills')) {
      final skills = resumeData['skills'] as List<dynamic>;
      if (skills.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'skills',
          'Skills',
          sectionOrder++,
        );

        for (final skill in skills) {
          final skillData = skill as Map<String, dynamic>;
          await _client.from('skills').insert({
            'section_id': section['id'],
            'name': skillData['name'] ?? '',
            'skill_level': skillData['skillLevel'] ?? '',
            'category': skillData['category'] ?? '',
          });
        }
      }
    }

    // Save projects section
    if (resumeData.containsKey('projects')) {
      final projects = resumeData['projects'] as List<dynamic>;
      if (projects.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'projects',
          'Projects',
          sectionOrder++,
        );

        for (final proj in projects) {
          final projData = proj as Map<String, dynamic>;
          final project = await _client
              .from('projects')
              .insert({
                'section_id': section['id'],
                'name': projData['name'] ?? '',
                'description': projData['description'] ?? '',
                'technologies': projData['technologies'] ?? [],
                'project_url': projData['projectUrl'] ?? '',
                'github_url': projData['githubUrl'] ?? '',
                'start_date': projData['startDate'] ?? '',
                'end_date': projData['endDate'] ?? '',
              })
              .select()
              .single();

          // Save project points
          final points = projData['descriptionPoints'] as List<dynamic>? ?? [];
          for (int i = 0; i < points.length; i++) {
            await _client.from('project_points').insert({
              'project_id': project['id'],
              'point_text': points[i],
              'point_order': i,
            });
          }

          // Save project links
          final links = projData['links'] as List<dynamic>? ?? [];
          for (final link in links) {
            final linkData = link as Map<String, dynamic>;
            await _client.from('project_links').insert({
              'project_id': project['id'],
              'label': linkData['label'] ?? '',
              'url': linkData['url'] ?? '',
            });
          }
        }
      }
    }

    // Save certifications section
    if (resumeData.containsKey('certifications')) {
      final certifications = resumeData['certifications'] as List<dynamic>;
      if (certifications.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'certifications',
          'Certifications',
          sectionOrder++,
        );

        for (final cert in certifications) {
          await _client.from('certifications').insert({
            'section_id': section['id'],
            'name': cert.toString(),
          });
        }
      }
    }

    // Save languages section
    if (resumeData.containsKey('languages')) {
      final languages = resumeData['languages'] as List<dynamic>;
      if (languages.isNotEmpty) {
        final section = await _createSection(
          resumeId,
          'languages',
          'Languages',
          sectionOrder++,
        );

        for (final lang in languages) {
          await _client.from('languages').insert({
            'section_id': section['id'],
            'name': lang.toString(),
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> _createSection(
    String resumeId,
    String type,
    String title,
    int order,
  ) async {
    return await _client
        .from('resume_sections')
        .insert({
          'resume_id': resumeId,
          'section_type': type,
          'section_title': title,
          'section_order': order,
        })
        .select()
        .single();
  }

  // Profile Operations
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _client
        .from('profiles')
        .update(profileData)
        .eq('id', currentUser!.id);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    return response;
  }

  Future<ResumeModel> getFullResume(String resumeId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    // Get all sections for this resume
    final sectionsData = await _client
        .from('resume_sections')
        .select()
        .eq('resume_id', resumeId)
        .order('section_order', ascending: true);

    // Get resume details (title)
    final resumeRecord = await _client
        .from('resumes')
        .select('title')
        .eq('id', resumeId)
        .single();

    final title = resumeRecord['title'] as String? ?? 'Untitled Resume';

    final List<SectionModel> sections = [];

    for (final section in sectionsData) {
      final sectionTypeStr = section['section_type'] as String;
      final sectionId = section['id'] as String;
      final sectionTitle = section['section_title'] as String;

      final type = _mapStringToSectionType(sectionTypeStr);

      switch (type) {
        case SectionType.header:
          final headerData = await _client
              .from('header_sections')
              .select()
              .eq('section_id', sectionId)
              .maybeSingle();

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              headerData: headerData != null
                  ? HeaderModel(
                      fullName: headerData['full_name'] ?? '',
                      jobTitle: headerData['job_title'] ?? '',
                      email: headerData['email'] ?? '',
                      phoneNumber: headerData['phone_number'] ?? '',
                      location: headerData['location'] ?? '',
                      website: headerData['website'] ?? '',
                      linkedin: headerData['linkedin'] ?? '',
                      github: headerData['github'] ?? '',
                    )
                  : HeaderModel(),
            ),
          );
          break;

        case SectionType.summary:
          final summaryData = await _client
              .from('summary_sections')
              .select()
              .eq('section_id', sectionId)
              .maybeSingle();

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              summaryData: summaryData != null
                  ? summaryData['content'] ?? ''
                  : '',
            ),
          );
          break;

        case SectionType.workExperience:
          final experiences = await _client
              .from('work_experiences')
              .select('*, experience_points(*)')
              .eq('section_id', sectionId)
              .order('created_at', ascending: false);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              experienceData: experiences
                  .map(
                    (exp) => ExperienceModel(
                      id: exp['id'],
                      company: exp['company'] ?? '',
                      role: exp['role'] ?? '',
                      startDate: exp['start_date'] ?? '',
                      endDate: exp['end_date'] ?? '',
                      location: exp['location'] ?? '',
                      isCurrent:
                          exp['end_date'] == 'Present' ||
                          exp['end_date'] == null ||
                          exp['end_date'] ==
                              '', // Simple logic, might need adjustment
                      descriptionPoints:
                          (exp['experience_points'] as List<dynamic>?)
                              ?.map((point) => point['point_text'] as String)
                              .toList() ??
                          [],
                    ),
                  )
                  .toList(),
            ),
          );
          break;

        case SectionType.education:
          final education = await _client
              .from('education_entries')
              .select()
              .eq('section_id', sectionId)
              .order('created_at', ascending: false);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              educationData: education
                  .map(
                    (edu) => EducationModel(
                      id: edu['id'],
                      institution: edu['institution'] ?? '',
                      degree: edu['degree'] ?? '',
                      fieldOfStudy: edu['field_of_study'] ?? '',
                      startDate: edu['start_date'] ?? '',
                      endDate: edu['end_date'] ?? '',
                      gpa: edu['gpa'] ?? '',
                      description: edu['description'] ?? '',
                    ),
                  )
                  .toList(),
            ),
          );
          break;

        case SectionType.skills:
          final skills = await _client
              .from('skills')
              .select()
              .eq('section_id', sectionId);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              skillData: skills
                  .map(
                    (skill) => SkillModel(
                      id: skill['id'],
                      name: skill['name'] ?? '',
                      level: skill['skill_level'] ?? '',
                    ),
                  )
                  .toList(),
            ),
          );
          break;

        case SectionType.projects:
          final projects = await _client
              .from('projects')
              .select('*, project_points(*), project_links(*)')
              .eq('section_id', sectionId)
              .order('created_at', ascending: true);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              projectData: projects
                  .map(
                    (proj) => ProjectModel(
                      id: proj['id'],
                      name: proj['name'] ?? '',
                      description: proj['description'] ?? '',
                      technologies:
                          (proj['technologies'] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ??
                          [],
                      // Load links from project_links table
                      links:
                          (proj['project_links'] as List<dynamic>?)
                              ?.map(
                                (link) => ProjectLink(
                                  label: link['label'] ?? '',
                                  url: link['url'] ?? '',
                                ),
                              )
                              .toList() ??
                          [],
                      descriptionPoints:
                          (proj['project_points'] as List<dynamic>?)
                              ?.map((point) => point['point_text'] as String)
                              .toList() ??
                          [],
                    ),
                  )
                  .toList(),
            ),
          );
          break;

        case SectionType.certifications:
          final certifications = await _client
              .from('certifications')
              .select()
              .eq('section_id', sectionId);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              listData: certifications
                  .map((c) => '${c['name']} - ${c['issuer']}')
                  .toList(), // Simplified mapping as listData is List<String>
            ),
          );
          break;

        case SectionType.languages:
          final languages = await _client
              .from('languages')
              .select()
              .eq('section_id', sectionId);

          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              listData: languages
                  .map((l) => '${l['name']} (${l['proficiency']})')
                  .toList(), // Simplified mapping
            ),
          );
          break;

        case SectionType.custom:
          // Not implemented fully in save logic shown, assuming basic string content or similar to summary
          sections.add(
            SectionModel(
              id: sectionId,
              title: sectionTitle,
              type: type,
              customData: '', // Placeholder
            ),
          );
          break;
      }
    }

    return ResumeModel(id: resumeId, title: title, sections: sections);
  }

  SectionType _mapStringToSectionType(String type) {
    switch (type) {
      case 'header':
        return SectionType.header;
      case 'summary':
        return SectionType.summary;
      case 'work_experience':
        return SectionType.workExperience;
      case 'projects':
        return SectionType.projects;
      case 'education':
        return SectionType.education;
      case 'skills':
        return SectionType.skills;
      case 'certifications':
        return SectionType.certifications;
      case 'languages':
        return SectionType.languages;
      case 'custom':
        return SectionType.custom;
      default:
        return SectionType.custom;
    }
  }
}
