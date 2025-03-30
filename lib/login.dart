import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care2wheeler_customer/bottom_nav_bar.dart';

// Theme Constants
const Color kPrimaryColor = Color.fromARGB(255, 1, 225, 188);
const Color kDarkPrimary = Color.fromARGB(255, 0, 165, 138);
const Color kLightPrimary = Color.fromARGB(255, 218, 255, 248);
const Color kTextPrimary = Color(0xFF2D3142);
const Color kTextSecondary = Color(0xFF6C757D);

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await secureStorage.read(key: 'fcm_token');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': _phoneController.text,
          'fcmToken': token,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _storeUserData(responseData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      } else {
        // Show error message for non-200 responses
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Login failed';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Handle network or unexpected errors
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    await secureStorage.write(key: 'jwt_token', value: data['token']);
    await secureStorage.write(key: 'customer_id', value: data['customerId']);
    await secureStorage.write(key: 'username', value: data['username']);
    await secureStorage.write(key: 'address', value: data['address']);
    await secureStorage.write(key: 'phone', value: _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: kLightPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: kLightPrimary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: kTextPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Sign in to continue your journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextSecondary,
                      )),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Container(
                              width: 52,
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(Icons.phone_iphone_rounded,
                                  color: kTextSecondary.withOpacity(0.8)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ), // <-- Added missing closing parenthesis
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Invalid 10-digit number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.login_rounded),
                                    const SizedBox(width: 12),
                                    Text('SIGN IN',
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
