import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/utilities/status.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';
import 'package:uinlp_annotate_repository/exceptions.dart';
import 'package:uinlp_annotate_repository/repositories/base.dart';

part 'annotate_task_event.dart';
part 'annotate_task_state.dart';

class AnnotateTaskBloc extends Bloc<AnnotateTaskEvent, AnnotateTaskState> {
  final UinlpAnnotateRepository repository;
  AnnotateTaskBloc({required this.repository}) : super(AnnotateTaskState()) {
    on<LoadAnnotateTaskEvent>((event, emit) async {
      debugPrint("Loading annotate tasks");
      emit(state.copyWith(status: LoadingStatus(event: event)));
      try {
        final tasks = await repository.getRecentTasks();
        debugPrint("Loaded annotate tasks: ${tasks.length}");
        emit(
          state.copyWith(
            status: SuccessStatus(data: tasks, event: event),
            tasks: tasks,
          ),
        );
      } catch (e) {
        debugPrint("Failed to load annotate tasks: $e");
        emit(
          state.copyWith(
            status: ErrorStatus(
              event: event,
              data: RepositoryException.fromCatch(e),
            ),
          ),
        );
      }
      emit(state.copyWith(status: const IdleStatus()));
    });
    on<CreateAnnotateTaskEvent>((event, emit) async {
      debugPrint("Creating annotate task");
      emit(state.copyWith(status: LoadingStatus(event: event)));
      try {
        final task = await repository.createAnnotateTask(asset: event.asset);
        debugPrint("Created annotate task: ${task.id}");
        emit(
          state.copyWith(
            status: SuccessStatus(data: task.id, event: event),
            tasks: [task, ...state.tasks],
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: ErrorStatus(
              event: event,
              data: RepositoryException.fromCatch(e),
            ),
          ),
        );
      }
      emit(state.copyWith(status: const IdleStatus()));
    });
  }
}
