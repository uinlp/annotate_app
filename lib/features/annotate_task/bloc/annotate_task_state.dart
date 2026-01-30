part of 'annotate_task_bloc.dart';

class AnnotateTaskState {
  final Status status;
  final List<AnnotateTaskModel> tasks;
  AnnotateTaskState({this.status = const IdleStatus(), this.tasks = const []});

  AnnotateTaskState copyWith({Status? status, List<AnnotateTaskModel>? tasks}) {
    return AnnotateTaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }

  List<AnnotateTaskModel> filteredTasks(TaskTypeEnum type) {
    return tasks.where((element) {
      return element.type == type;
    }).toList();
  }
}
