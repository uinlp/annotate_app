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

Color getModalityColor(AnnotateModalityEnum modality) {
  switch (modality) {
    case AnnotateModalityEnum.image:
      return Colors.blue;
    case AnnotateModalityEnum.text:
      return Colors.orange;
    case AnnotateModalityEnum.audio:
      return Colors.purple;
    case AnnotateModalityEnum.video:
      return Colors.red;
  }
}

IconData getModalityIcon(AnnotateModalityEnum modality) {
  switch (modality) {
    case AnnotateModalityEnum.image:
      return Icons.image;
    case AnnotateModalityEnum.text:
      return Icons.text_fields;
    case AnnotateModalityEnum.audio:
      return Icons.audio_file;
    case AnnotateModalityEnum.video:
      return Icons.video_file;
  }
}
