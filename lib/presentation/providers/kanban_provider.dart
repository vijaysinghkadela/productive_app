import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_data_source.dart';
import '../../core/security/input_sanitizer.dart';

// ─── Task Entity ───

enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high, urgent }

class KanbanTask {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> labels;
  final int sortOrder;

  const KanbanTask({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.labels = const [],
    this.sortOrder = 0,
  });

  KanbanTask copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? labels,
    int? sortOrder,
  }) {
    return KanbanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      labels: labels ?? this.labels,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.index,
        'priority': priority.index,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'labels': labels,
        'sortOrder': sortOrder,
      };

  factory KanbanTask.fromMap(Map<String, dynamic> map) => KanbanTask(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        status: TaskStatus.values[map['status'] as int? ?? 0],
        priority: TaskPriority.values[map['priority'] as int? ?? 1],
        createdAt: DateTime.parse(map['createdAt'] as String),
        dueDate: map['dueDate'] != null
            ? DateTime.parse(map['dueDate'] as String)
            : null,
        labels: List<String>.from(map['labels'] as List? ?? []),
        sortOrder: map['sortOrder'] as int? ?? 0,
      );

  String get priorityEmoji {
    switch (priority) {
      case TaskPriority.low:
        return '🟢';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.high:
        return '🟠';
      case TaskPriority.urgent:
        return '🔴';
    }
  }
}

// ─── Kanban State ───

class KanbanState {
  final List<KanbanTask> tasks;
  final bool isLoading;

  const KanbanState({this.tasks = const [], this.isLoading = false});

  List<KanbanTask> byStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  int countByStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).length;

  KanbanState copyWith({List<KanbanTask>? tasks, bool? isLoading}) =>
      KanbanState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─── Kanban Notifier ───

class KanbanNotifier extends StateNotifier<KanbanState> {
  final LocalDataSource _dataSource;

  KanbanNotifier(this._dataSource) : super(const KanbanState()) {
    _load();
  }

  void _load() {
    // Load tasks from settings box (will migrate to SQLite in future)
    final stored = _dataSource.getSetting<List<dynamic>>('kanban_tasks');
    if (stored != null) {
      final tasks = stored
          .map((e) => KanbanTask.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      state = state.copyWith(tasks: tasks);
    }
  }

  Future<void> _save() async {
    await _dataSource.saveSetting(
      'kanban_tasks',
      state.tasks.map((t) => t.toMap()).toList(),
    );
  }

  Future<void> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> labels = const [],
  }) async {
    final sanitizedTitle = InputSanitizer.sanitizeTextField(title);
    final sanitizedDesc = description != null
        ? InputSanitizer.sanitizeTextField(description)
        : null;

    final task = KanbanTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: sanitizedTitle,
      description: sanitizedDesc,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      labels: labels,
      sortOrder: state.countByStatus(TaskStatus.todo),
    );

    state = state.copyWith(tasks: [...state.tasks, task]);
    await _save();
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: newStatus,
            sortOrder: state.countByStatus(newStatus),
          );
        }
        return t;
      }).toList(),
    );
    await _save();
  }

  Future<void> updateTask(KanbanTask updated) async {
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == updated.id ? updated : t).toList(),
    );
    await _save();
  }

  Future<void> deleteTask(String taskId) async {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
    );
    await _save();
  }

  Future<void> reorder(TaskStatus status, int oldIndex, int newIndex) async {
    final column = state.byStatus(status);
    final item = column.removeAt(oldIndex);
    column.insert(newIndex, item);

    // Update sort orders
    final reordered = <KanbanTask>[];
    for (var i = 0; i < column.length; i++) {
      reordered.add(column[i].copyWith(sortOrder: i));
    }

    // Merge back
    final allTasks = state.tasks.where((t) => t.status != status).toList()
      ..addAll(reordered);

    state = state.copyWith(tasks: allTasks);
    await _save();
  }
}

// ─── Providers ───

final kanbanProvider =
    StateNotifierProvider.autoDispose<KanbanNotifier, KanbanState>(
  (ref) => KanbanNotifier(ref.read(_localDataSourceProvider)),
);

// Re-export for convenience
final _localDataSourceProvider =
    Provider<LocalDataSource>((ref) => LocalDataSource());
