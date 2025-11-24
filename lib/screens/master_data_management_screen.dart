import 'package:flutter/material.dart';
import 'package:buddyapp/services/master_data_service.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_helpers.dart';

class MasterDataManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const MasterDataManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MasterDataManagementScreen> createState() =>
      _MasterDataManagementScreenState();
}

class _MasterDataManagementScreenState
    extends State<MasterDataManagementScreen> {
  late MasterDataService _masterDataService;
  bool _isLoading = true;

  final TextEditingController _workorderController = TextEditingController();
  final TextEditingController _componentController = TextEditingController();
  final TextEditingController _stageController = TextEditingController();

  List<String> _workorders = [];
  List<String> _components = [];
  List<String> _stages = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final service = await MasterDataService.getInstance();
    final workorders = await service.getWorkorders();
    final components = await service.getComponents();
    final stages = await service.getProcessStages();

    if (!mounted) return;

    setState(() {
      _masterDataService = service;
      _workorders = workorders;
      _components = components;
      _stages = stages;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _workorderController.dispose();
    _componentController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _addWorkorder() async {
    final value = _workorderController.text.trim();
    final error = AppHelpers.validateWorkOrder(value);
    if (error != null) {
      _showError(error);
      return;
    }
    await _masterDataService.addWorkorder(value);
    final updated = await _masterDataService.getWorkorders();
    if (!mounted) return;
    setState(() {
      _workorders = updated;
      _workorderController.clear();
    });
  }

  Future<void> _addComponent() async {
    final value = _componentController.text.trim();
    if (value.isEmpty) {
      _showError('Component/Equipment name is required');
      return;
    }
    await _masterDataService.addComponent(value);
    final updated = await _masterDataService.getComponents();
    if (!mounted) return;
    setState(() {
      _components = updated;
      _componentController.clear();
    });
  }

  Future<void> _addStage() async {
    final value = _stageController.text.trim();
    if (value.isEmpty) {
      _showError('Process stage name is required');
      return;
    }
    await _masterDataService.addProcessStage(value);
    final updated = await _masterDataService.getProcessStages();
    if (!mounted) return;
    setState(() {
      _stages = updated;
      _stageController.clear();
    });
  }

  Future<void> _removeWorkorder(String value) async {
    await _masterDataService.removeWorkorder(value);
    final updated = await _masterDataService.getWorkorders();
    if (!mounted) return;
    setState(() {
      _workorders = updated;
    });
  }

  Future<void> _removeComponent(String value) async {
    await _masterDataService.removeComponent(value);
    final updated = await _masterDataService.getComponents();
    if (!mounted) return;
    setState(() {
      _components = updated;
    });
  }

  Future<void> _removeStage(String value) async {
    await _masterDataService.removeProcessStage(value);
    final updated = await _masterDataService.getProcessStages();
    if (!mounted) return;
    setState(() {
      _stages = updated;
    });
  }

  Widget _buildListTab({
    required String title,
    required String hintText,
    required String emptyText,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> items,
    required void Function(String) onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onAdd,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final value = items[index];
                      return ListTile(
                        title: Text(value),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () => onDelete(value),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Master Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Work Orders'),
              Tab(text: 'Components/Equipment'),
              Tab(text: 'Process Stages'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildListTab(
                    title: 'Work Orders',
                    hintText: 'e.g. ABC-1234',
                    emptyText:
                        'No work orders yet. Add work orders to select them on the dashboard.',
                    controller: _workorderController,
                    onAdd: _addWorkorder,
                    items: _workorders,
                    onDelete: _removeWorkorder,
                  ),
                  _buildListTab(
                    title: 'Components / Parts / Equipment',
                    hintText: 'e.g. Turbine Blade',
                    emptyText:
                        'No components yet. Add components or equipment names here.',
                    controller: _componentController,
                    onAdd: _addComponent,
                    items: _components,
                    onDelete: _removeComponent,
                  ),
                  _buildListTab(
                    title: 'Process Stages',
                    hintText: 'e.g. Visual Inspection',
                    emptyText:
                        'No process stages yet. Add stages or use the defaults.',
                    controller: _stageController,
                    onAdd: _addStage,
                    items: _stages,
                    onDelete: _removeStage,
                  ),
                ],
              ),
      ),
    );
  }
}
