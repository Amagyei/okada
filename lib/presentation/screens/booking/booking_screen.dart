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
  int _currentStep = 0;
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
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: _buildCurrentStepContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepper() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(0, 'Location'),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Driver'),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Payment'),
          _buildStepConnector(2),
          _buildStepIndicator(3, 'Confirm'),
        ],
      ),
    );
  }
  
  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? ghanaGreen : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isCurrent 
                ? Border.all(color: ghanaGreen, width: 2) 
                : null,
          ),
          child: Center(
            child: isActive 
                ? Icon(Icons.check, color: ghanaWhite, size: 16)
                : Text(
                    (step + 1).toString(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCurrent ? ghanaGreen : textSecondary,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    
    return Container(
      width: 40,
      height: 2,
      color: isActive ? ghanaGreen : Colors.grey.shade300,
    );
  }
  
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildLocationStep();
      case 1:
        return _buildDriverStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildConfirmStep();
      default:
        return Container();
    }
  }
  
  Widget _buildLocationStep() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Map View',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          LocationInput(
            label: 'Pickup Location',
            controller: _pickupController,
            icon: Icons.my_location,
            onTap: () {},
          ),
          SizedBox(height: 16),
          LocationInput(
            label: 'Destination',
            controller: _destinationController,
            icon: Icons.location_on_outlined,
            onTap: () {},
          ),
          SizedBox(height: 24),
          Text(
            'Suggested Places',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          _buildSuggestedPlace('Home', 'East Legon, Accra'),
          _buildSuggestedPlace('Work', 'Airport City, Accra'),
          _buildSuggestedPlace('Makola Market', 'Central Accra'),
          Spacer(),
          GhanaButton(
            text: 'Find Riders',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              // Simulate network delay
              Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  _isLoading = false;
                  _currentStep = 1;
                });
              });
            },
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestedPlace(String name, String address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ghanaGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          name == 'Home' 
              ? Icons.home_outlined 
              : name == 'Work' 
                  ? Icons.work_outline 
                  : Icons.place_outlined,
          color: ghanaGreen,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        address,
        style: TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
      onTap: () {
        setState(() {
          _destinationController.text = address;
        });
      },
    );
  }
  
  Widget _buildDriverStep() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Riders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a rider for your trip',
            style: TextStyle(
              color: textSecondary,
            ),
          ),
          SizedBox(height: 16),
          DriverCard(
            name: 'Isaac Owusu',
            rating: 4.8,
            price: '22 GHS',
            eta: '5 min',
            isSelected: true,
            onTap: () {},
          ),
          SizedBox(height: 16),
          DriverCard(
            name: 'Kofi Mensah',
            rating: 4.5,
            price: '24 GHS',
            eta: '8 min',
            isSelected: false,
            onTap: () {},
          ),
          SizedBox(height: 16),
          DriverCard(
            name: 'Abena Pokuaa',
            rating: 4.7,
            price: '23 GHS',
            eta: '10 min',
            isSelected: false,
            onTap: () {},
          ),
          Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text('Back'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GhanaButton(
                  text: 'Continue',
                  onPressed: () {
                    setState(() {
                      _currentStep = 2;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentStep() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Payment Method',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select your preferred payment option',
            style: TextStyle(
              color: textSecondary,
            ),
          ),
          SizedBox(height: 24),
          PaymentMethodSelector(
            onPaymentMethodSelected: (method) {},
          ),
          Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text('Back'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GhanaButton(
                  text: 'Continue',
                  onPressed: () {
                    setState(() {
                      _currentStep = 3;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmStep() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review your trip details before confirming',
            style: TextStyle(
              color: textSecondary,
            ),
          ),
          SizedBox(height: 24),
          KenteBorderContainer(
            child: Column(
              children: [
                _buildTripDetail('From', _pickupController.text),
                SizedBox(height: 16),
                _buildTripDetail('To', _destinationController.text),
                SizedBox(height: 16),
                _buildTripDetail('Driver', 'Isaac Owusu (4.8 ★)'),
                SizedBox(height: 16),
                _buildTripDetail('Payment', 'Mobile Money'),
                SizedBox(height: 16),
                _buildTripDetail('Price', '22 GHS', isHighlighted: true),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text('Back'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GhanaButton(
                  text: 'Confirm Booking',
                  onPressed: () {
                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (context) => _buildSuccessDialog(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTripDetail(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlighted ? 18 : 16,
            color: isHighlighted ? ghanaGreen : textPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuccessDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ghanaGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: ghanaGreen,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Booking Successful!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your rider is on the way.',
              style: TextStyle(
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            GhanaButton(
              text: 'Track My Ride',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.trips);
              },
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
