import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:care2wheeler_customer/main.dart';
import 'package:care2wheeler_customer/side_bar.dart';

class RequestStatusPage extends StatefulWidget {
  final String requestId;
  final Color mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  const RequestStatusPage({Key? key, required this.requestId})
      : super(key: key);

  @override
  _RequestStatusPageState createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  Map<String, dynamic>? requestData;
  bool isLoading = true;
  String errorMessage = "";
  final _timelineAnimationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/customer/request/${widget.requestId}'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: "jwt_token")}'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          requestData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch details. Please try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred. Please try again.";
        isLoading = false;
      });
    }
  }

  Future<void> _updateRequestStatus() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/customer/scan-qr/${widget.requestId}'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: "jwt_token")}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'picked'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Request status updated to 'Picked'!"),
            backgroundColor: widget.mainThemeColor,
          ),
        );
        _fetchRequestDetails();
      } else {
        throw Exception("Failed to update request status");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanQRCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Scan QR Code"),
            backgroundColor: widget.mainThemeColor,
          ),
          body: MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? scannedData = barcodes.first.rawValue;
                if (scannedData != null) {
                  try {
                    final Map<String, dynamic> qrData = jsonDecode(scannedData);
                    final String? customerId =
                        await storage.read(key: 'customerId');
                    if (qrData['customerId'] == customerId) {
                      await _updateRequestStatus();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("QR Code doesn't match customer"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Invalid QR Code: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: widget.mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) return _buildLoadingState();
    if (errorMessage.isNotEmpty) return _buildErrorState();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildVehicleDetailsSection(),
              const SizedBox(height: 24),
              _buildServiceDetailsSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildTimelineSection(),
              if (requestData?["worker"] != null) _buildWorkerSection(),
              const SizedBox(height: 24),
              _buildTimeDetailsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Hero(
      tag: 'request-${widget.requestId}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.mainThemeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.mainThemeColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.two_wheeler, color: widget.mainThemeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Request #${widget.requestId}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(requestData?["status"]?.toUpperCase() ?? "",
                        style: TextStyle(
                            color: _getStatusColor(requestData?["status"]),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsSection() {
    return _buildSection(
      icon: Icons.two_wheeler,
      title: "Vehicle Details",
      children: [
        _buildDetailItem("Brand", requestData?["vehicleBrand"]),
        _buildDetailItem("Model", requestData?["vehicleModel"]),
        _buildDetailItem("Number", requestData?["vehicleNumber"]),
      ],
    );
  }

  Widget _buildServiceDetailsSection() {
    return _buildSection(
      icon: Icons.build_circle,
      title: "Service Details",
      children: [
        _buildChipList("Issues", requestData?["issues"]),
        _buildChipList("Services", requestData?["services"]),
        _buildDetailItem(
            "Description", requestData?["description"] ?? "No description"),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      icon: Icons.location_pin,
      title: "Location",
      children: [
        _buildDetailItem("Address", requestData?["address"]),
        _buildDetailItem("Coordinates",
            "${requestData?["location"]["latitude"]}, ${requestData?["location"]["longitude"]}"),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return _buildSection(
      icon: Icons.timeline,
      title: "Status Timeline",
      children: [
        AnimatedSize(
          duration: _timelineAnimationDuration,
          child: Column(children: _buildTimelineSteps()),
        ),
      ],
    );
  }

  List<Widget> _buildTimelineSteps() {
    final statusOrder = [
      "pending",
      "acknowledged",
      "picked",
      "inprogress",
      "completed",
      "rejected"
    ];
    final currentStatus = requestData?["status"] ?? "pending";
    final currentIndex = statusOrder.indexOf(currentStatus);

    return statusOrder.map((status) {
      final isActive = statusOrder.indexOf(status) <= currentIndex;
      final isCurrent = status == currentStatus;

      return _buildTimelineItem(
          status: status,
          isActive: isActive,
          isCurrent: isCurrent,
          isLast: status == statusOrder.last);
    }).toList();
  }

  Widget _buildTimelineItem(
      {required String status,
      required bool isActive,
      required bool isCurrent,
      required bool isLast}) {
    final statusLabels = {
      "pending": "Request Submitted",
      "acknowledged": "Garage Confirmed",
      "picked": "Vehicle Collected",
      "inprogress": "Service Ongoing",
      "completed": "Service Completed",
      "rejected": "Request Rejected"
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: isActive ? widget.mainThemeColor : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: widget.mainThemeColor, width: 3)
                        : null),
                child: isActive
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isActive ? widget.mainThemeColor : Colors.grey[200],
                )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedContainer(
              duration: _timelineAnimationDuration,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isCurrent
                      ? widget.mainThemeColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(color: widget.mainThemeColor)
                      : null),
              child: Text(
                statusLabels[status]!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? Colors.black87 : Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWorkerSection() {
    return _buildSection(
      icon: Icons.engineering,
      title: "Assigned Worker",
      children: [
        _buildDetailItem("Name", requestData?["worker"]["name"]),
        _buildDetailItem("Contact", requestData?["worker"]["phone"]),
      ],
    );
  }

  Widget _buildTimeDetailsSection() {
    return _buildSection(
      icon: Icons.access_time,
      title: "Timestamps",
      children: [
        _buildDetailItem(
            "Pickup Time", _formatDateTime(requestData?["pickupTime"])),
        _buildDetailItem(
            "Dropoff Time", _formatDateTime(requestData?["dropOffTime"])),
      ],
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return "-";
    final dateTime = DateTime.parse(isoString).toLocal();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: widget.mainThemeColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text("$label:",
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value?.toString() ?? "-",
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(String label, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label:",
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items
                .map((item) => Chip(
                      label: Text(item.toString(),
                          style: TextStyle(
                              color: widget.mainThemeColor, fontSize: 12)),
                      backgroundColor: widget.mainThemeColor.withOpacity(0.1),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return widget.mainThemeColor;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.mainThemeColor),
          const SizedBox(height: 20),
          Text("Loading Service Details...",
              style: TextStyle(
                  color: widget.mainThemeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500))
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
              size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.mainThemeColor,
                foregroundColor: Colors.white),
            onPressed: _fetchRequestDetails,
          )
        ],
      ),
    );
  }
}
