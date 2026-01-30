import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';
import 'package:uinlp_annotate_repository/models/user_stats.dart';

abstract base class UinlpAnnotateRepository {
  const UinlpAnnotateRepository();

  Future<void> init();

  Future<void> dispose();

  Future<UserStatsModel> getUserStatsModel();
  Future<List<AnnotateTaskModel>> getRecentTasks({
    int limit = 10,
    int offset = 0,
  });
  Future<List<AnnotateAssetModel>> getRecentAssets({
    int limit = 10,
    int offset = 0,
  });
  Future<AnnotateTaskModel> createAnnotateTask({
    required AnnotateAssetModel asset,
  });
  // Future<List<TaskTypeEnum>> getAvailableTaskTypeEnums(); // TaskTypeEnum is an enum, maybe just hardcode or return list of available ones if dynamic.
}

class AnnotateLocalStore {
  final String dbName;
  late final Database db;
  AnnotateLocalStore(this.dbName);

  Future<void> init() async {
    db = sqlite3.open(
      Directory(
        "${(await getApplicationDocumentsDirectory()).path}/$dbName",
      ).path,
    );
    debugPrint("Database opened");
    db.execute('PRAGMA foreign_keys = ON;');
    db.execute('''CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY, 
      title TEXT, 
      description TEXT, 
      type TEXT, 
      status TEXT, 
      progress REAL, 
      last_updated TEXT, 
      local_path TEXT
    );''');
    db.execute('''CREATE TABLE IF NOT EXISTS fields (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      name TEXT, 
      type TEXT, 
      description TEXT,
      task_id TEXT,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );''');
  }

  void close() {
    db.close();
  }

  void insertTask(AnnotateTaskModel task) {
    db.execute(
      '''
      INSERT OR REPLACE INTO tasks (id, title, description, type, status, progress, last_updated, local_path)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    ''',
      [
        task.id,
        task.title,
        task.description,
        task.type.repr,
        task.status.repr,
        task.progress,
        task.lastUpdated.toIso8601String(),
        // task.localPath,
      ],
    );
    // Explicitly delete old fields just in case replace didn't cascade (replace on task might, but cleaner to be sure or rely on FK)
    // Actually, INSERT OR REPLACE on primary key deletes the old row, which triggers cascading delete on child rows if PRAGMA foreign_keys = ON.

    for (var field in task.annotateFields) {
      _insertField(field, task.id);
    }
  }

  void _insertField(AnnotateFieldModel field, String taskId) {
    db.execute(
      '''
      INSERT INTO fields (name, type, description, task_id)
      VALUES (?, ?, ?, ?);
    ''',
      [field.name, field.type.repr, field.description, taskId],
    );
  }

  List<AnnotateFieldModel> _selectFields(String taskId) {
    return db
        .select('SELECT * FROM fields WHERE task_id = ?', [taskId])
        .map((row) => AnnotateFieldModel.fromJson(row))
        .toList();
  }

  List<AnnotateTaskModel> selectTasks([
    List<String>? where,
    List<String>? whereValue,
  ]) {
    final where_ = where?.join(' LIKE ? AND ');
    return db
        .select(
          'SELECT * FROM tasks${where_ != null ? ' WHERE $where_ LIKE ?' : ''}',
          whereValue ?? [],
        )
        .map((row) {
          final taskId = row['id'] as String;
          final fields = _selectFields(taskId);

          final rowMap = Map<String, dynamic>.from(row);
          rowMap['annotate_fields'] = fields.map((e) => e.toJson()).toList();

          return AnnotateTaskModel.fromJson(rowMap);
        })
        .toList();
  }

  void deleteTask(String taskId) {
    db.execute('DELETE FROM tasks WHERE id = ?', [taskId]);
  }
}

Future<Directory> getWorkspaceDirectory() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final workspaceDir = Directory("${appDocDir.path}/uinlp_workspace");
  if (!await workspaceDir.exists()) {
    await workspaceDir.create(recursive: true);
  }
  return workspaceDir;
}
