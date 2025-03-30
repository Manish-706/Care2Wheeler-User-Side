import 'package:care2wheeler_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care2wheeler_customer/bottom_nav_bar.dart';

// Theme Colors
final Color mainThemeColor = Color.fromARGB(255, 1, 225, 188);
final Color darkThemeColor = Color.fromARGB(255, 0, 165, 138);
final Color lightThemeColor = Color.fromARGB(255, 218, 255, 248);
final Color textPrimary = Color(0xFF2D3142);
final Color textSecondary = Color(0xFF4F4F4F);

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await storage.read(key: 'fcm_token');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'fcmToken': token,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await storage.write(key: 'jwt_token', value: responseData['token']);
        await storage.write(
            key: 'customer_id', value: responseData['customerId']);
        await storage.write(key: 'username', value: _usernameController.text);
        await storage.write(key: 'phone', value: _phoneController.text);
        await storage.write(key: 'address', value: _addressController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: lightThemeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: lightThemeColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20),
                  Text('Create Account',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  SizedBox(height: 8),
                  Text('Join our service community',
                      style: TextStyle(fontSize: 16, color: textSecondary)),
                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v!.length < 3 ? 'Minimum 3 characters' : null,
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_iphone_rounded,
                          inputType: TextInputType.phone,
                          formatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) =>
                              v!.length != 10 ? 'Invalid phone number' : null,
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on_outlined,
                          validator: (v) =>
                              v!.isEmpty ? 'Required field' : null,
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainThemeColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add_alt_1_rounded),
                                    SizedBox(width: 12),
                                    Text('REGISTER NOW',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? inputType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: inputType,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          width: 52,
          padding: EdgeInsets.only(left: 16),
          child: Icon(icon, color: textSecondary.withOpacity(0.8)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
