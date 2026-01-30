import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/components/activity_tile.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/image_to_text_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/text_to_text_screen.dart';
import 'package:uinlp_annotate/utilities/status.dart';
import 'package:uinlp_annotate_repository/uinlp_annotate_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = "dashboard";

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Using the mock repository directly. In a real app, use Provider/GetIt/Bloc.
  late final UinlpAnnotateRepository _repository;

  late Future<UserStatsModel> _statsFuture;

  @override
  void initState() {
    super.initState();
    _repository = context.read<UinlpAnnotateRepository>();
    _loadData();
    context.read<AnnotateTaskBloc>().add(LoadAnnotateTaskEvent());
  }

  void _loadData() {
    _statsFuture = _repository.getUserStatsModel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final ittTasks = context.read<ImageToTextBloc>().state.tasks;
    // List<AnnotateTaskModel> recentTasks = [...ittTasks]
    //   ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("UINLP Annotate"),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(theme),
                  const SizedBox(height: 24),
                  _buildStatsSection(theme),
                  const SizedBox(height: 32),
                  Text(
                    "Start Annotating",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionGrid(context, theme),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Activity",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildRecentActivityList(theme),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "Hi, ", style: theme.textTheme.headlineSmall),
          TextSpan(
            text: "Ahmad",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "\nLet's clear some tasks today!",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return FutureBuilder<UserStatsModel>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: LinearProgressIndicator());
        }
        final stats = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                theme,
                stats.tasksCompleted.toString(),
                "Completed",
                Icons.check_circle_outline,
              ),
              _buildStatItem(
                theme,
                stats.tasksInProgress.toString(),
                "In Progress",
                Icons.pending_actions,
              ),
              _buildStatItem(
                theme,
                "${stats.hoursSpent}h",
                "Hours",
                Icons.timer_outlined,
              ),
              _buildStatItem(
                theme,
                "${(stats.accuracy * 100).toInt()}%",
                "Accuracy",
                Icons.analytics_outlined,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          theme,
          "Image to Text",
          "Extract text from images",
          Icons.image_search,
          Colors.blue,
          ImageToTextScreen.routeName,
        ),
        _buildActionCard(
          context,
          theme,
          "Text to Text",
          "Translation & Summary",
          Icons.translate,
          Colors.orange,
          TextToTextScreen.routeName,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String routeName,
  ) {
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withAlpha(100),
      child: InkWell(
        onTap: () {
          // Only navigate if route exists, for now just print or show snackbar if not implemented in router
          try {
            context.goNamed(routeName);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Route $routeName not implemented yet!")),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(ThemeData theme) {
    return BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
      builder: (context, state) {
        if (state.status is LoadingStatus) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final task = state.tasks[index];
            return ActivityTile(
              task: task,
              onTap: () {
                context.goNamed(
                  AnnotateEditorScreen.routeName,
                  queryParameters: {AnnotateEditorScreen.idQueryParam: task.id},
                );
              },
            );
          }, childCount: state.tasks.length),
        );
      },
    );
  }
}
