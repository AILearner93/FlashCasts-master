class FieldValidator {
  static String? validateEmptyField(String? value) {
    if (value!.isEmpty) {
      return "Field can't be empty";
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value!.isEmpty) return "Please enter first name";
    if (value.length < 3) {
      return "First name is too short";
    }
    if (value.length >= 50) {
      return "First name must be less than 50 characters";
    }
    if (!RegExp(r"^([ \u00c0-\u01ffa-zA-Z'\-])+$").hasMatch(value)) {
      return 'Invalid Name';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value!.isEmpty) return "Please enter last name";
    if (value.length < 3) {
      return "Last name is too short";
    }
    if (value.length >= 50) {
      return "Last name must be less than 50 characters";
    }
    if (!RegExp(r"^([ \u00c0-\u01ffa-zA-Z'\-])+$").hasMatch(value)) {
      return 'Invalid Name';
    }
    return null;
  }

  static String? validateUserName(String? value) {
    if (value!.isEmpty) return "Please enter User name";
    if (value.length <= 2) {
      return "User name is too short";
    }
    if (value.length >= 50) {
      return "User mame must be less than 50 characters";
    }
    return null;
  }

  static String? validateUserID(String? value) {
    // if (value.isEmpty) return "Please enter User ID";
    // if (value.length <= 2) {
    //   return "User ID is too short";
    // }
    // if (value.length >= 50) {
    //   return "User ID must be less than 50 characters";
    // }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value!.isEmpty) return "Please enter First name";
    if (value.length <= 2) {
      return "Full name is too short";
    }
    if (value.length >= 50) {
      return "Full mame must be less than 50 characters";
    }
    return null;
  }

  static String? validateFullName2(String? value) {
    if (value!.isEmpty) return "Please enter Last name";
    if (value.length <= 2) {
      return "Full name is too short";
    }
    if (value.length >= 50) {
      return "Full mame must be less than 50 characters";
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value!.isEmpty) return "Phone number is required";
    if (!value.contains('+')) {
      return "valid phone number like : (+923001234567) ";
    }
    if (value.length < 12) {
      return "Please enter correct phone number";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Please enter email address";
    }
    if (!RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value)) {
      return "Invalid email address";
    }
    return null;
  }

  static String? validateOldPassword(String? value) {
    if (value!.isEmpty) return "Please enter old password";
    if (value.length < 8) return "Password should contain at least 8 character";
    if (!RegExp(r"^(?=.*[A-Za-z])(?=.*\d).{8,}$").hasMatch(value)) {
      return 'Password should be alphanumeric';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty) return "Please enter password";
    //if (value.length < 6) return "Password should contain at least 6 character";
    // if (!RegExp(r"^(?=.*[A-Za-z])(?=.*\d).{8,}$").hasMatch(value)) {
    //   return 'Password should be alphanumeric';
    // }
    return null;
  }

  static String? validatePasswordMatch(String? value, String? pass2) {
    if (value!.isEmpty) return "Confirm password is required";
    if (value != pass2) {
      return 'Password didn\'t match';
    }
    return null;
  }

  static String? validateCountry(String? value) {
    if (value!.isEmpty) return "Please enter country of issue";
    if (value.length < 3) {
      return "Country name is too short";
    }
    if (value.length >= 20) {
      return "Country name must be less than 20 characters";
    }
    if (!RegExp(r"^([ \u00c0-\u01ffa-zA-Z'\-])+$").hasMatch(value)) {
      return 'Invalid Name';
    }
    return null;
  }

  static String? validateDigits(String? value) {
    if (value!.isEmpty) return "Please enter Last 4 digits ID/Passport";
    if (value.length < 4) {
      return "Invalid Digits";
    }
    if (value.length > 11) {
      return " Digits must be equal to 4";
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value!.isEmpty) return "OTP is required";
    if (!RegExp(r'^(?=.*?[0-9])(?!.*?[!@#\$&*~+/.,():N]).{6,}$')
        .hasMatch(value.trim())) {
      return "Please enter a valid OTP";
    }
    return null;
  }

  static String? validateIssueDate(String? value) {
    if (value!.isEmpty) return "Date of issue is required.";
    return null;
  }

  static String? fieldRequired(String? value) {
    if (value!.isEmpty) return "Field required";
    return null;
  }
}
