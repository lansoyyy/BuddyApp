import 'package:buddyapp/services/storage_service.dart';
import 'package:buddyapp/utils/app_constants.dart';

class MasterDataService {
  static MasterDataService? _instance;
  final StorageService _storage;

  static const String _workordersKey = 'master_workorders';
  static const String _componentsKey = 'master_components';
  static const String _processStagesKey = 'master_process_stages';
  static const String _componentStampsKey = 'master_component_stamps';

  MasterDataService._(this._storage);

  static Future<MasterDataService> getInstance() async {
    if (_instance != null) return _instance!;
    final storage = await StorageService.getInstance();
    _instance = MasterDataService._(storage);
    return _instance!;
  }

  Future<List<String>> _getList(String key, {List<String>? fallback}) async {
    final list = _storage.getStringList(key);
    if (list != null) {
      return List<String>.from(list);
    }
    if (fallback != null) {
      return List<String>.from(fallback);
    }
    return <String>[];
  }

  Future<void> _setList(String key, List<String> value) async {
    await _storage.setStringList(key, value);
  }

  Future<List<String>> getWorkorders() {
    return _getList(_workordersKey);
  }

  Future<void> addWorkorder(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final list = await getWorkorders();
    if (!list.contains(trimmed)) {
      list.add(trimmed);
      await _setList(_workordersKey, list);
    }
  }

  Future<void> removeWorkorder(String value) async {
    final list = await getWorkorders();
    list.remove(value);
    await _setList(_workordersKey, list);
  }

  Future<List<String>> getComponents() {
    return _getList(_componentsKey);
  }

  Future<void> addComponent(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final list = await getComponents();
    if (!list.contains(trimmed)) {
      list.add(trimmed);
      await _setList(_componentsKey, list);
    }
  }

  Future<void> removeComponent(String value) async {
    final list = await getComponents();
    list.remove(value);
    await _setList(_componentsKey, list);
  }

  Future<List<String>> getProcessStages() async {
    // Default to AppConstants.processStages if nothing stored yet
    return _getList(_processStagesKey, fallback: AppConstants.processStages);
  }

  Future<void> addProcessStage(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final list = await getProcessStages();
    if (!list.contains(trimmed)) {
      list.add(trimmed);
      await _setList(_processStagesKey, list);
    }
  }

  Future<void> removeProcessStage(String value) async {
    final list = await getProcessStages();
    list.remove(value);
    await _setList(_processStagesKey, list);
  }

  Future<List<String>> getComponentStamps() {
    return _getList(_componentStampsKey);
  }

  Future<void> addComponentStamp(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final list = await getComponentStamps();
    if (!list.contains(trimmed)) {
      list.add(trimmed);
      await _setList(_componentStampsKey, list);
    }
  }

  Future<void> removeComponentStamp(String value) async {
    final list = await getComponentStamps();
    list.remove(value);
    await _setList(_componentStampsKey, list);
  }
}
