import 'package:equatable/equatable.dart';

import '../../data/models/resume_models.dart';

abstract class ResumeState extends Equatable {
  const ResumeState();

  @override
  List<Object?> get props => [];
}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumeListLoaded extends ResumeState {
  final List<Map<String, dynamic>> resumes;
  const ResumeListLoaded(this.resumes);

  @override
  List<Object?> get props => [resumes];
}

class ResumeUpdated extends ResumeState {
  final ResumeModel resume;
  final bool isAtsView;
  final bool isSaving;

  const ResumeUpdated(
    this.resume, {
    this.isAtsView = false,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [resume, isAtsView, isSaving];

  ResumeUpdated copyWith({
    ResumeModel? resume,
    bool? isAtsView,
    bool? isSaving,
  }) {
    return ResumeUpdated(
      resume ?? this.resume,
      isAtsView: isAtsView ?? this.isAtsView,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ResumeError extends ResumeState {
  final String message;
  const ResumeError(this.message);

  @override
  List<Object?> get props => [message];
}
