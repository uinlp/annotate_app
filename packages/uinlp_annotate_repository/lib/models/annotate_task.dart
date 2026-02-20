import 'dart:convert';
import 'dart:io';

import 'package:uinlp_annotate_repository/repositories/base.dart';

enum TaskStatusEnum { todo, inProgress, completed }

enum TaskTypeEnum { imageToText, textToText }

enum AnnotateModalityEnum { image, text, audio, video }

extension EnumExtension on Enum {
  // separate the enum name(camelCase) with an underscore
  /// Returns the representation of the enum
  String get repr => name
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase();
}

extension AnnotateModalityEnumExtension on AnnotateModalityEnum {
  String get ext {
    switch (this) {
      case AnnotateModalityEnum.image:
        return "jpg";
      case AnnotateModalityEnum.text:
        return "txt";
      case AnnotateModalityEnum.audio:
        return "wav";
      case AnnotateModalityEnum.video:
        return "mp4";
    }
  }
}

extension StringConverterExtension on String {
  String toTitleCase({String sep = " ", String join = " "}) => split(
    sep,
  ).map((word) => word[0].toUpperCase() + word.substring(1)).join(join);
}

class AnnotateFieldModel {
  final String name;
  final AnnotateModalityEnum modality;
  final String description;

  const AnnotateFieldModel({
    required this.name,
    required this.modality,
    required this.description,
  });

  factory AnnotateFieldModel.fromJson(Map<String, dynamic> json) {
    return AnnotateFieldModel(
      name: json['name'],
      modality: modalityFromString(json['modality']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'modality': modality.repr,
      'description': description,
    };
  }
}

class AnnotateTaskModel {
  final String id;
  final String datasetId;
  final String datasetBatchKey;
  final String name;
  final String description;
  final AnnotateModalityEnum modality;
  final TaskStatusEnum status;
  final List<String> dataIds;
  final DateTime lastUpdated;
  final List<AnnotateFieldModel> annotateFields;
  final Map<String, Map<String, dynamic>> commits;
  final List<String> tags;

  AnnotateTaskModel({
    required this.id,
    required this.datasetId,
    required this.datasetBatchKey,
    required this.name,
    required this.description,
    required this.modality,
    required this.status,
    required this.dataIds,
    required this.lastUpdated,
    required this.annotateFields,
    Map<String, Map<String, dynamic>>? commits,
    this.tags = const [],
  }) : commits = commits ?? {};

  double get progress =>
      commits.isEmpty ? 0.0 : (commits.length / dataIds.length);

  Future<File> loadDataFile(int dataIndex) async {
    final workingDir = await getWorkspaceDirectory();
    print(
      "Working directory: ${workingDir.listSync().map((e) => e.path).toList()}",
    );
    final file = File("${workingDir.path}/$id/data/${dataIds[dataIndex]}");
    return file;
  }

  Future<File> loadDataFieldFile(
    int dataIndex,
    AnnotateFieldModel field,
  ) async {
    final workingDir = await getWorkspaceDirectory();
    final file = File(
      "${workingDir.path}/$id/media/${dataIds[dataIndex]}/${field.name}.${field.modality.ext}",
    );
    return file;
  }

  Future<void> updateCommit(
    String dataId,
    Map<String, dynamic> commitData,
  ) async {
    // commits[dataId] = commitData;
    commits.update(dataId, (value) => commitData, ifAbsent: () => commitData);
    // Save task file asynchronously
    // compute((dynamic _) => saveTaskFile(), null); // avoid blocking UI
    await saveTaskFile();
  }

  Future<void> saveTaskFile() async {
    final workingDir = await getWorkspaceDirectory();
    final taskFile = File("${workingDir.path}/$id/task.json");
    await taskFile.writeAsString(jsonEncode(toJson()));
  }

  factory AnnotateTaskModel.fromJson(Map<String, dynamic> json) {
    return AnnotateTaskModel(
      id: json['id'],
      datasetId: json['dataset_id'],
      datasetBatchKey: json['dataset_batch_key'],
      name: json['name'],
      description: json['description'],
      modality: AnnotateModalityEnum.values.firstWhere(
        (e) => e.repr.toLowerCase() == json['modality'].toLowerCase(),
      ),
      status: TaskStatusEnum.values.firstWhere(
        (e) => e.repr.toLowerCase() == json['status'].toLowerCase(),
      ),
      dataIds: List<String>.from(json['data_ids']),
      commits: json['commits'] != null
          ? Map<String, Map<String, dynamic>>.from(json['commits'])
          : {},
      lastUpdated: DateTime.parse(json['last_updated']),
      annotateFields: json['annotate_fields']
          .map<AnnotateFieldModel>(
            (field) => AnnotateFieldModel.fromJson(field),
          )
          .toList(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataset_id': datasetId,
      'dataset_batch_key': datasetBatchKey,
      'name': name,
      'description': description,
      'modality': modality.repr,
      'status': status.repr,
      'data_ids': dataIds,
      'commits': commits,
      'last_updated': lastUpdated.toIso8601String(),
      'annotate_fields': annotateFields.map((e) => e.toJson()).toList(),
      'tags': tags,
    };
  }

  Set<String> get modalitySet {
    final modality = <String>{};
    for (var field in annotateFields) {
      modality.add(field.modality.repr.toTitleCase(sep: '_'));
    }
    return modality;
  }
}

class AnnotateAssetModel {
  final String id;
  final String datasetId;
  final String datasetBatchKey;
  final AnnotateModalityEnum modality;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnnotateFieldModel> annotateFields;
  final List<String> tags;
  final List<String> publishers;

  const AnnotateAssetModel({
    required this.id,
    required this.datasetId,
    required this.datasetBatchKey,
    required this.modality,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.annotateFields,
    this.tags = const [],
    this.publishers = const [],
  });

  factory AnnotateAssetModel.fromJson(Map<String, dynamic> json) {
    return AnnotateAssetModel(
      id: json['id'],
      datasetId: json['dataset_id'],
      datasetBatchKey: json['dataset_batch_key'],
      modality: AnnotateModalityEnum.values.firstWhere(
        (e) => e.repr.toLowerCase() == json['modality'].toLowerCase(),
      ),
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      annotateFields: json['annotate_fields']
          .map<AnnotateFieldModel>(
            (field) => AnnotateFieldModel.fromJson(field),
          )
          .toList(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      publishers: json['publishers'] != null
          ? List<String>.from(json['publishers'])
          : [],
    );
  }

  Set<String> get modalitySet {
    final modality = <String>{};
    for (var field in annotateFields) {
      modality.add(field.modality.repr.toTitleCase(sep: '_'));
    }
    return modality;
  }
}

// UTILITIES
AnnotateModalityEnum modalityFromString(String str) {
  return AnnotateModalityEnum.values.firstWhere(
    (e) => e.repr.toLowerCase() == str.toLowerCase(),
  );
}

class DatasetBatchDownloadModel {
  final String url;

  const DatasetBatchDownloadModel({required this.url});

  factory DatasetBatchDownloadModel.fromJson(Map<String, dynamic> json) {
    return DatasetBatchDownloadModel(url: json['url']);
  }
}
