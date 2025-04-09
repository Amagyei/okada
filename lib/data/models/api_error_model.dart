// lib/data/models/api_error_model.dart

/// Represents a structured error response potentially received from the API.
/// Helps in extracting user-friendly error messages.
class ApiError {
  // Stores the raw error map received from the backend
  final Map<String, dynamic> errors;

  ApiError({required this.errors});

  /// Factory constructor to create an instance from a JSON map.
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(errors: json);
  }

  /// Helper getter to extract the first meaningful error message.
  /// Handles common Django REST Framework error structures like:
  /// - {'detail': 'Error message'}
  /// - {'field_name': ['Error message 1', 'Error message 2']}
  String get firstError {
    if (errors.isEmpty) {
      // Handle cases where the error map might be empty but status indicates error
      return "An unknown API error occurred.";
    }

    // Check for DRF's common 'detail' key for non-field specific errors
    if (errors.containsKey('detail') && errors['detail'] != null) {
      return errors['detail'].toString();
    }

    // Check for DRF's 'non_field_errors' key
    if (errors.containsKey('non_field_errors') && errors['non_field_errors'] is List) {
       final nonFieldErrors = errors['non_field_errors'] as List;
       if (nonFieldErrors.isNotEmpty) {
           return nonFieldErrors.first.toString();
       }
    }

    // Check for field-specific errors (like {'field_name': ['Error message', ...]})
    // Iterate through values to find the first list of error messages.
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        // Return the first error message from the first list found.
        return value.first.toString();
      }
    }

    // Fallback if the structure doesn't match common patterns
    // Return the first value's string representation or the whole map string.
    return errors.values.first?.toString() ?? errors.toString();
  }
}
