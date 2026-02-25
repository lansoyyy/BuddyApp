import 'dart:convert';
import 'package:buddyapp/services/storage_service.dart';

class IncomingShipment {
  final String id;
  final String shipmentNumber;
  final String senderName;
  final String consigneeName;
  final String date;
  final String weight;
  final String? notes;
  final DateTime createdAt;
  final String? imagePath;

  IncomingShipment({
    required this.id,
    required this.shipmentNumber,
    required this.senderName,
    required this.consigneeName,
    required this.date,
    required this.weight,
    this.notes,
    required this.createdAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipmentNumber': shipmentNumber,
      'senderName': senderName,
      'consigneeName': consigneeName,
      'date': date,
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory IncomingShipment.fromMap(Map<String, dynamic> map) {
    return IncomingShipment(
      id: map['id'] as String,
      shipmentNumber: map['shipmentNumber'] as String,
      senderName: map['senderName'] as String,
      consigneeName: map['consigneeName'] as String,
      date: map['date'] as String,
      weight: map['weight'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      imagePath: map['imagePath'] as String?,
    );
  }

  IncomingShipment copyWith({
    String? id,
    String? shipmentNumber,
    String? senderName,
    String? consigneeName,
    String? date,
    String? weight,
    String? notes,
    DateTime? createdAt,
    String? imagePath,
  }) {
    return IncomingShipment(
      id: id ?? this.id,
      shipmentNumber: shipmentNumber ?? this.shipmentNumber,
      senderName: senderName ?? this.senderName,
      consigneeName: consigneeName ?? this.consigneeName,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class IncomingShipmentService {
  static IncomingShipmentService? _instance;
  final StorageService _storage;

  static const String _shipmentsKey = 'incoming_shipments';

  IncomingShipmentService._(this._storage);

  static Future<IncomingShipmentService> getInstance() async {
    if (_instance != null) return _instance!;
    final storage = await StorageService.getInstance();
    _instance = IncomingShipmentService._(storage);
    return _instance!;
  }

  List<IncomingShipment> _getShipmentsList() {
    final jsonString = _storage.getString(_shipmentsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => IncomingShipment.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveShipmentsList(List<IncomingShipment> shipments) async {
    final jsonString = jsonEncode(shipments.map((s) => s.toMap()).toList());
    await _storage.setString(_shipmentsKey, jsonString);
  }

  Future<List<IncomingShipment>> getAllShipments() async {
    return _getShipmentsList();
  }

  Future<IncomingShipment?> getShipmentById(String id) async {
    final shipments = _getShipmentsList();
    try {
      return shipments.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<IncomingShipment?> getShipmentByNumber(String shipmentNumber) async {
    final shipments = _getShipmentsList();
    try {
      return shipments.firstWhere((s) => s.shipmentNumber == shipmentNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> addShipment(IncomingShipment shipment) async {
    final shipments = _getShipmentsList();
    shipments.add(shipment);
    await _saveShipmentsList(shipments);
  }

  Future<void> updateShipment(IncomingShipment shipment) async {
    final shipments = _getShipmentsList();
    final index = shipments.indexWhere((s) => s.id == shipment.id);
    if (index != -1) {
      shipments[index] = shipment;
      await _saveShipmentsList(shipments);
    }
  }

  Future<void> deleteShipment(String id) async {
    final shipments = _getShipmentsList();
    shipments.removeWhere((s) => s.id == id);
    await _saveShipmentsList(shipments);
  }

  Future<void> deleteAllShipments() async {
    await _storage.remove(_shipmentsKey);
  }

  int getShipmentCount() {
    return _getShipmentsList().length;
  }
}
