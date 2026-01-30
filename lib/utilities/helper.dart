import 'package:flutter/material.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';

Color getStatusColor(TaskStatusEnum status) {
  switch (status) {
    case TaskStatusEnum.completed:
      return Colors.green;
    case TaskStatusEnum.inProgress:
      return Colors.blue;
    case TaskStatusEnum.todo:
      return Colors.grey;
  }
}

Color getTypeColor(TaskTypeEnum type) {
  switch (type) {
    case TaskTypeEnum.imageToText:
      return Colors.blue;
    case TaskTypeEnum.textToText:
      return Colors.orange;
  }
}

IconData getTypeIcon(TaskTypeEnum type) {
  switch (type) {
    case TaskTypeEnum.imageToText:
      return Icons.image;
    case TaskTypeEnum.textToText:
      return Icons.text_fields;
  }
}
