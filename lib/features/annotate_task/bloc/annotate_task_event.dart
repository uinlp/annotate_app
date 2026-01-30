part of 'annotate_task_bloc.dart';

class AnnotateTaskEvent {}

class LoadAnnotateTaskEvent extends AnnotateTaskEvent {}

class CreateAnnotateTaskEvent extends AnnotateTaskEvent {
  final AnnotateAssetModel asset;
  CreateAnnotateTaskEvent({required this.asset});
}
