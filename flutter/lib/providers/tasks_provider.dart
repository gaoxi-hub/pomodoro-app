import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/storage_keys.dart';
import '../core/models/task.dart';
import '../core/utils/id_utils.dart';
import '../data/repositories/task_repository.dart';
import 'storage_providers.dart';

/// 任务状态：任务列表 + 当前绑定任务 id。
class TasksState {
  final List<Task> tasks;
  final String? currentTaskId;

  const TasksState({this.tasks = const [], this.currentTaskId});

  TasksState copyWith({
    List<Task>? tasks,
    String? currentTaskId,
    bool clearCurrent = false,
  }) =>
      TasksState(
        tasks: tasks ?? this.tasks,
        currentTaskId: clearCurrent ? null : (currentTaskId ?? this.currentTaskId),
      );

  Task? get current {
    if (currentTaskId == null) return null;
    final found = tasks.where((t) => t.id == currentTaskId);
    return found.isEmpty ? null : found.first;
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, TasksState>(TasksNotifier.new);

class TasksNotifier extends AsyncNotifier<TasksState> {
  TaskRepository get _repo => ref.read(taskRepoProvider);

  @override
  Future<TasksState> build() async {
    final tasks = await _repo.load();
    final ls = ref.read(localStorageProvider).requireValue;
    final cur = ls.getString(StorageKeys.currentTaskId);
    final valid = (cur != null && cur != 'null' && tasks.any((t) => t.id == cur))
        ? cur
        : null;
    return TasksState(tasks: tasks, currentTaskId: valid);
  }

  Future<void> _persist(TasksState s) async {
    await _repo.save(s.tasks);
    final ls = ref.read(localStorageProvider).requireValue;
    if (s.currentTaskId == null) {
      await ls.remove(StorageKeys.currentTaskId);
    } else {
      await ls.setString(StorageKeys.currentTaskId, s.currentTaskId!);
    }
    state = AsyncData(s);
  }

  Future<void> add(String name, int estimate) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final t = Task.create(
      id: uid(),
      name: trimmed,
      estimate: estimate.clamp(1, 99),
    );
    await _persist(state.requireValue.copyWith(tasks: [...state.requireValue.tasks, t]));
  }

  Future<void> updateTask(String id, {String? name, int? estimate}) async {
    final tasks = state.requireValue.tasks
        .map((t) => t.id == id
            ? t.copyWith(name: name?.trim(), estimate: estimate)
            : t)
        .toList();
    await _persist(state.requireValue.copyWith(tasks: tasks));
  }

  Future<void> remove(String id) async {
    final tasks = state.requireValue.tasks.where((t) => t.id != id).toList();
    final clear = state.requireValue.currentTaskId == id;
    await _persist(state.requireValue.copyWith(
      tasks: tasks,
      clearCurrent: clear,
    ));
  }

  Future<void> archive(String id) async {
    final tasks = state.requireValue.tasks
        .map((t) => t.id == id ? t.copyWith(archived: true) : t)
        .toList();
    final clear = state.requireValue.currentTaskId == id;
    await _persist(state.requireValue.copyWith(
      tasks: tasks,
      clearCurrent: clear,
    ));
  }

  Future<void> setCurrent(String? id) async {
    await _persist(state.requireValue.copyWith(
      currentTaskId: id,
      clearCurrent: id == null,
    ));
  }

  Future<void> incrementDone(String id) async {
    final tasks = state.requireValue.tasks
        .map((t) => t.id == id ? t.copyWith(done: t.done + 1) : t)
        .toList();
    await _persist(state.requireValue.copyWith(tasks: tasks));
  }
}
