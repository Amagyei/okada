
import 'package:flutter/material.dart';
import '../../../../core/constants/theme.dart';

class LocationInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;

  const LocationInput({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ghanaGreen),
        suffixIcon: IconButton(
          icon: Icon(Icons.search, color: textSecondary),
          onPressed: onTap,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      readOnly: true,
      onTap: onTap,
    );
  }
}
