import 'package:care2wheeler_customer/Records/requestBody.dart';
import 'package:care2wheeler_customer/appData.dart';
import 'package:flutter/material.dart';
import 'package:care2wheeler_customer/bottom_nav_bar.dart';
import 'package:care2wheeler_customer/home/home.dart';
import 'package:care2wheeler_customer/vehicleDetails/addVehicleDetails.dart';
import 'package:care2wheeler_customer/vehicleDetails/selectBrand.dart';
import 'package:care2wheeler_customer/vehicleDetails/selectModel.dart';
import 'package:care2wheeler_customer/login.dart';
import 'package:care2wheeler_customer/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:care2wheeler_customer/notification_service.dart';

final storage = FlutterSecureStorage();

// Main theme color
final Color mainThemeColor = Color.fromARGB(255, 1, 225, 188);
final Color darkThemeColor = Color.fromARGB(255, 0, 165, 138);
final Color lightThemeColor = Color.fromARGB(255, 218, 255, 248);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care2Wheeler',
      theme: ThemeData(
        primaryColor: mainThemeColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: mainThemeColor,
          secondary: darkThemeColor,
          surface: Colors.white,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF4F4F4F),
          ),
        ),
      ),
      initialRoute: '/initial',
      routes: {
        '/': (context) => BottomNavBar(),
        '/home': (context) => HomeScreen(),
        '/addVehicleDetails': (context) =>
            VehicleDetailsScreen(vehicleData: AppData.vehicleData),
        '/selectBrand': (context) =>
            VehicleBrands(vehicleData: AppData.vehicleData),
        '/selectModel': (context) => VehicleModels(models: [], brand: ''),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegPage(),
        '/requestBody': (context) => RequestStatusPage(
              requestId: '',
            ),
        '/initial': (context) => MainPage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background design with circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: lightThemeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -150,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: lightThemeColor.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),

                    // Header with logo animation
                    Center(
                      child: LogoAnimation(),
                    ),

                    SizedBox(height: 36),

                    // Title and tagline
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Care2Wheeler',
                            style: TextStyle(
                              color: Color(0xFF2D3142),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: mainThemeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Your Ride, Our Care',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Welcome section
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Premium Bike Service',
                          style: TextStyle(
                            color: Color(0xFF2D3142),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: mainThemeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Connect your two-wheeler with professional garages for reliable service and maintenance.',
                      style: TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 36),

                    // App highlights section
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why Choose Us?',
                            style: TextStyle(
                              color: Color(0xFF2D3142),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          FeatureItem(
                            icon: Icons.access_time_rounded,
                            title: 'Real-time Updates',
                            description: 'Track your service status live',
                          ),
                          SizedBox(height: 16),
                          FeatureItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Digital Billing',
                            description: 'Transparent, paperless receipts',
                          ),
                          SizedBox(height: 16),
                          FeatureItem(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'QR Authentication',
                            description: 'Secure handover process',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 36),

                    // Promotional banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            mainThemeColor,
                            darkThemeColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'NEW USER',
                                    style: TextStyle(
                                      color: mainThemeColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '15% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'on your first service',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Login button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainThemeColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded),
                          SizedBox(width: 8),
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Register button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainThemeColor,
                        minimumSize: Size(double.infinity, 56),
                        side: BorderSide(color: mainThemeColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded),
                          SizedBox(width: 8),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoAnimation extends StatefulWidget {
  @override
  _LogoAnimationState createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: mainThemeColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: mainThemeColor.withOpacity(0.5),
            width: 6,
          ),
        ),
        padding: EdgeInsets.all(25),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: lightThemeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: mainThemeColor,
            size: 22,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Color(0xFF4F4F4F),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
