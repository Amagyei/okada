import 'package:flutter/material.dart';
// Adjust import path based on your project structure
import 'package:okada_app/core/constants/theme.dart';

class LocationInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  // final VoidCallback? onSearchIconTap; // Removed, use trailing instead if needed
  final bool readOnly;
  final bool enabled;
  final Widget? trailing; // Keep for GPS button etc.
  final ValueChanged<String>? onChanged; // Callback for text changes
  final ValueChanged<String>? onSubmitted; // Callback for submission
  final TextInputAction? textInputAction; // Allow customizing keyboard action

  const LocationInput({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
    // this.onSearchIconTap, // Removed
    this.readOnly = false, // *** Default to false to allow typing ***
    this.enabled = true,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Use TextFormField for direct input
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChanged, // Pass onChanged callback
      onFieldSubmitted: onSubmitted, // Pass onSubmitted callback
      textInputAction: textInputAction ?? TextInputAction.search, // Default to search action
      style: TextStyle(
        color: enabled ? textPrimary : textSecondary.withOpacity(0.7),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? textSecondary : textSecondary.withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? ghanaGreen : Colors.grey.shade400,
        ),
        // Suffix combines trailing widget OR a clear button if text exists
        suffixIcon: enabled
          ? Row( // Use Row to potentially have multiple icons
              mainAxisSize: MainAxisSize.min, // Prevent row from expanding
              children: [
                if (trailing != null) trailing!,
                // Add clear button if controller has text and not readOnly
                if (!readOnly)
                   ValueListenableBuilder<TextEditingValue>(
                     valueListenable: controller,
                     builder: (context, value, child) {
                        if (value.text.isNotEmpty) {
                           return IconButton(
                              icon: const Icon(Icons.clear, size: 20, color: textSecondary),
                              tooltip: 'Clear',
                              padding: const EdgeInsets.only(right: 8.0), // Add some padding
                              constraints: const BoxConstraints(),
                              onPressed: () => controller.clear(), // Clear the text field
                           );
                        }
                        return const SizedBox.shrink(); // Return empty if no text
                     },
                   ),
                 // Add padding if trailing exists AND clear button is shown
                 if (trailing != null && controller.text.isNotEmpty && !readOnly)
                    const SizedBox(width: 4),

              ],
            )
          : null,
        filled: true,
        fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ghanaGreen, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.only(left:16, right: 4, top: 14, bottom: 14), // Adjust right padding for icons
      ),
    );
  }
}