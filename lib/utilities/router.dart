import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_asset_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/image_to_text_screen.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/text_to_text_screen.dart';
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
          path: "image-to-text",
          name: ImageToTextScreen.routeName,
          builder: (context, state) => ImageToTextScreen(),
        ),
        GoRoute(
          path: "text-to-text",
          name: TextToTextScreen.routeName,
          builder: (context, state) => TextToTextScreen(),
        ),
        GoRoute(
          path: "annotate-asset",
          name: AnnotateAssetScreen.routeName,
          builder: (context, state) => AnnotateAssetScreen(routerState: state),
        ),
        GoRoute(
          path: "annotate-editor",
          name: AnnotateEditorScreen.routeName,
          builder: (context, state) => AnnotateEditorScreen(routerState: state),
        ),
      ],
    ),
  ],
);
