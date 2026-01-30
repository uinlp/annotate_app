import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/components/activity_tile.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_asset_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';

class TextToTextScreen extends StatelessWidget {
  const TextToTextScreen({super.key});

  static const routeName = 'text-to-text';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Text To Text")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 16,
            children: [
              Text("Translate text ✨", style: theme.textTheme.headlineSmall),
              TextButton(
                onPressed: () {
                  context.goNamed(
                    AnnotateAssetScreen.routeName,
                    queryParameters: {
                      AnnotateAssetScreen.typeQueryParam:
                          TaskTypeEnum.textToText.repr,
                    },
                  );
                },
                child: Text("New Task"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "Recent Activity",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRecentActivityList(theme),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(ThemeData theme) {
    return BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
      builder: (context, state) {
        return Column(
          children: [
            for (final task in state.filteredTasks(TaskTypeEnum.textToText))
              ActivityTile(
                margin: .symmetric(vertical: 8),
                task: task,
                onTap: () {
                  context.goNamed(
                    AnnotateEditorScreen.routeName,
                    queryParameters: {
                      AnnotateEditorScreen.idQueryParam: task.id,
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
