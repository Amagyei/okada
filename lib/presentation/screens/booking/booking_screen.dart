import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';
import '../../../routes.dart';
import 'widgets/location_input.dart';
import 'widgets/driver_card.dart';
import 'widgets/payment_method_selector.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Set default values for demo
    _pickupController.text = 'Current Location';
  }
  
  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Full-bleed map
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Text('Map View', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          // Sliding bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(child: Container(width: 40, height: 4, margin: EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      // Search fields
                      LocationInput(
                        label: 'Pickup',
                        controller: _pickupController,
                        icon: Icons.my_location,
                        onTap: () {},
                      ),
                      SizedBox(height: 12),
                      LocationInput(
                        label: 'Destination',
                        controller: _destinationController,
                        icon: Icons.location_on_outlined,
                        onTap: () {},
                      ),
                      SizedBox(height: 16),
                      Text('Suggested Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPlaceChip('Home', 'East Legon, Accra'),
                          _buildPlaceChip('Work', 'Airport City, Accra'),
                          _buildPlaceChip('Market', 'Makola Market'),
                        ],
                      ),
                      SizedBox(height: 24),
                      GhanaButton(
                        text: 'Find Riders',
                        isLoading: _isLoading,
                        onPressed: () {
                          setState(() => _isLoading = true);
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              _isLoading = false;
                              // navigate or show drivers
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceChip(String label, String address) {
    return ActionChip(
      label: Text(label),
      backgroundColor: ghanaGreen.withOpacity(0.1),
      onPressed: () => setState(() {
        _destinationController.text = address;
      }),
    );
  }
}
