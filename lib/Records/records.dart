import 'package:care2wheeler_customer/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'requestBody.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  int selectedTab = 0;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<dynamic> ongoingRequests = [];
  List<dynamic> serviceHistory = [];
  bool isLoading = true;
  String errorMessage = '';
  final Color mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  @override
  void initState() {
    super.initState();
    _fetchServiceRequests();
  }

  Future<void> _fetchServiceRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/customer/requests'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> requests = json.decode(response.body);
        setState(() {
          ongoingRequests = requests
              .where((request) =>
                  request['status'] != 'completed' &&
                  request['status'] != 'rejected')
              .toList();
          serviceHistory = requests
              .where((request) =>
                  request['status'] == 'completed' ||
                  request['status'] == 'rejected')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch requests. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection error. Please check your internet.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Service Records",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ), // <-- Fixed missing closing parenthesis for `shape`
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildSegmentedControl(),
          ),
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : selectedTab == 0
                        ? _buildRequestList(requests: ongoingRequests)
                        : _buildRequestList(requests: serviceHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Ongoing", 0)),
          Expanded(child: _buildTabButton("History", 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
          color: isSelected ? mainThemeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => selectedTab = tabIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: mainThemeColor),
          const SizedBox(height: 20),
          Text("Fetching Records...",
              style: TextStyle(
                  color: mainThemeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 50, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(errorMessage,
              style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
                backgroundColor: mainThemeColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            onPressed: _fetchServiceRequests,
          )
        ],
      ),
    );
  }

  Widget _buildRequestList({required List<dynamic> requests}) {
    return requests.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    selectedTab == 0
                        ? Icons.autorenew_rounded
                        : Icons.history_rounded,
                    size: 60,
                    color: mainThemeColor.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                    selectedTab == 0
                        ? "No Ongoing Services"
                        : "No Service History",
                    style: TextStyle(
                        color: mainThemeColor.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildRequestCard(requests[index]));
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestStatusPage(requestId: request['_id']),
          ),
        ), // <-- Fixed missing closing parenthesis for `Navigator.push`
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mainThemeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedTab == 0
                      ? Icons.autorenew_rounded
                      : Icons.history_rounded,
                  color: mainThemeColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${request['vehicleBrand']} ${request['vehicleModel']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vehicle: ${request['vehicleNumber']}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (request['issues'] as List<dynamic>)
                          .take(3)
                          .map<Widget>(
                            (issue) => Chip(
                              label: Text(
                                issue.toString(),
                                style: TextStyle(
                                  color: mainThemeColor,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: mainThemeColor.withOpacity(0.1),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request['status'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            request['status'].toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(request['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return mainThemeColor;
    }
  }
}
