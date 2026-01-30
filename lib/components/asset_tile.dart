import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/utilities/helper.dart';
import 'package:uinlp_annotate/utilities/theme.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';

class AssetTile extends StatelessWidget {
  const AssetTile({
    super.key,
    required this.asset,
    this.onTap,
    this.margin = const .symmetric(horizontal: 16, vertical: 8),
  });

  final AnnotateAssetModel asset;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: .antiAlias,
      margin: margin,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: getTypeColor(asset.type).withAlpha(25),
          child: Icon(
            getTypeIcon(asset.type),
            color: getTypeColor(asset.type),
            size: 20,
          ),
        ),
        title: Text(
          asset.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              asset.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // _buildStatusBadge(theme, asset.status),
                const Spacer(),
                Text(
                  DateFormat('MMM d, h:mm a').format(asset.updatedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, TaskStatusEnum status) {
    Color color;
    String label;
    switch (status) {
      case TaskStatusEnum.completed:
        color = Colors.green;
        label = "Completed";
        break;
      case TaskStatusEnum.inProgress:
        color = Colors.blue;
        label = "In Progress";
        break;
      case TaskStatusEnum.todo:
        color = Colors.grey;
        label = "To Do";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
