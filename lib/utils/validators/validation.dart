class PValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w\.-]+@([\w]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(email)) {
      return 'Invalid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#\$%\^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    final phoneNumber = value?.trim() ?? '';
    if (phoneNumber.isEmpty) {
      return 'Phone number is required.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(phoneNumber)) {
      return 'Invalid phone number format (10 digits required).';
    }

    return null;
  }

  static String? validateRequiredSelection(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validateOptionalUrl(String? fieldName, String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;

    final normalizedUrl = url.contains('://') ? url : 'https://$url';
    final uri = Uri.tryParse(normalizedUrl);
    final isValidWebUrl = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.') &&
        !uri.host.contains(' ');

    if (!isValidWebUrl) {
      return 'Invalid ${fieldName ?? 'URL'} format.';
    }

    return null;
  }

  static String? validateRequiredUrl(String? fieldName, String? value) {
    final emptyError = validateEmptyText(fieldName, value);
    if (emptyError != null) return emptyError;
    return validateOptionalUrl(fieldName, value);
  }

  static String? validateOptionalPositiveNumber(
    String? fieldName,
    String? value,
  ) {
    final numberValue = value?.trim() ?? '';
    if (numberValue.isEmpty) return null;

    final parsedNumber = num.tryParse(numberValue);
    if (parsedNumber == null || parsedNumber <= 0) {
      return '$fieldName must be a positive number.';
    }

    return null;
  }

  static String? validateRequiredPositiveNumber(
    String? fieldName,
    String? value,
  ) {
    final emptyError = validateEmptyText(fieldName, value);
    if (emptyError != null) return emptyError;
    return validateOptionalPositiveNumber(fieldName, value);
  }

  static String? validateOptionalNonNegativeNumber(
    String? fieldName,
    String? value,
  ) {
    final numberValue = value?.trim() ?? '';
    if (numberValue.isEmpty) return null;

    final parsedNumber = num.tryParse(numberValue);
    if (parsedNumber == null || parsedNumber < 0) {
      return '$fieldName must be zero or greater.';
    }

    return null;
  }

  static String? validateRequiredNonNegativeNumber(
    String? fieldName,
    String? value,
  ) {
    final emptyError = validateEmptyText(fieldName, value);
    if (emptyError != null) return emptyError;
    return validateOptionalNonNegativeNumber(fieldName, value);
  }

  static String? validateRequiredPercentage(
    String? fieldName,
    String? value, {
    bool allowHundred = true,
  }) {
    final emptyError = validateEmptyText(fieldName, value);
    if (emptyError != null) return emptyError;

    final parsedNumber = num.tryParse(value!.trim());
    final num maxValue = allowHundred ? 100 : 99.999999;
    if (parsedNumber == null || parsedNumber <= 0 || parsedNumber > maxValue) {
      return '$fieldName must be between 1 and 100.';
    }

    return null;
  }

  static String? validateFlexiblePhoneNumber(String? fieldName, String? value) {
    final phoneNumber = value?.trim() ?? '';
    if (phoneNumber.isEmpty) {
      return '$fieldName is required.';
    }

    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegExp = RegExp(r'^\+?\d{7,15}$');

    if (!phoneRegExp.hasMatch(cleaned)) {
      return 'Invalid phone number format.';
    }

    return null;
  }

  static DateTime? parseSlashDate(String? value) {
    final dateText = value?.trim() ?? '';
    final parts = dateText.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    return parsed;
  }

  static String? validateRequiredPastOrPresentDate(
    String? fieldName,
    String? value,
  ) {
    final emptyError = validateEmptyText(fieldName, value);
    if (emptyError != null) return emptyError;

    final parsedDate = parseSlashDate(value);
    if (parsedDate == null) {
      return 'Invalid $fieldName format.';
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (parsedDate.isAfter(todayOnly)) {
      return '$fieldName cannot be in the future.';
    }

    return null;
  }
}
