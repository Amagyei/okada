// lib/data/models/api_error_model.dart
class ApiError {
  final Map<String, dynamic> errors;

  ApiError({required this.errors});

  // Factory constructor to create an instance from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(errors: json);
  }

  // Helper getter to extract the first meaningful error message
  String get firstError {
    if (errors.isEmpty) return "An unknown error occurred.";

    // Check for Django REST framework's common 'detail' key
    if (errors.containsKey('detail')) {
      return errors['detail'].toString();
    }

    // Check for field errors (like {'field_name': ['Error message']})
    var firstValue = errors.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }

    // Fallback
    return errors.toString();
  }
}