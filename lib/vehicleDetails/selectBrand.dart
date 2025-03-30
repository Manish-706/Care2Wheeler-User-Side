import 'package:flutter/material.dart';

class VehicleBrands extends StatelessWidget {
  final Map<String, dynamic> vehicleData;
  final Color mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  const VehicleBrands({Key? key, required this.vehicleData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brands = vehicleData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Brand',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final brand = brands[index];
            final brandData = vehicleData[brand];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context, brand),
                  splashColor: mainThemeColor.withOpacity(0.2),
                  highlightColor: mainThemeColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              brandData['image'],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error_outline_rounded),
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      loadingProgress == null
                                          ? child
                                          : Center(
                                              child: CircularProgressIndicator(
                                                  color: mainThemeColor)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          brand,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
