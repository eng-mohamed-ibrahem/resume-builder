import 'package:json_annotation/json_annotation.dart';

part 'resume_models.g.dart';

@JsonSerializable()
class ResumeModel {
  final String id;
  final String title;
  final List<SectionModel> sections;

  ResumeModel({
    required this.id,
    this.title = 'Untitled Resume',
    required this.sections,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ResumeModelToJson(this);

  ResumeModel copyWith({
    String? id,
    String? title,
    List<SectionModel>? sections,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      sections: sections ?? this.sections,
    );
  }
}

enum SectionType {
  header,
  summary,
  workExperience,
  projects,
  education,
  skills,
  certifications,
  languages,
  custom,
}

@JsonSerializable()
class SectionModel {
  final String id;
  final String title;
  final SectionType type;
  final bool isVisible;

  // Specific data fields
  final HeaderModel? headerData;
  final String? summaryData;
  final List<ExperienceModel>? experienceData;
  final List<ProjectModel>? projectData;
  final List<EducationModel>? educationData;
  final List<SkillModel>? skillData;
  final List<String>? listData;
  final String? customData;

  SectionModel({
    required this.id,
    required this.title,
    required this.type,
    this.isVisible = true,
    this.headerData,
    this.summaryData,
    this.experienceData,
    this.projectData,
    this.educationData,
    this.skillData,
    this.listData,
    this.customData,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$SectionModelToJson(this);

  SectionModel copyWith({
    String? id,
    String? title,
    SectionType? type,
    bool? isVisible,
    HeaderModel? headerData,
    String? summaryData,
    List<ExperienceModel>? experienceData,
    List<ProjectModel>? projectData,
    List<EducationModel>? educationData,
    List<SkillModel>? skillData,
    List<String>? listData,
    String? customData,
  }) {
    return SectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      headerData: headerData ?? this.headerData,
      summaryData: summaryData ?? this.summaryData,
      experienceData: experienceData ?? this.experienceData,
      projectData: projectData ?? this.projectData,
      educationData: educationData ?? this.educationData,
      skillData: skillData ?? this.skillData,
      listData: listData ?? this.listData,
      customData: customData ?? this.customData,
    );
  }
}

@JsonSerializable()
class HeaderModel {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phoneNumber;
  final String location;
  final String website;
  final String linkedin;
  final String github;

  HeaderModel({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phoneNumber = '',
    this.location = '',
    this.website = '',
    this.linkedin = '',
    this.github = '',
  });

  factory HeaderModel.fromJson(Map<String, dynamic> json) =>
      _$HeaderModelFromJson(json);
  Map<String, dynamic> toJson() => _$HeaderModelToJson(this);

  HeaderModel copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phoneNumber,
    String? location,
    String? website,
    String? linkedin,
    String? github,
  }) {
    return HeaderModel(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
    );
  }
}

@JsonSerializable()
class ExperienceModel {
  final String id;
  final String company;
  final String role;
  final String location;
  final String startDate;
  final String endDate;
  final List<String> descriptionPoints;
  final bool isCurrent;

  ExperienceModel({
    required this.id,
    this.company = '',
    this.role = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.descriptionPoints = const [],
    this.isCurrent = false,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      _$ExperienceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExperienceModelToJson(this);

  ExperienceModel copyWith({
    String? id,
    String? company,
    String? role,
    String? location,
    String? startDate,
    String? endDate,
    List<String>? descriptionPoints,
    bool? isCurrent,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      descriptionPoints: descriptionPoints ?? this.descriptionPoints,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String role;
  final List<String> technologies;
  final List<ProjectLink> links;
  final List<String> descriptionPoints;

  ProjectModel({
    required this.id,
    this.name = '',
    this.description = '',
    this.role = '',
    this.technologies = const [],
    this.links = const [],
    this.descriptionPoints = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? role,
    List<String>? technologies,
    List<ProjectLink>? links,
    List<String>? descriptionPoints,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      role: role ?? this.role,
      technologies: technologies ?? this.technologies,
      links: links ?? this.links,
      descriptionPoints: descriptionPoints ?? this.descriptionPoints,
    );
  }
}

@JsonSerializable()
class ProjectLink {
  final String label;
  final String url;

  ProjectLink({required this.label, required this.url});

  factory ProjectLink.fromJson(Map<String, dynamic> json) =>
      _$ProjectLinkFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectLinkToJson(this);
}

@JsonSerializable()
class EducationModel {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String gpa;
  final String description;

  EducationModel({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    this.startDate = '',
    this.endDate = '',
    this.gpa = '',
    this.description = '',
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) =>
      _$EducationModelFromJson(json);
  Map<String, dynamic> toJson() => _$EducationModelToJson(this);

  EducationModel copyWith({
    String? id,
    String? institution,
    String? degree,
    String? fieldOfStudy,
    String? startDate,
    String? endDate,
    String? gpa,
    String? description,
  }) {
    return EducationModel(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      gpa: gpa ?? this.gpa,
      description: description ?? this.description,
    );
  }
}

@JsonSerializable()
class SkillModel {
  final String id;
  final String name;
  final String level;

  SkillModel({required this.id, this.name = '', this.level = ''});

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);
  Map<String, dynamic> toJson() => _$SkillModelToJson(this);

  SkillModel copyWith({String? id, String? name, String? level}) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
}
