// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeModel _$ResumeModelFromJson(Map<String, dynamic> json) => ResumeModel(
  id: json['id'] as String,
  sections: (json['sections'] as List<dynamic>)
      .map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ResumeModelToJson(ResumeModel instance) =>
    <String, dynamic>{'id': instance.id, 'sections': instance.sections};

SectionModel _$SectionModelFromJson(Map<String, dynamic> json) => SectionModel(
  id: json['id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$SectionTypeEnumMap, json['type']),
  isVisible: json['isVisible'] as bool? ?? true,
  headerData: json['headerData'] == null
      ? null
      : HeaderModel.fromJson(json['headerData'] as Map<String, dynamic>),
  summaryData: json['summaryData'] as String?,
  experienceData: (json['experienceData'] as List<dynamic>?)
      ?.map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  projectData: (json['projectData'] as List<dynamic>?)
      ?.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  educationData: (json['educationData'] as List<dynamic>?)
      ?.map((e) => EducationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  skillData: (json['skillData'] as List<dynamic>?)
      ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  listData: (json['listData'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  customData: json['customData'] as String?,
);

Map<String, dynamic> _$SectionModelToJson(SectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$SectionTypeEnumMap[instance.type]!,
      'isVisible': instance.isVisible,
      'headerData': instance.headerData,
      'summaryData': instance.summaryData,
      'experienceData': instance.experienceData,
      'projectData': instance.projectData,
      'educationData': instance.educationData,
      'skillData': instance.skillData,
      'listData': instance.listData,
      'customData': instance.customData,
    };

const _$SectionTypeEnumMap = {
  SectionType.header: 'header',
  SectionType.summary: 'summary',
  SectionType.workExperience: 'workExperience',
  SectionType.projects: 'projects',
  SectionType.education: 'education',
  SectionType.skills: 'skills',
  SectionType.certifications: 'certifications',
  SectionType.languages: 'languages',
  SectionType.custom: 'custom',
};

HeaderModel _$HeaderModelFromJson(Map<String, dynamic> json) => HeaderModel(
  fullName: json['fullName'] as String? ?? '',
  jobTitle: json['jobTitle'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phoneNumber: json['phoneNumber'] as String? ?? '',
  location: json['location'] as String? ?? '',
  website: json['website'] as String? ?? '',
  linkedin: json['linkedin'] as String? ?? '',
  github: json['github'] as String? ?? '',
);

Map<String, dynamic> _$HeaderModelToJson(HeaderModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'jobTitle': instance.jobTitle,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'website': instance.website,
      'linkedin': instance.linkedin,
      'github': instance.github,
    };

ExperienceModel _$ExperienceModelFromJson(Map<String, dynamic> json) =>
    ExperienceModel(
      id: json['id'] as String,
      company: json['company'] as String? ?? '',
      role: json['role'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      descriptionPoints:
          (json['descriptionPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$ExperienceModelToJson(ExperienceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'role': instance.role,
      'location': instance.location,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'descriptionPoints': instance.descriptionPoints,
      'isCurrent': instance.isCurrent,
    };

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  role: json['role'] as String? ?? '',
  technologies:
      (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => ProjectLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  descriptionPoints:
      (json['descriptionPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'role': instance.role,
      'technologies': instance.technologies,
      'links': instance.links,
      'descriptionPoints': instance.descriptionPoints,
    };

ProjectLink _$ProjectLinkFromJson(Map<String, dynamic> json) =>
    ProjectLink(label: json['label'] as String, url: json['url'] as String);

Map<String, dynamic> _$ProjectLinkToJson(ProjectLink instance) =>
    <String, dynamic>{'label': instance.label, 'url': instance.url};

EducationModel _$EducationModelFromJson(Map<String, dynamic> json) =>
    EducationModel(
      id: json['id'] as String,
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['fieldOfStudy'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      gpa: json['gpa'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$EducationModelToJson(EducationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'institution': instance.institution,
      'degree': instance.degree,
      'fieldOfStudy': instance.fieldOfStudy,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'gpa': instance.gpa,
      'description': instance.description,
    };

SkillModel _$SkillModelFromJson(Map<String, dynamic> json) => SkillModel(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  level: json['level'] as String? ?? '',
);

Map<String, dynamic> _$SkillModelToJson(SkillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': instance.level,
    };
