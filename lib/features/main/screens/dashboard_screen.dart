import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  static const routeName = "dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UINLP Annotate")),
      body: ListView(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: .all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              for (var tab in _taskTabs)
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: .center,
                    decoration: BoxDecoration(
                      borderRadius: .circular(8),
                      border: .all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      tab.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  onTap: () => context.goNamed(tab.routeName),
                ),
            ],
          ),
        ],
      ),
    );
  }

  final _taskTabs = [
    TaskTabModel(title: "Image to Text", routeName: "image_to_text"),
    TaskTabModel(title: "Text to Text", routeName: "text_to_text"),
  ];
}

class TaskTabModel {
  final String title;
  final String routeName;

  TaskTabModel({required this.title, required this.routeName});
}
