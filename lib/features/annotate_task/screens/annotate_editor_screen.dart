import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/main/screens/dashboard_screen.dart';
import 'package:uinlp_annotate/utilities/helper.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';

class AnnotateEditorScreen extends StatefulWidget {
  const AnnotateEditorScreen({super.key, required this.routerState});
  final GoRouterState routerState;

  static const String routeName = "annotate-editor";
  static const String idQueryParam = "id";

  @override
  State<AnnotateEditorScreen> createState() => _AnnotateEditorScreenState();
}

class _AnnotateEditorScreenState extends State<AnnotateEditorScreen> {
  List<AnnotateFieldStateModel> fields = [];
  String? taskId;
  int currentDataIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("I'm here");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      taskId = widget
          .routerState
          .uri
          .queryParameters[AnnotateEditorScreen.idQueryParam];
      final state = context.read<AnnotateTaskBloc>().state;
      final task = state.tasks.where((e) => e.id == taskId).firstOrNull;
      debugPrint("Task field count: ${task?.annotateFields.length}");
      setState(() {
        if (task != null) {
          fields = task.annotateFields
              .map(
                (e) => AnnotateFieldStateModel(
                  name: e.name,
                  type: e.type,
                  description: e.description,
                ),
              )
              .toList();
        }
      });
    });
  }

  void goto(int index) {
    setState(() {
      currentDataIndex = index;
    });
  }

  void next() {
    final totalData = context.read<AnnotateTaskBloc>().state.tasks
        .where((e) => e.id == taskId)
        .firstOrNull
        ?.dataIds
        .length;
    if (totalData == null) return;
    if (currentDataIndex < (totalData - 1)) {
      setState(() {
        currentDataIndex += 1;
      });
    }
  }

  void previous() {
    if (currentDataIndex > 0) {
      setState(() {
        currentDataIndex -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Annotate Editor [${currentDataIndex + 1}]"),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  final scaffold = Scaffold.of(context);
                  if (scaffold.hasEndDrawer) {
                    scaffold.openEndDrawer();
                  }
                },
                icon: Icon(Icons.info_outline),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: .all(16),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Data display area
            DataDisplay(taskId: taskId, currentDataIndex: currentDataIndex),
            for (var field in fields)
              // Text(field.name),
              if (field.type == AnnotateModalityEnum.text)
                TextField(
                  controller: field.textController,
                  decoration: InputDecoration(
                    labelText: field.name.toTitleCase(),
                    hintText: field.description,
                  ),
                )
              else if (field.type == AnnotateModalityEnum.audio)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Audio Recording Field (#TODO)",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      drawer: AnnotatedEditorDrawer(
        taskId: taskId,
        currentDataIndex: currentDataIndex,
        onDataIndexPressed: (index) {
          goto(index);
          context.pop();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("More Actions", style: theme.textTheme.titleLarge),
                  ListTile(
                    leading: Icon(Icons.save),
                    title: Text("Save"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_forward),
                    title: Text("Next"),
                    onTap: () {
                      next();
                      context.pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_back),
                    title: Text("Previous"),
                    onTap: () {
                      previous();
                      context.pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Save & Exit"),
                    onTap: () {
                      context.goNamed(DashboardScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.publish),
                    title: Text("Publish"),
                    onTap: () {},
                    enabled: false,
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        color: theme.colorScheme.surfaceContainerLow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomActionButton(
              icon: Icons.arrow_back,
              label: "Previous",
              onPressed: () {
                previous();
              },
            ),
            BottomActionButton(
              icon: Icons.arrow_forward,
              label: "Save & Next",
              onPressed: () {
                next();
              },
            ),
          ],
        ),
      ),
      endDrawer: AnnotateEditorEndDrawer(taskId: taskId),
    );
  }
}

class AnnotatedEditorDrawer extends StatelessWidget {
  const AnnotatedEditorDrawer({
    super.key,
    required this.taskId,
    this.onDataIndexPressed,
    this.currentDataIndex,
  });
  final String? taskId;
  final void Function(int index)? onDataIndexPressed;
  final int? currentDataIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Activity Grid", style: theme.textTheme.titleLarge),
            ),
            Expanded(
              child:
                  BlocSelector<
                    AnnotateTaskBloc,
                    AnnotateTaskState,
                    AnnotateTaskModel?
                  >(
                    selector: (state) {
                      return state.tasks
                          .where((e) => e.id == taskId)
                          .firstOrNull;
                    },
                    builder: (context, task) {
                      if (task == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: task.dataIds.length,
                        itemBuilder: (context, index) {
                          return FilledButton(
                            onPressed: () {
                              onDataIndexPressed?.call(index);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  task.commits.containsKey(task.dataIds[index])
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withAlpha(25),
                              foregroundColor:
                                  task.commits.containsKey(task.dataIds[index])
                                  ? theme.colorScheme.primary.withAlpha(25)
                                  : theme.colorScheme.primary,
                              side: currentDataIndex == index
                                  ? BorderSide(
                                      color: theme.colorScheme.secondary,
                                    )
                                  : BorderSide.none,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Tooltip(
                              message: task.dataIds[index],
                              child: Text("${index + 1}"),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataDisplay extends StatelessWidget {
  const DataDisplay({
    super.key,
    required this.taskId,
    required this.currentDataIndex,
  });

  final String? taskId;
  final int currentDataIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<
      AnnotateTaskBloc,
      AnnotateTaskState,
      AnnotateTaskModel?
    >(
      selector: (state) {
        return state.tasks.where((e) => e.id == taskId).firstOrNull;
      },
      builder: (context, state) {
        if (state == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: state.retrieveDataFileValue(currentDataIndex),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  return Text(
                    "Error loading data ${asyncSnapshot.error}",
                    style: theme.textTheme.headlineMedium,
                  );
                }
                if (!asyncSnapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  asyncSnapshot.data as String,
                  style: theme.textTheme.headlineMedium,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class BottomActionButton extends StatelessWidget {
  const BottomActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), Text(label)],
          ),
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Text(
    title,
    style: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    ),
  );
}

class AnnotateEditorEndDrawer extends StatelessWidget {
  const AnnotateEditorEndDrawer({super.key, required this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
          builder: (context, state) {
            final task = state.tasks.where((e) => e.id == taskId).firstOrNull;
            if (task == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: getTypeColor(task!.type).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          getTypeIcon(task!.type),
                          color: getTypeColor(task!.type),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task!.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(
                                  task!.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task!.status.name.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: getStatusColor(task!.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionHeader(theme, "Progress"),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: task!.progress,
                          minHeight: 12,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(task!.progress * 100).toInt()}% Completed",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(theme, "About this task"),
                      const SizedBox(height: 8),
                      Text(
                        task!.description,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Last Updated: ${DateFormat.yMMMd().add_jm().format(task!.lastUpdated)}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(theme, "Modalities"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var modality in task!.modalitySet)
                            Chip(
                              label: Text(modality),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(theme, "Input Fields"),
                      const SizedBox(height: 12),
                      for (var field in task!.annotateFields)
                        Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      field.name.toTitleCase(),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        field.type.repr.toTitleCase(sep: '_'),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  field.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnnotateFieldStateModel extends AnnotateFieldModel {
  AnnotateFieldStateModel({
    required super.name,
    required super.type,
    required super.description,
    TextEditingController? textController,
    String? audioCachePath,
  }) : textController = type == AnnotateModalityEnum.text
           ? (textController ?? TextEditingController())
           : null,
       audioCachePath = type == AnnotateModalityEnum.audio
           ? (audioCachePath ?? "cache/$name.wav")
           : null;
  final TextEditingController? textController;
  final String? audioCachePath;
}
