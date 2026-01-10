import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/features/main/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      name: DashboardScreen.routeName,
      builder: (context, state) => DashboardScreen(),
    ),
  ],
);
