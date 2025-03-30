import 'package:flutter/material.dart';
import 'package:care2wheeler_customer/side_bar.dart';

class IssuesAndServices extends StatefulWidget {
  const IssuesAndServices({Key? key}) : super(key: key);

  @override
  _IssuesAndServicesState createState() => _IssuesAndServicesState();
}

class _IssuesAndServicesState extends State<IssuesAndServices>
    with SingleTickerProviderStateMixin {
  final Color _mainThemeColor = const Color.fromARGB(255, 1, 225, 188);
  final List<String> _issues = [
    'Flat Tire',
    'Engine Noise',
    'Brake Failure',
    'Battery Issue',
    'Oil Leak',
    'Overheating',
    'Lighting Issue',
    'Steering Problem',
  ];

  final List<String> _services = [
    'Car Washing',
    'Engine Oil Change',
    'New Indicators',
    'Wheel Alignment',
    'Air Filter Replacement',
    'AC Service',
  ];

  List<String> _selectedIssues = [];
  List<String> _selectedServices = [];
  final TextEditingController _descriptionController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Diagnostics',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        bottom: _buildSegmentedTabs(),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSelectionGrid(
                    _issues, _selectedIssues, Icons.warning_rounded),
                _buildSelectionGrid(
                    _services, _selectedServices, Icons.build_rounded),
              ],
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSegmentedTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _mainThemeColor,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade700,
          tabs: const [
            Tab(icon: Icon(Icons.warning_amber_rounded), text: "Issues"),
            Tab(icon: Icon(Icons.construction_rounded), text: "Services"),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid(
      List<String> items, List<String> selectedItems, IconData icon) {
    return items.isEmpty
        ? _buildEmptyState(icon)
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildSelectionCard(
              items[index],
              selectedItems.contains(items[index]),
              icon,
              onTap: () => _handleSelection(items[index], selectedItems),
            ),
          );
  }

  Widget _buildSelectionCard(String title, bool isSelected, IconData icon,
      {VoidCallback? onTap}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? _mainThemeColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _mainThemeColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: _mainThemeColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? _mainThemeColor : Colors.grey.shade400,
                  size: 24,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: _mainThemeColor),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? _mainThemeColor : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Additional Notes',
              hintText: 'Describe specific details or special requests...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _mainThemeColor),
              ),
              suffixIcon:
                  Icon(Icons.edit_note_rounded, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Confirm Selection',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mainThemeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: _submitSelection,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: _mainThemeColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No Items Available',
              style: TextStyle(
                color: _mainThemeColor.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  void _handleSelection(String item, List<String> selectedItems) {
    setState(() {
      selectedItems.contains(item)
          ? selectedItems.remove(item)
          : selectedItems.add(item);
    });
  }

  void _submitSelection() {
    Navigator.pop(context, {
      'issues': _selectedIssues,
      'services': _selectedServices,
      'description': _descriptionController.text,
    });
  }
}
