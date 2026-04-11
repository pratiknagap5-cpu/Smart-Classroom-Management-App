/// Form field validators for the app
class Validators {
  /// Validate student name - must not be empty
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter student name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate roll number - must be a positive integer
  static String? validateRollNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter roll number';
    }
    final rollNo = int.tryParse(value.trim());
    if (rollNo == null || rollNo <= 0) {
      return 'Enter a valid roll number';
    }
    return null;
  }

  /// Validate class selection
  static String? validateClass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a class';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate fee amount - must be non-negative number
  static String? validateFeeAmount(String? value, {bool allowZero = true}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Enter a valid amount';
    }
    if (amount < 0) {
      return 'Amount cannot be negative';
    }
    if (!allowZero && amount == 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// Validate paid amount does not exceed total fee
  static String? validatePaidAmount(String? value, double totalFee) {
    final baseValidation = validateFeeAmount(value);
    if (baseValidation != null) return baseValidation;

    final paid = double.tryParse(value!.trim())!;
    if (paid > totalFee) {
      return 'Paid amount cannot exceed total fee (₹${totalFee.toStringAsFixed(0)})';
    }
    return null;
  }
}
