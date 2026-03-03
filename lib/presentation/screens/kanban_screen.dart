// ignore_for_file: discarded_futures, inference_failure_on_function_invocation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/theme.dart';
import 'package:focusguard_pro/presentation/providers/kanban_provider.dart';

/// Kanban-style task board with three columns: To Do, In Progress, Done.
/// Supports drag-and-drop reordering, swipe actions, and task creation.
class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kanban = ref.watch(kanbanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Task',
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: PageView(
        children: [
          _buildColumn(
            context,
            kanban,
            'To Do',
            TaskStatus.todo,
            AppColors.secondary,
            Icons.radio_button_unchecked_rounded,
          ),
          _buildColumn(
            context,
            kanban,
            'In Progress',
            TaskStatus.inProgress,
            AppColors.warning,
            Icons.timelapse_rounded,
          ),
          _buildColumn(
            context,
            kanban,
            'Done',
            TaskStatus.done,
            AppColors.success,
            Icons.check_circle_rounded,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatusChip(
              'To Do',
              kanban.countByStatus(TaskStatus.todo),
              AppColors.secondary,
            ),
            _buildStatusChip(
              'In Progress',
              kanban.countByStatus(TaskStatus.inProgress),
              AppColors.warning,
            ),
            _buildStatusChip(
              'Done',
              kanban.countByStatus(TaskStatus.done),
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: GlassDecoration.pill(color),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$label ($count)',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      );

  Widget _buildColumn(
    BuildContext context,
    KanbanState kanban,
    String title,
    TaskStatus status,
    Color color,
    IconData icon,
  ) {
    final tasks = kanban.byStatus(status);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Column header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconLg),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: theme.textTheme.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: GlassDecoration.pill(color),
                child: Text(
                  '${tasks.length}',
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
        // Task list
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 48,
                          color: color.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No tasks here',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: tasks.length,
                  onReorder: (oldIdx, newIdx) {
                    if (newIdx > oldIdx) newIdx--;
                    ref
                        .read(kanbanProvider.notifier)
                        .reorder(status, oldIdx, newIdx);
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _KanbanTaskCard(
                      key: ValueKey(task.id),
                      task: task,
                      color: color,
                      onMove: (newStatus) {
                        ref
                            .read(kanbanProvider.notifier)
                            .moveTask(task.id, newStatus);
                      },
                      onDelete: () {
                        ref.read(kanbanProvider.notifier).deleteTask(task.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _titleController.clear();
    _descController.clear();
    _selectedPriority = TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Task',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'What needs to be done?',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add details...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Priority selector
              Wrap(
                spacing: AppSpacing.sm,
                children: TaskPriority.values.map((p) {
                  final selected = p == _selectedPriority;
                  return ChoiceChip(
                    label: Text(_priorityLabel(p)),
                    selected: selected,
                    onSelected: (val) {
                      setSheetState(() => _selectedPriority = p);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;
                  ref.read(kanbanProvider.notifier).addTask(
                        title: _titleController.text.trim(),
                        description: _descController.text.trim().isEmpty
                            ? null
                            : _descController.text.trim(),
                        priority: _selectedPriority,
                      );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return '🟢 Low';
      case TaskPriority.medium:
        return '🟡 Medium';
      case TaskPriority.high:
        return '🟠 High';
      case TaskPriority.urgent:
        return '🔴 Urgent';
    }
  }
}

class _KanbanTaskCard extends StatelessWidget {
  const _KanbanTaskCard({
    required this.task,
    required this.color,
    required this.onMove,
    required this.onDelete,
    super.key,
  });
  final KanbanTask task;
  final Color color;
  final void Function(TaskStatus) onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey('dismiss_${task.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.alert.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.alert),
        ),
        onDismissed: (_) => onDelete(),
        child: Container(
          decoration: GlassDecoration.card,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    task.priorityEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Move menu
                  PopupMenuButton<TaskStatus>(
                    icon: Icon(
                      Icons.more_vert,
                      size: AppSizes.iconMd,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context) => TaskStatus.values
                        .where((s) => s != task.status)
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(_statusLabel(s)),
                          ),
                        )
                        .toList(),
                    onSelected: onMove,
                  ),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (task.dueDate != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: AppSizes.iconSm,
                      color: color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ],
              if (task.labels.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: task.labels
                      .map(
                        (l) => Chip(
                          label: Text(l),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return '📋 Move to To Do';
      case TaskStatus.inProgress:
        return '⏳ Move to In Progress';
      case TaskStatus.done:
        return '✅ Move to Done';
    }
  }
}
