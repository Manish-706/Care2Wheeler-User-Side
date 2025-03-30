import 'package:flutter/material.dart';

class VehicleModels extends StatelessWidget {
  final List<Map<String, String>> models;
  final String brand;
  final Color mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  const VehicleModels({Key? key, required this.models, required this.brand})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$brand Models',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
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
            childAspectRatio: 0.85,
          ),
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context, model['name']),
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
                              model['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error_outline_rounded),
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      loadingProgress == null
                                          ? child
                                          : Center(
                                              child: CircularProgressIndicator(
                                                color: mainThemeColor,
                                                strokeWidth: 2,
                                              ),
                                            ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          model['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
