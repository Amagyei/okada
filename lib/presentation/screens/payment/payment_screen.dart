import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedProvider = 'MTN Mobile Money';
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Payment Method',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Select your preferred mobile money option',
              style: TextStyle(color: textSecondary),
            ),
            SizedBox(height: 24),
            
            // Mobile Money Card (Primary Option)
            _buildPaymentMethodCard(
              title: 'Mobile Money',
              subtitle: 'Fast and convenient mobile payments',
              icon: Icons.phone_android,
              isSelected: true,
              onTap: () {},
            ),
            
            SizedBox(height: 24),
            Text(
              'Select Mobile Money Provider',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            
            // Mobile Money Provider Options
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildProviderOption(
                    'MTN Mobile Money',
                    'assets/images/mtn_momo.png',
                    isSelected: _selectedProvider == 'MTN Mobile Money',
                    onTap: () {
                      setState(() {
                        _selectedProvider = 'MTN Mobile Money';
                      });
                    },
                  ),
                  SizedBox(width: 12),
                  _buildProviderOption(
                    'Telecel Cash',
                    'assets/images/telecel_cash.png',
                    isSelected: _selectedProvider == 'Telecel Cash',
                    onTap: () {
                      setState(() {
                        _selectedProvider = 'Telecel Cash';
                      });
                    },
                  ),
                  SizedBox(width: 12),
                  _buildProviderOption(
                    'AirtelTigo Money',
                    'assets/images/airteltigo_money.png',
                    isSelected: _selectedProvider == 'AirtelTigo Money',
                    onTap: () {
                      setState(() {
                        _selectedProvider = 'AirtelTigo Money';
                      });
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            GhanaTextField(
              label: 'Mobile Money Number',
              hint: '024 XXX XXXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),
            
            SizedBox(height: 24),
            Text(
              'Other Payment Options',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            
            // Cash Payment Option
            _buildPaymentMethodCard(
              title: 'Cash',
              subtitle: 'Pay directly to driver',
              icon: Icons.payments_outlined,
              isSelected: false,
              onTap: () {
                // Show dialog to confirm switch to cash payment
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Switch to Cash?'),
                    content: Text('Are you sure you want to pay with cash instead of mobile money?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Implement cash payment logic
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: 'Card Payment',
              subtitle: 'Credit or Debit card',
              icon: Icons.credit_card,
              isSelected: false,
              onTap: () {
                // Show dialog to confirm switch to card payment
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Switch to Card Payment?'),
                    content: Text('Card payment will be available soon.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            SizedBox(height: 32),
            GhanaButton(
              text: 'Confirm Payment Method',
              isLoading: _isLoading,
              onPressed: () {
                if (_phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your mobile money number')),
                  );
                  return;
                }
                
                setState(() {
                  _isLoading = true;
                });
                
                // Simulate API call
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  Navigator.pop(context, {
                    'provider': _selectedProvider,
                    'phoneNumber': _phoneController.text,
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ghanaGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? ghanaGreen.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? ghanaGreen.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? ghanaGreen : Colors.grey.shade600,
                size: 24,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? ghanaGreen : textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ghanaGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderOption(
    String name,
    String imagePath, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ghanaGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? ghanaGreen.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Using Icon as placeholder since we don't have actual images
            Icon(
              Icons.account_balance_wallet,
              size: 36,
              color: isSelected ? ghanaGreen : Colors.grey.shade600,
            ),
            SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? ghanaGreen : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}