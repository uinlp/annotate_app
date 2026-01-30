import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/components/asset_tile.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/utilities/helper.dart';
import 'package:uinlp_annotate/utilities/status.dart';
import 'package:uinlp_annotate_repository/uinlp_annotate_repository.dart';

class AnnotateAssetScreen extends StatelessWidget {
  const AnnotateAssetScreen({super.key, required this.routerState});
  final GoRouterState routerState;

  static const routeName = "annotate-task-list";

  static const typeQueryParam = "type";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$type Assets")),
      body: BlocListener<AnnotateTaskBloc, AnnotateTaskState>(
        listenWhen: (previous, current) {
          return current.status.event is CreateAnnotateTaskEvent;
        },
        listener: (context, state) {
          if (state.status is LoadingStatus) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state.status is SuccessStatus) {
            context.goNamed(
              AnnotateEditorScreen.routeName,
              queryParameters: {
                AnnotateEditorScreen.idQueryParam: state.status.data,
              },
            );
          }
          if (state.status is ErrorStatus) {
            final errorStatus = state.status as ErrorStatus;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to create annotate task:\n${errorStatus.data.message}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        },
        child: FutureBuilder(
          future: context.read<UinlpAnnotateRepository>().getRecentAssets(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.hasError) {
              debugPrintStack(stackTrace: asyncSnapshot.stackTrace);
              return Center(
                child: Text("Failed to load assets: ${asyncSnapshot.error}"),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (asyncSnapshot.hasData) ...[
                  Text(
                    "Choose an asset to annotate 👇",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  for (final asset in asyncSnapshot.data!)
                    AssetTile(
                      asset: asset,
                      margin: const EdgeInsets.only(bottom: 16),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) =>
                              AnnotateAssetModal(asset: asset),
                        );
                      },
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String get type {
    final rawType = routerState.uri.queryParameters[typeQueryParam];
    if (rawType == null) return "Annotate";
    return TaskTypeEnum.values
        .firstWhere((e) => e.repr == rawType)
        .repr
        .toTitleCase(sep: '_');
  }
}

class AnnotateAssetModal extends StatelessWidget {
  const AnnotateAssetModal({super.key, required this.asset});

  final AnnotateAssetModel asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: getTypeColor(asset.type).withAlpha(25),
                child: Icon(
                  getTypeIcon(asset.type),
                  color: getTypeColor(asset.type),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Created: ${DateFormat.yMMMd().format(asset.createdAt)}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Description",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            asset.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Annotation Modalities",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var modality in asset.modalitySet)
                Chip(
                  label: Text(modality),
                  // avatar: Icon(
                  //   field.type == AnnotateFieldTypeEnum.audio
                  //       ? Icons.mic
                  //       : Icons.text_fields,
                  //   size: 16,
                  // ),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.read<AnnotateTaskBloc>().add(
                CreateAnnotateTaskEvent(asset: asset),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start Annotating"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
