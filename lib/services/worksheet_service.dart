import 'dart:convert';
import 'package:buddyapp/services/storage_service.dart';

class WorksheetData {
  final String id;
  final String worksheetNumber;
  final String jobName;
  final String component;
  final String quantity;
  final String description;
  final String status;
  final String priority;
  final String assignedTo;
  final String dueDate;
  final String notes;
  final DateTime createdAt;
  final String? imagePath;

  WorksheetData({
    required this.id,
    required this.worksheetNumber,
    required this.jobName,
    required this.component,
    required this.quantity,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.dueDate,
    this.notes = '',
    required this.createdAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worksheetNumber': worksheetNumber,
      'jobName': jobName,
      'component': component,
      'quantity': quantity,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory WorksheetData.fromMap(Map<String, dynamic> map) {
    return WorksheetData(
      id: map['id'] as String,
      worksheetNumber: map['worksheetNumber'] as String,
      jobName: map['jobName'] as String,
      component: map['component'] as String,
      quantity: map['quantity'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      priority: map['priority'] as String,
      assignedTo: map['assignedTo'] as String,
      dueDate: map['dueDate'] as String,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      imagePath: map['imagePath'] as String?,
    );
  }

  WorksheetData copyWith({
    String? id,
    String? worksheetNumber,
    String? jobName,
    String? component,
    String? quantity,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    String? dueDate,
    String? notes,
    DateTime? createdAt,
    String? imagePath,
  }) {
    return WorksheetData(
      id: id ?? this.id,
      worksheetNumber: worksheetNumber ?? this.worksheetNumber,
      jobName: jobName ?? this.jobName,
      component: component ?? this.component,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class WorksheetService {
  static WorksheetService? _instance;
  final StorageService _storage;

  static const String _worksheetsKey = 'worksheets';

  WorksheetService._(this._storage);

  static Future<WorksheetService> getInstance() async {
    if (_instance != null) return _instance!;
    final storage = await StorageService.getInstance();
    _instance = WorksheetService._(storage);
    return _instance!;
  }

  List<WorksheetData> _getWorksheetsList() {
    final jsonString = _storage.getString(_worksheetsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => WorksheetData.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveWorksheetsList(List<WorksheetData> worksheets) async {
    final jsonString = jsonEncode(worksheets.map((w) => w.toMap()).toList());
    await _storage.setString(_worksheetsKey, jsonString);
  }

  Future<List<WorksheetData>> getAllWorksheets() async {
    return _getWorksheetsList();
  }

  Future<WorksheetData?> getWorksheetById(String id) async {
    final worksheets = _getWorksheetsList();
    try {
      return worksheets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<WorksheetData?> getWorksheetByNumber(String worksheetNumber) async {
    final worksheets = _getWorksheetsList();
    try {
      return worksheets.firstWhere((w) => w.worksheetNumber == worksheetNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> addWorksheet(WorksheetData worksheet) async {
    final worksheets = _getWorksheetsList();
    worksheets.add(worksheet);
    await _saveWorksheetsList(worksheets);
  }

  Future<void> updateWorksheet(WorksheetData worksheet) async {
    final worksheets = _getWorksheetsList();
    final index = worksheets.indexWhere((w) => w.id == worksheet.id);
    if (index != -1) {
      worksheets[index] = worksheet;
      await _saveWorksheetsList(worksheets);
    }
  }

  Future<void> deleteWorksheet(String id) async {
    final worksheets = _getWorksheetsList();
    worksheets.removeWhere((w) => w.id == id);
    await _saveWorksheetsList(worksheets);
  }

  Future<void> deleteAllWorksheets() async {
    await _storage.remove(_worksheetsKey);
  }

  int getWorksheetCount() {
    return _getWorksheetsList().length;
  }
}
