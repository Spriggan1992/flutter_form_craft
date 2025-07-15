part of '../form_craft.dart';

/// A class that provides a set of utility methods for managing and interacting with a collection of FormCraftTextField widgets.
base class FormCraftValidatorManager {
  /// Map of field keys to corresponding FormCraftTextField widgets.
  final FormCraftFieldManager _manager;

  /// Creates a new instance of FormCraftValidatorManager.
  const FormCraftValidatorManager(this._manager);

  /// Validates all FormCraftTextField widgets and returns true if all are valid.
  ///
  /// Iterates through each field, validates its content, and returns a boolean indicating overall validity.
  bool validate() {
    // List to store the validation results for each field
    var validate = <bool>[];
    _manager.controllers.forEach((key, value) {
      // Validate the current field and add the result to the list
      final isValid = value.globalKey.currentState?.validate() ?? true;

      validate.add(isValid);
    });

    // Return true if all fields are valid, false otherwise
    return validate.every((element) => element);
  }

  /// Sets the validation type for all FormCraftTextField widgets.
  ///
  /// The [type] is the validation type to be set for all fields.
  void setValidationType(FormCraftValidationType type) {
    _manager.controllers.forEach((_, controller) {
      controller.globalKey.currentState?._setValidationType(type);
    });
  }
}
