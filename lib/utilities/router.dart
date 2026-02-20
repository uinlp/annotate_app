import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_asset_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/recent_tasks_screen.dart';
import 'package:uinlp_annotate/features/main/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      name: DashboardScreen.routeName,
      builder: (context, state) => DashboardScreen(),
      routes: [
        GoRoute(
          path: "tasks",
          name: RecentTasksScreen.routeName,
          builder: (context, state) => RecentTasksScreen(),
        ),
        GoRoute(
          path: "assets",
          name: AnnotateAssetScreen.routeName,
          builder: (context, state) => AnnotateAssetScreen(routerState: state),
        ),
        GoRoute(
          path: "editor",
          name: AnnotateEditorScreen.routeName,
          builder: (context, state) => AnnotateEditorScreen(routerState: state),
        ),
      ],
    ),
  ],
);
