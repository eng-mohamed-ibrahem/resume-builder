import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/supabase_service.dart';
import '../../data/models/resume_models.dart';
import 'resume_state.dart';

class ResumeCubit extends Cubit<ResumeState> {
  final _supabaseService = SupabaseService();

  ResumeCubit() : super(ResumeInitial());

  void resetToInitial() {
    emit(ResumeInitial());
  }

  Future<void> loadUserResumes() async {
    try {
      emit(ResumeLoading());
      final resumes = await _supabaseService.getUserResumes();
      if (resumes.isNotEmpty) {
        emit(ResumeListLoaded(resumes));
      } else {
        // Even if empty, we might want to show the dashboard with "Create New"
        emit(const ResumeListLoaded([]));
      }
    } catch (e) {
      if (kDebugMode) print('Error loading resumes: $e');
      emit(const ResumeError('Failed to load existing resumes'));
    }
  }

  Future<void> loadResume(String resumeId) async {
    try {
      emit(ResumeLoading());
      final resume = await _supabaseService.getFullResume(resumeId);
      emit(ResumeUpdated(resume));
    } catch (e) {
      if (kDebugMode) print('Error loading resume: $e');
      emit(const ResumeError('Failed to load resume'));
    }
  }

  void createNewResume() {
    final emptyResume = ResumeModel(
      id: 'temp_${const Uuid().v4()}',
      title: 'My Resume',
      sections: [
        SectionModel(
          id: 'header',
          title: 'Header',
          type: SectionType.header,
          headerData: HeaderModel(),
        ),
      ],
    );
    emit(ResumeUpdated(emptyResume));
  }

  void toggleView() {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      emit(currentState.copyWith(isAtsView: !currentState.isAtsView));
    }
  }

  void updateTitle(String title) {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      emit(
        currentState.copyWith(
          resume: currentState.resume.copyWith(title: title),
        ),
      );
    }
  }

  void updateHeader(String sectionId, HeaderModel header) {
    _updateSection(id: sectionId, headerData: header);
  }

  void updateSummary(String sectionId, String summary) {
    _updateSection(id: sectionId, summaryData: summary);
  }

  void updateExperiences(String sectionId, List<ExperienceModel> experiences) {
    _updateSection(id: sectionId, experienceData: experiences);
  }

  void updateProjects(String sectionId, List<ProjectModel> projects) {
    _updateSection(id: sectionId, projectData: projects);
  }

  void updateEducation(String sectionId, List<EducationModel> education) {
    _updateSection(id: sectionId, educationData: education);
  }

  void updateSkills(String sectionId, List<SkillModel> skills) {
    _updateSection(id: sectionId, skillData: skills);
  }

  void updateListData(String sectionId, List<String> list) {
    _updateSection(id: sectionId, listData: list);
  }

  void updateCustomData(String sectionId, String custom) {
    _updateSection(id: sectionId, customData: custom);
  }

  void _updateSection({
    required String id,
    HeaderModel? headerData,
    String? summaryData,
    List<ExperienceModel>? experienceData,
    List<ProjectModel>? projectData,
    List<EducationModel>? educationData,
    List<SkillModel>? skillData,
    List<String>? listData,
    String? customData,
  }) {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      final updatedSections = currentState.resume.sections.map((s) {
        if (s.id == id) {
          return s.copyWith(
            headerData: headerData,
            summaryData: summaryData,
            experienceData: experienceData,
            projectData: projectData,
            educationData: educationData,
            skillData: skillData,
            listData: listData,
            customData: customData,
          );
        }
        return s;
      }).toList();
      emit(
        currentState.copyWith(
          resume: currentState.resume.copyWith(sections: updatedSections),
        ),
      );
    }
  }

  void addSection(SectionType type) {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      final newId = const Uuid().v4();
      final newSection = _createInitialSection(newId, type);
      final updatedSections = List<SectionModel>.from(
        currentState.resume.sections,
      )..add(newSection);
      emit(
        currentState.copyWith(
          resume: currentState.resume.copyWith(sections: updatedSections),
        ),
      );
    }
  }

  SectionModel _createInitialSection(String id, SectionType type) {
    final title = _getDefaultTitle(type);
    switch (type) {
      case SectionType.header:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          headerData: HeaderModel(),
        );
      case SectionType.summary:
        return SectionModel(id: id, title: title, type: type, summaryData: '');
      case SectionType.workExperience:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          experienceData: const [],
        );
      case SectionType.projects:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          projectData: const [],
        );
      case SectionType.education:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          educationData: const [],
        );
      case SectionType.skills:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          skillData: const [],
        );
      case SectionType.certifications:
      case SectionType.languages:
        return SectionModel(
          id: id,
          title: title,
          type: type,
          listData: const [],
        );
      case SectionType.custom:
        return SectionModel(id: id, title: title, type: type, customData: '');
    }
  }

  void removeSection(String sectionId) {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      final updatedSections = currentState.resume.sections
          .where((s) => s.id != sectionId)
          .toList();
      emit(
        currentState.copyWith(
          resume: currentState.resume.copyWith(sections: updatedSections),
        ),
      );
    }
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      final updatedSections = List<SectionModel>.from(
        currentState.resume.sections,
      );
      if (newIndex > oldIndex) newIndex -= 1;
      final item = updatedSections.removeAt(oldIndex);
      updatedSections.insert(newIndex, item);
      emit(
        currentState.copyWith(
          resume: currentState.resume.copyWith(sections: updatedSections),
        ),
      );
    }
  }

  String _getDefaultTitle(SectionType type) {
    switch (type) {
      case SectionType.header:
        return 'Header';
      case SectionType.summary:
        return 'Summary';
      case SectionType.workExperience:
        return 'Work Experience';
      case SectionType.projects:
        return 'Projects';
      case SectionType.education:
        return 'Education';
      case SectionType.skills:
        return 'Skills';
      case SectionType.certifications:
        return 'Certifications';
      case SectionType.languages:
        return 'Languages';
      case SectionType.custom:
        return 'Custom Section';
    }
  }

  void loadResumeFromCloud(ResumeModel resume) {
    emit(ResumeUpdated(resume));
  }

  Future<void> saveToCloud(ResumeModel resume, {String? title}) async {
    // Set saving state to true
    if (state is ResumeUpdated) {
      final currentState = state as ResumeUpdated;
      emit(currentState.copyWith(isSaving: true));
    }

    try {
      // Convert resume to JSON for storage
      final resumeData = _convertResumeToData(resume);
      final resumeTitle = title ?? resume.title;

      if (resume.id.isEmpty || resume.id.startsWith('temp_')) {
        // Create new resume in cloud
        final response = await _supabaseService.createResume(
          resumeTitle,
          resumeData,
        );

        // Update local state with the real ID from the cloud
        if (state is ResumeUpdated) {
          final currentState = state as ResumeUpdated;
          final newId = response['id'];
          emit(
            ResumeUpdated(
              currentState.resume.copyWith(id: newId, title: resumeTitle),
              isAtsView: currentState.isAtsView,
              isSaving: false,
            ),
          );
        }
      } else {
        // Update existing resume
        // Update title and data
        await _supabaseService.updateResume(resume.id, {'title': resumeTitle});
        await _supabaseService.saveResumeData(resume.id, resumeData);

        // Update local state title if it changed
        if (state is ResumeUpdated) {
          final currentState = state as ResumeUpdated;
          emit(
            ResumeUpdated(
              currentState.resume.copyWith(title: resumeTitle),
              isAtsView: currentState.isAtsView,
              isSaving: false,
            ),
          );
        }
      }
    } catch (e) {
      // Reset saving state on error
      if (state is ResumeUpdated) {
        final currentState = state as ResumeUpdated;
        emit(currentState.copyWith(isSaving: false));
      }
      if (kDebugMode) print('Error saving to cloud: $e');
      // Rethrow to let UI handle the error if needed
      rethrow;
    }
  }

  Map<String, dynamic> _convertResumeToData(ResumeModel resume) {
    final Map<String, dynamic> data = {};

    for (final section in resume.sections) {
      switch (section.type) {
        case SectionType.header:
          if (section.headerData != null) {
            data['header'] = {
              'fullName': section.headerData!.fullName,
              'jobTitle': section.headerData!.jobTitle,
              'email': section.headerData!.email,
              'phoneNumber': section.headerData!.phoneNumber,
              'location': section.headerData!.location,
              'website': section.headerData!.website,
              'linkedin': section.headerData!.linkedin,
              'github': section.headerData!.github,
            };
          }
          break;
        case SectionType.summary:
          if (section.summaryData != null) {
            data['summary'] = section.summaryData!;
          }
          break;
        case SectionType.workExperience:
          if (section.experienceData != null) {
            data['experience'] = section.experienceData!
                .map(
                  (exp) => {
                    'id': exp.id,
                    'company': exp.company,
                    'role': exp.role,
                    'location': exp.location,
                    'startDate': exp.startDate,
                    'endDate': exp.endDate,
                    'descriptionPoints': exp.descriptionPoints,
                    'isCurrent': exp.isCurrent,
                  },
                )
                .toList();
          }
          break;
        case SectionType.education:
          if (section.educationData != null) {
            data['education'] = section.educationData!
                .map(
                  (edu) => {
                    'id': edu.id,
                    'institution': edu.institution,
                    'degree': edu.degree,
                    'fieldOfStudy': edu.fieldOfStudy,
                    'startDate': edu.startDate,
                    'endDate': edu.endDate,
                    'gpa': edu.gpa,
                    'description': edu.description,
                  },
                )
                .toList();
          }
          break;
        case SectionType.skills:
          if (section.skillData != null) {
            data['skills'] = section.skillData!
                .map(
                  (skill) => {
                    'id': skill.id,
                    'name': skill.name,
                    'level': skill.level,
                  },
                )
                .toList();
          }
          break;
        case SectionType.projects:
          if (section.projectData != null) {
            data['projects'] = section.projectData!
                .map(
                  (proj) => {
                    'id': proj.id,
                    'name': proj.name,
                    'description': proj.description,
                    'role': proj.role,
                    'technologies': proj.technologies,
                    'links': proj.links
                        .map((link) => {'label': link.label, 'url': link.url})
                        .toList(),
                    'descriptionPoints': proj.descriptionPoints,
                  },
                )
                .toList();
          }
          break;
        case SectionType.certifications:
          if (section.listData != null) {
            data['certifications'] = section.listData!;
          }
          break;
        case SectionType.languages:
          if (section.listData != null) {
            data['languages'] = section.listData!;
          }
          break;
        case SectionType.custom:
          if (section.customData != null) {
            data['custom'] = section.customData!;
          }
          break;
      }
    }

    return data;
  }
}
