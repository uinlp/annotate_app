import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/components/activity_tile.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/utilities/status.dart';

class RecentTasksScreen extends StatelessWidget {
  const RecentTasksScreen({super.key});

  static const routeName = 'recent-tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent Tasks")),
      body: BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
        builder: (context, state) {
          if (state.status is LoadingStatus) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.tasks.isEmpty) {
            return Center(child: Text("No recent tasks"));
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return ActivityTile(
                task: task,
                onTap: () {
                  context.goNamed(
                    AnnotateEditorScreen.routeName,
                    queryParameters: {
                      AnnotateEditorScreen.idQueryParam: task.id,
                    },
                  );
                },
              );
            },
            itemCount: state.tasks.length,
          );
        },
      ),
    );
  }
}
