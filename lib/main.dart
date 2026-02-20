import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/utilities/router.dart';
import 'package:uinlp_annotate/utilities/theme.dart';
import 'package:uinlp_annotate_repository/uinlp_annotate_repository.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UinlpAnnotateRepository>(
          create: (context) => UinlpAnnotateRepositoryProd(
            baseUrl:
                "https://cndwf6gz22.execute-api.af-south-1.amazonaws.com/v1/",
          ),
          // dispose: (repository) => repository.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AnnotateTaskBloc(
              repository: context.read<UinlpAnnotateRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'UINLP Annotate',
          theme: appLightTheme,
          darkTheme: appDarkTheme,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
          // builder: (context, child) {
          //   print("Initializing repositories");
          //   return FutureBuilder(
          //     key: ValueKey("123"),
          //     future: context.read<UinlpAnnotateRepository>().init(),
          //     builder: (context, asyncSnapshot) {
          //       if (asyncSnapshot.connectionState != ConnectionState.done) {
          //         return const Center(child: CircularProgressIndicator());
          //       }
          //       return child ?? const SizedBox.shrink();
          //     },
          //   );
          // },
        ),
      ),
    );
  }
}
