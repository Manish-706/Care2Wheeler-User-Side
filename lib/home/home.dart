import 'package:care2wheeler_customer/Records/requestBody.dart';
import 'package:care2wheeler_customer/home/issueCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:care2wheeler_customer/vehicleDetails/addVehicleDetails.dart';
import 'package:care2wheeler_customer/appData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care2wheeler_customer/side_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Color _kPrimaryColor = const Color.fromARGB(255, 1, 225, 188);
  final Color _kTextSecondary = const Color(0xFF6C757D);

  LatLng _selectedLocation = const LatLng(28.7041, 77.1025);
  String? selectedBrand;
  String? selectedModel;
  String? vehicleNumber;
  List<String>? selectedIssues;
  List<String>? selectedServices;
  String? issueDescription;
  bool _isMapExpanded = false;
  String _selectedAddress = '';
  Map<String, dynamic>? _selectedGarage;
  List<Map<String, dynamic>> garages = [];

  @override
  void initState() {
    super.initState();
    _fetchGarages();
  }

  Future<void> _fetchGarages() async {
    try {
      final address = await _secureStorage.read(key: 'address');
      final token = await _secureStorage.read(key: 'jwt_token');

      if (address == null || token == null) return;

      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/customer/garagedata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => garages = List<Map<String, dynamic>>.from(
            json.decode(response.body)['garages']));
      }
    } catch (e) {
      print('Error fetching garages: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() => _selectedAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].postalCode}');
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  void _expandMap() => setState(() => _isMapExpanded = true);
  void _shrinkMap() => setState(() => _isMapExpanded = false);

  Future<void> _getCurrentLocation() async {
    const LatLng mockLocation = LatLng(28.7041, 77.1025);
    setState(() {
      _selectedLocation = mockLocation;
      _selectedAddress = 'Current Location (Mock)';
    });
    _getAddressFromLatLng(mockLocation);
  }

  void _showGarageDialog(BuildContext context, Map<String, dynamic> garage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: _kPrimaryColor.withOpacity(0.1),
                child:
                    Icon(Icons.garage_rounded, size: 40, color: _kPrimaryColor),
              ),
              const SizedBox(height: 20),
              Text(garage['garageName'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildInfoRow(Icons.person, 'Owner: ${garage['ownerName']}'),
              _buildInfoRow(Icons.phone, 'Phone: ${garage['phone']}'),
              _buildInfoRow(
                  Icons.location_on, 'Address: ${garage['garageAddress']}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimaryColor),
                    child: const Text(
                      'Select Garage',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() => _selectedGarage = garage);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected ${garage['garageName']}'),
                          backgroundColor: _kPrimaryColor,
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: _kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Confirm Service Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildConfirmationDetail(
                  'Vehicle:', '$selectedBrand $selectedModel ($vehicleNumber)'),
              _buildConfirmationDetail(
                  'Issues:', selectedIssues?.join(', ') ?? ''),
              _buildConfirmationDetail(
                  'Services:', selectedServices?.join(', ') ?? ''),
              _buildConfirmationDetail('Description:', issueDescription ?? ''),
              _buildConfirmationDetail('Location:', _selectedAddress),
              if (_selectedGarage != null) ...[
                _buildConfirmationDetail(
                    'Garage:', _selectedGarage!['garageName']),
                _buildConfirmationDetail(
                    'Garage Address:', _selectedGarage!['garageAddress']),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimaryColor),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:3000/customer/request'),
                          headers: {
                            'Authorization':
                                'Bearer ${await _secureStorage.read(key: "jwt_token")}',
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({
                            'customerId':
                                await _secureStorage.read(key: 'customer_id'),
                            'garageId': _selectedGarage!['_id'],
                            "vehicleBrand": selectedBrand,
                            "vehicleModel": selectedModel,
                            "vehicleNumber": vehicleNumber,
                            'issues': selectedIssues,
                            'services': selectedServices,
                            'location': {
                              'latitude': _selectedLocation.latitude,
                              'longitude': _selectedLocation.longitude,
                            },
                            'address': _selectedAddress,
                            'description': issueDescription
                          }),
                        );

                        if (response.statusCode == 201) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestStatusPage(
                                requestId:
                                    jsonDecode(response.body)['requestId'],
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to create request')),
                        );
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
                text: '$title ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _kPrimaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Home Page',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _selectedLocation, zoom: 14),
                  onTap: (location) {
                    setState(() => _selectedLocation = location);
                    _getAddressFromLatLng(location);
                    _expandMap();
                  },
                  markers: {
                    Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: _selectedLocation),
                    ...garages.map((garage) => Marker(
                          markerId: MarkerId(garage['_id']),
                          position: LatLng(garage['location']['latitude'],
                              garage['location']['longitude']),
                          onTap: () => _showGarageDialog(context, garage),
                        )),
                  },
                ),
                if (_isMapExpanded)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(30),
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Selected Location',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location,
                                    color: _kPrimaryColor),
                                onPressed: _getCurrentLocation,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            controller:
                                TextEditingController(text: _selectedAddress),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 16,
                                    spreadRadius: 2)
                              ]),
                          child: ElevatedButton.icon(
                            icon:
                                const Icon(Icons.check_circle_outline_rounded),
                            label: const Text('Confirm Location'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16)),
                            onPressed: _shrinkMap,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!_isMapExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLocationCard(),
                  if (_selectedGarage != null) _buildGarageCard(),
                  _buildVehicleCard(),
                  _buildServicesCard(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continue to Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (selectedBrand != null &&
                          selectedModel != null &&
                          selectedIssues != null &&
                          selectedIssues!.isNotEmpty &&
                          selectedServices != null &&
                          selectedServices!.isNotEmpty &&
                          _selectedAddress.isNotEmpty) {
                        _showConfirmationDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.location_on, color: _kPrimaryColor),
        title: const Text('Pick-up Location',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            _selectedAddress.isNotEmpty
                ? _selectedAddress
                : 'No location selected',
            style: TextStyle(color: _kTextSecondary)),
      ),
    );
  }

  Widget _buildGarageCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.garage_rounded, color: _kPrimaryColor),
        title: Text(_selectedGarage!['garageName'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_selectedGarage!['garageAddress'],
            style: TextStyle(color: _kTextSecondary)),
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.two_wheeler, color: _kPrimaryColor),
        title:
            Text('Your Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            selectedBrand != null && selectedModel != null
                ? '$selectedBrand $selectedModel\n$vehicleNumber'
                : 'No vehicle selected',
            style: TextStyle(color: _kTextSecondary)),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: _kPrimaryColor),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VehicleDetailsScreen(vehicleData: AppData.vehicleData)),
            );
            if (result != null) {
              setState(() {
                selectedBrand = result['brand'];
                selectedModel = result['model'];
                vehicleNumber = result['vehicleNumber'];
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.build_circle, color: _kPrimaryColor),
        title: const Text('Services & Issues',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedIssues != null && selectedIssues!.isNotEmpty)
              Text('Issues: ${selectedIssues!.join(', ')}',
                  style: TextStyle(color: _kTextSecondary)),
            if (selectedServices != null && selectedServices!.isNotEmpty)
              Text('Services: ${selectedServices!.join(', ')}',
                  style: TextStyle(color: _kTextSecondary)),
            if (issueDescription != null && issueDescription!.isNotEmpty)
              Text('Description: $issueDescription',
                  style: TextStyle(color: _kTextSecondary)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: _kPrimaryColor),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IssuesAndServices()),
            );
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                selectedIssues = result['issues'];
                selectedServices = result['services'];
                issueDescription = result['description'];
              });
            }
          },
        ),
      ),
    );
  }
}
