import 'package:care2wheeler_customer/side_bar.dart';
import 'package:flutter/material.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services by Garage"),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 32, 5, 5)),
      ),
      drawer: const Sidebar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 33, 240),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 40,
              width: 300,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 33, 243, 128),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 44, 33, 243),
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ],
        ),
      ),
    );
  }
}
