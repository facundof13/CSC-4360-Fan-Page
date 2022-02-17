class Validator {
  static validateText(String input) {
    return input.isNotEmpty && input != '';
  }

  static validatePassword(String input) {
    return input.isNotEmpty && input.length >= 8;
  }

  static validateEmail(String input) {
    return input.contains('@');
  }

  static bool validateControllers(inputs) {
    for (var input in inputs) {
      switch (input['type']) {
        case 'password':
          if (!validatePassword(input['value'])) {
            return false;
          }
          break;
        case 'text':
          if (!validateText(input['value'])) {
            return false;
          }
          break;
        case 'email':
          if (!validateEmail(input['value'])) {
            return false;
          }
          break;
      }
    }
    return true;
  }
}
