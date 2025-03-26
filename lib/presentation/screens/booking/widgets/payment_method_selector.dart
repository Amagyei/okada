import 'package:flutter/material.dart';
import '../../../../core/constants/theme.dart';

enum PaymentMethod {
  cash,
  mobileMoney,
  card,
}

class PaymentMethodSelector extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.onPaymentMethodSelected,
  }) : super(key: key);

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod _selectedMethod = PaymentMethod.mobileMoney;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentOption(
          title: 'Mobile Money',
          subtitle: 'MTN, Vodafone, AirtelTigo',
          icon: Icons.phone_android,
          method: PaymentMethod.mobileMoney,
        ),
        SizedBox(height: 16),
        _buildPaymentOption(
          title: 'Cash',
          subtitle: 'Pay directly to driver',
          icon: Icons.money,
          method: PaymentMethod.cash,
        ),
        SizedBox(height: 16),
        _buildPaymentOption(
          title: 'Card Payment',
          subtitle: 'Credit or Debit Card',
          icon: Icons.credit_card,
          method: PaymentMethod.card,
        ),
        SizedBox(height: 24),
        if (_selectedMethod == PaymentMethod.mobileMoney) ...[
          Text(
            'Select Mobile Money Provider',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildProviderOption(
                'MTN MoMo',
                isSelected: true,
              ),
              SizedBox(width: 16),
              _buildProviderOption(
                'Vodafone Cash',
                isSelected: false,
              ),
              SizedBox(width: 16),
              _buildProviderOption(
                'AirtelTigo',
                isSelected: false,
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter Mobile Money Number',
              hintText: '024 XXX XXXX',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod method,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
        widget.onPaymentMethodSelected(method);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ghanaGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? ghanaGreen.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ghanaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: ghanaGreen,
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
            Radio(
              value: method,
              groupValue: _selectedMethod,
              activeColor: ghanaGreen,
              onChanged: (PaymentMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                  widget.onPaymentMethodSelected(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderOption(String name, {required bool isSelected}) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? ghanaGreen : Colors.grey.shade300,
            ),
            color: isSelected ? ghanaGreen.withOpacity(0.1) : null,
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? ghanaGreen : textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
