import 'package:flutter/material.dart';
import 'package:buddyapp/services/incoming_shipment_service.dart';
import 'package:buddyapp/services/ocr_service.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class IncomingShipmentScreen extends StatefulWidget {
  final bool embedded;

  const IncomingShipmentScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<IncomingShipmentScreen> createState() => _IncomingShipmentScreenState();
}

class _IncomingShipmentScreenState extends State<IncomingShipmentScreen> {
  List<IncomingShipment> _shipments = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    final service = await IncomingShipmentService.getInstance();
    final shipments = await service.getAllShipments();
    setState(() {
      _shipments = shipments;
      _isLoading = false;
    });
  }

  Future<void> _scanWaybill() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ocrService = OcrService.instance;
      final waybillData =
          await ocrService.processWaybillImage(File(pickedFile.path));

      if (waybillData != null) {
        _showAddShipmentDialog(
          waybillData: waybillData,
          imagePath: pickedFile.path,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to extract waybill data')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning waybill: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddShipmentDialog({
    WaybillData? waybillData,
    IncomingShipment? existingShipment,
    String? imagePath,
  }) {
    final shipmentController = TextEditingController(
      text:
          waybillData?.shipmentNumber ?? existingShipment?.shipmentNumber ?? '',
    );
    final senderController = TextEditingController(
      text: waybillData?.senderName ?? existingShipment?.senderName ?? '',
    );
    final consigneeController = TextEditingController(
      text: waybillData?.consigneeName ?? existingShipment?.consigneeName ?? '',
    );
    final dateController = TextEditingController(
      text: waybillData?.date ?? existingShipment?.date ?? '',
    );
    final weightController = TextEditingController(
      text: waybillData?.weight ?? existingShipment?.weight ?? '',
    );
    final notesController = TextEditingController(
      text: existingShipment?.notes ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(existingShipment == null
            ? 'Add Incoming Shipment'
            : 'Edit Shipment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shipmentController,
                decoration: const InputDecoration(
                  labelText: 'Shipment Number *',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senderController,
                decoration: const InputDecoration(
                  labelText: 'Sender Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: consigneeController,
                decoration: const InputDecoration(
                  labelText: 'Consignee Name',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final shipmentNumber = shipmentController.text.trim();
              final senderName = senderController.text.trim();

              if (shipmentNumber.isEmpty || senderName.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in required fields')),
                  );
                }
                return;
              }

              final service = await IncomingShipmentService.getInstance();

              if (existingShipment != null) {
                // Update existing shipment
                final updatedShipment = existingShipment.copyWith(
                  shipmentNumber: shipmentNumber,
                  senderName: senderName,
                  consigneeName: consigneeController.text.trim(),
                  date: dateController.text.trim(),
                  weight: weightController.text.trim(),
                  notes: notesController.text.trim(),
                  imagePath: imagePath ?? existingShipment.imagePath,
                );
                await service.updateShipment(updatedShipment);
              } else {
                // Add new shipment
                final newShipment = IncomingShipment(
                  id: _uuid.v4(),
                  shipmentNumber: shipmentNumber,
                  senderName: senderName,
                  consigneeName: consigneeController.text.trim(),
                  date: dateController.text.trim(),
                  weight: weightController.text.trim(),
                  notes: notesController.text.trim(),
                  createdAt: DateTime.now(),
                  imagePath: imagePath,
                );
                await service.addShipment(newShipment);
              }

              await _loadShipments();
              if (mounted) Navigator.pop(context);
            },
            child: Text(existingShipment == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShipment(IncomingShipment shipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shipment'),
        content: Text(
            'Are you sure you want to delete shipment ${shipment.shipmentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = await IncomingShipmentService.getInstance();
      await service.deleteShipment(shipment.id);
      await _loadShipments();
    }
  }

  void _showShipmentDetails(IncomingShipment shipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shipment #${shipment.shipmentNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Sender', shipment.senderName),
              _detailRow('Consignee', shipment.consigneeName),
              _detailRow('Date', shipment.date),
              _detailRow('Weight', shipment.weight),
              if (shipment.notes != null && shipment.notes!.isNotEmpty)
                _detailRow('Notes', shipment.notes!),
              _detailRow('Created', _formatDate(shipment.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddShipmentDialog(existingShipment: shipment);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildBody();

    if (widget.embedded) {
      return Column(
        children: [
          AppBar(
            title: const Text('Incoming Shipments'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _scanWaybill,
                tooltip: 'Scan Waybill',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddShipmentDialog(),
                tooltip: 'Add Manually',
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: content,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Incoming Shipments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanWaybill,
            tooltip: 'Scan Waybill',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddShipmentDialog(),
            tooltip: 'Add Manually',
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_shipments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No incoming shipments yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _scanWaybill,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Waybill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadShipments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _shipments.length,
        itemBuilder: (context, index) {
          final shipment = _shipments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showShipmentDetails(shipment),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shipment.shipmentNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddShipmentDialog(
                                existingShipment: shipment,
                              );
                            } else if (value == 'delete') {
                              _deleteShipment(shipment);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shipment.senderName,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (shipment.consigneeName.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.business,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shipment.consigneeName,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (shipment.date.isNotEmpty) ...[
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            shipment.date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (shipment.weight.isNotEmpty) ...[
                          const Icon(Icons.scale, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            shipment.weight,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
