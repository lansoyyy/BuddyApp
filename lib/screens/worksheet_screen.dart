import 'package:flutter/material.dart';
import 'package:buddyapp/services/worksheet_service.dart';
import 'package:buddyapp/services/ocr_service.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class WorksheetScreen extends StatefulWidget {
  const WorksheetScreen({super.key});

  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen> {
  List<WorksheetData> _worksheets = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();
  String _filterStatus = 'All';

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'On Hold'
  ];
  final List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    final service = await WorksheetService.getInstance();
    final worksheets = await service.getAllWorksheets();
    setState(() {
      _worksheets = worksheets;
      _isLoading = false;
    });
  }

  List<WorksheetData> get _filteredWorksheets {
    if (_filterStatus == 'All') return _worksheets;
    return _worksheets.where((w) => w.status == _filterStatus).toList();
  }

  Future<void> _scanWorksheet() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ocrService = OcrService.instance;
      final worksheetData =
          await ocrService.processWorksheetImage(File(pickedFile.path));

      if (worksheetData != null) {
        _showAddWorksheetDialog(
          ocrData: worksheetData,
          imagePath: pickedFile.path,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to extract worksheet data')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning worksheet: $e')),
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

  void _showAddWorksheetDialog({
    WorksheetOCRData? ocrData,
    WorksheetData? existingWorksheet,
    String? imagePath,
  }) {
    final worksheetController = TextEditingController(
      text:
          ocrData?.worksheetNumber ?? existingWorksheet?.worksheetNumber ?? '',
    );
    final jobController = TextEditingController(
      text: ocrData?.jobName ?? existingWorksheet?.jobName ?? '',
    );
    final componentController = TextEditingController(
      text: ocrData?.component ?? existingWorksheet?.component ?? '',
    );
    final quantityController = TextEditingController(
      text: ocrData?.quantity ?? existingWorksheet?.quantity ?? '',
    );
    final descriptionController = TextEditingController(
      text: ocrData?.description ?? existingWorksheet?.description ?? '',
    );
    final statusController = TextEditingController(
      text: ocrData?.status ?? existingWorksheet?.status ?? 'Pending',
    );
    final priorityController = TextEditingController(
      text: ocrData?.priority ?? existingWorksheet?.priority ?? 'Medium',
    );
    final assignedToController = TextEditingController(
      text: ocrData?.assignedTo ?? existingWorksheet?.assignedTo ?? '',
    );
    final dueDateController = TextEditingController(
      text: ocrData?.dueDate ?? existingWorksheet?.dueDate ?? '',
    );
    final notesController = TextEditingController(
      text: existingWorksheet?.notes ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              existingWorksheet == null ? 'Add Worksheet' : 'Edit Worksheet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: worksheetController,
                  decoration: const InputDecoration(
                    labelText: 'Worksheet Number *',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jobController,
                  decoration: const InputDecoration(
                    labelText: 'Job Name *',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: componentController,
                  decoration: const InputDecoration(
                    labelText: 'Component',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: statusController.text.isEmpty
                      ? 'Pending'
                      : statusController.text,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: ['Pending', 'In Progress', 'Completed', 'On Hold']
                      .map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      statusController.text = value;
                      setDialogState(() {});
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priorityController.text.isEmpty
                      ? 'Medium'
                      : priorityController.text,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.priority_high),
                  ),
                  items: _priorityOptions.map((priority) {
                    return DropdownMenuItem(
                        value: priority, child: Text(priority));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      priorityController.text = value;
                      setDialogState(() {});
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: assignedToController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned To',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: Icon(Icons.event),
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
                final worksheetNumber = worksheetController.text.trim();
                final jobName = jobController.text.trim();

                if (worksheetNumber.isEmpty || jobName.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in required fields')),
                    );
                  }
                  return;
                }

                final service = await WorksheetService.getInstance();

                if (existingWorksheet != null) {
                  // Update existing worksheet
                  final updatedWorksheet = existingWorksheet.copyWith(
                    worksheetNumber: worksheetNumber,
                    jobName: jobName,
                    component: componentController.text.trim(),
                    quantity: quantityController.text.trim(),
                    description: descriptionController.text.trim(),
                    status: statusController.text.trim(),
                    priority: priorityController.text.trim(),
                    assignedTo: assignedToController.text.trim(),
                    dueDate: dueDateController.text.trim(),
                    notes: notesController.text.trim(),
                    imagePath: imagePath ?? existingWorksheet.imagePath,
                  );
                  await service.updateWorksheet(updatedWorksheet);
                } else {
                  // Add new worksheet
                  final newWorksheet = WorksheetData(
                    id: _uuid.v4(),
                    worksheetNumber: worksheetNumber,
                    jobName: jobName,
                    component: componentController.text.trim(),
                    quantity: quantityController.text.trim(),
                    description: descriptionController.text.trim(),
                    status: statusController.text.trim(),
                    priority: priorityController.text.trim(),
                    assignedTo: assignedToController.text.trim(),
                    dueDate: dueDateController.text.trim(),
                    notes: notesController.text.trim(),
                    createdAt: DateTime.now(),
                    imagePath: imagePath,
                  );
                  await service.addWorksheet(newWorksheet);
                }

                await _loadWorksheets();
                if (mounted) Navigator.pop(context);
              },
              child: Text(existingWorksheet == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWorksheet(WorksheetData worksheet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Worksheet'),
        content: Text(
            'Are you sure you want to delete worksheet ${worksheet.worksheetNumber}?'),
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
      final service = await WorksheetService.getInstance();
      await service.deleteWorksheet(worksheet.id);
      await _loadWorksheets();
    }
  }

  void _showWorksheetDetails(WorksheetData worksheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Worksheet #${worksheet.worksheetNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Job Name', worksheet.jobName),
              _detailRow('Component', worksheet.component),
              _detailRow('Quantity', worksheet.quantity),
              _detailRow('Description', worksheet.description),
              _detailRow('Status', worksheet.status),
              _detailRow('Priority', worksheet.priority),
              _detailRow('Assigned To', worksheet.assignedTo),
              _detailRow('Due Date', worksheet.dueDate),
              if (worksheet.notes.isNotEmpty)
                _detailRow('Notes', worksheet.notes),
              _detailRow('Created', _formatDate(worksheet.createdAt)),
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
              _showAddWorksheetDialog(existingWorksheet: worksheet);
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'on hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Worksheets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanWorksheet,
            tooltip: 'Scan Worksheet',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorksheetDialog(),
            tooltip: 'Add Manually',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text('Filter: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusOptions.map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filterStatus = status;
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Worksheet List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWorksheets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No worksheets yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _scanWorksheet,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Scan Worksheet'),
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
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorksheets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredWorksheets.length,
                          itemBuilder: (context, index) {
                            final worksheet = _filteredWorksheets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showWorksheetDetails(worksheet),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              worksheet.worksheetNumber,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showAddWorksheetDialog(
                                                  existingWorksheet: worksheet,
                                                );
                                              } else if (value == 'delete') {
                                                _deleteWorksheet(worksheet);
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
                                                        size: 18,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.red)),
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
                                          const Icon(Icons.work,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              worksheet.jobName,
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (worksheet.component.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.category,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                worksheet.component,
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      worksheet.status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getStatusColor(
                                                    worksheet.status),
                                              ),
                                            ),
                                            child: Text(
                                              worksheet.status,
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                    worksheet.status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(
                                                      worksheet.priority)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getPriorityColor(
                                                    worksheet.priority),
                                              ),
                                            ),
                                            child: Text(
                                              worksheet.priority,
                                              style: TextStyle(
                                                color: _getPriorityColor(
                                                    worksheet.priority),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
