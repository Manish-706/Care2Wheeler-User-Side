import 'package:flutter/material.dart';
import 'package:care2wheeler_customer/vehicleDetails/selectBrand.dart';
import 'package:care2wheeler_customer/vehicleDetails/selectModel.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  final Color mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  const VehicleDetailsScreen({Key? key, required this.vehicleData})
      : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  String? selectedBrand;
  String? selectedModel;
  String? vehicleNumber;

  @override
  Widget build(BuildContext context) {
    final brandData =
        selectedBrand != null ? widget.vehicleData[selectedBrand] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: widget.mainThemeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Brand Display
            if (selectedBrand != null)
              _buildSelectionCard(
                image: brandData!['image'],
                title: 'Selected Brand',
                value: selectedBrand!,
              ),

            // Selected Model Display
            if (selectedModel != null)
              _buildSelectionCard(
                image: brandData!['models'].firstWhere(
                    (model) => model['name'] == selectedModel)['image'],
                title: 'Selected Model',
                value: selectedModel!,
              ),

            const SizedBox(height: 24),

            // Vehicle Number Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                prefixIcon: const Icon(Icons.confirmation_number_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'DL01AB1234',
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) => setState(() => vehicleNumber = value),
            ),

            const SizedBox(height: 24),

            // Brand Selection Button
            _buildSelectionButton(
              icon: Icons.branding_watermark_rounded,
              label: 'Choose Brand',
              onPressed: () async => await _handleBrandSelection(context),
            ),

            const SizedBox(height: 16),

            // Model Selection Button
            _buildSelectionButton(
              icon: Icons.model_training_rounded,
              label: 'Choose Model',
              onPressed: selectedBrand == null
                  ? null
                  : () async => await _handleModelSelection(context),
              isDisabled: selectedBrand == null,
            ),

            const Spacer(),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.mainThemeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed:
                    _validateInputs() ? () => _submitDetails(context) : null,
                child: const Text('SAVE VEHICLE DETAILS',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
      {required String image, required String title, required String value}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image.isNotEmpty ? image : 'https://via.placeholder.com/60',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDisabled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon:
            Icon(icon, color: isDisabled ? Colors.grey : widget.mainThemeColor),
        label: Text(label,
            style: TextStyle(
                color: isDisabled ? Colors.grey : widget.mainThemeColor,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade200 : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color:
                      isDisabled ? Colors.grey.shade300 : widget.mainThemeColor,
                  width: 1.5)),
          elevation: 0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  bool _validateInputs() {
    return selectedBrand != null &&
        selectedModel != null &&
        vehicleNumber != null &&
        vehicleNumber!.isNotEmpty;
  }

  Future<void> _handleBrandSelection(BuildContext context) async {
    final brand = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleBrands(vehicleData: widget.vehicleData),
      ),
    );
    if (brand != null) {
      setState(() {
        selectedBrand = brand;
        selectedModel = null;
      });
    }
  }

  Future<void> _handleModelSelection(BuildContext context) async {
    final model = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleModels(
          models: widget.vehicleData[selectedBrand!]['models'],
          brand: selectedBrand!,
        ),
      ),
    );
    if (model != null) setState(() => selectedModel = model);
  }

  void _submitDetails(BuildContext context) {
    Navigator.pop(context, {
      'brand': selectedBrand!,
      'model': selectedModel!,
      'vehicleNumber': vehicleNumber!,
    });
  }
}
