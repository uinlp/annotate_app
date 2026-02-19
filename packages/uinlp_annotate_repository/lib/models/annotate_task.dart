import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uinlp_annotate_repository/repositories/base.dart';

enum TaskStatusEnum { todo, inProgress, completed }

enum TaskTypeEnum { imageToText, textToText }

enum AnnotateFieldTypeEnum { text, audio }

enum AnnotateModalityEnum { image, text, audio }

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

extension StringConverterExtension on String {
  String toTitleCase({String sep = " ", String join = " "}) => split(
    sep,
  ).map((word) => word[0].toUpperCase() + word.substring(1)).join(join);
}

class AnnotateFieldModel {
  final String name;
  final AnnotateModalityEnum type;
  final String description;

  const AnnotateFieldModel({
    required this.name,
    required this.type,
    required this.description,
  });

  factory AnnotateFieldModel.fromJson(Map<String, dynamic> json) {
    return AnnotateFieldModel(
      name: json['name'],
      // type: AnnotateFieldTypeEnum.values.firstWhere(
      //   (e) => e.repr.toLowerCase() == json['type'].toLowerCase(),
      // ),
      type: modalityFromString(json['type']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type.repr, 'description': description};
  }
}

class AnnotateTaskModel {
  final String id;
  final String dataId;
  final String title;
  final String description;
  final TaskTypeEnum type;
  final TaskStatusEnum status;
  final List<String> dataIds;
  final DateTime lastUpdated;
  final List<AnnotateFieldModel> annotateFields;
  final Map<String, Map<String, dynamic>> commits;
  final List<String> tags;

  AnnotateTaskModel({
    required this.id,
    required this.dataId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.dataIds,
    required this.lastUpdated,
    required this.annotateFields,
    Map<String, Map<String, dynamic>>? commits,
    this.tags = const [],
  }) : commits = commits ?? {};

  double get progress =>
      commits.isEmpty ? 0.0 : (commits.length / dataIds.length);

  Future<String> retrieveDataFileValue(int dataIndex) async {
    final workingDir = await getWorkspaceDirectory();
    print(
      "Working directory: ${workingDir.listSync().map((e) => e.path).toList()}",
    );
    final file = File("${workingDir.path}/$id/data/${dataIds[dataIndex]}");
    return file.readAsStringSync();
  }

  Future<void> updateCommit(String dataId, Map<String, dynamic> commitData) async {
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
      dataId: json['data_id'],
      title: json['title'],
      description: json['description'],
      type: TaskTypeEnum.values.firstWhere(
        (e) => e.repr.toLowerCase() == json['type'].toLowerCase(),
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
      'data_id': dataId,
      'title': title,
      'description': description,
      'type': type.repr,
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
      modality.add(field.type.repr.toTitleCase(sep: '_'));
    }
    return modality;
  }
}

class AnnotateAssetModel {
  final String id;
  final String dataId;
  final TaskTypeEnum type;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnnotateFieldModel> annotateFields;
  final List<String> tags;

  const AnnotateAssetModel({
    required this.id,
    required this.dataId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.annotateFields,
    this.tags = const [],
  });

  factory AnnotateAssetModel.fromJson(Map<String, dynamic> json) {
    return AnnotateAssetModel(
      id: json['id'],
      dataId: json['data_id'],
      type: TaskTypeEnum.values.firstWhere(
        (e) => e.repr.toLowerCase() == json['type'].toLowerCase(),
      ),
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      annotateFields: json['annotate_fields']
          .map<AnnotateFieldModel>(
            (field) => AnnotateFieldModel.fromJson(field),
          )
          .toList(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Set<String> get modalitySet {
    final modality = <String>{};
    for (var field in annotateFields) {
      modality.add(field.type.repr.toTitleCase(sep: '_'));
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
