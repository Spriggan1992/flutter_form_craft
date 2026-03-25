part of '../form_craft.dart';

/// A class that provides a set of utility methods for managing and interacting with a collection of FormCraftTextField widgets.
base class FormCraftValidatorManager {
  /// Map of field keys to corresponding FormCraftTextField widgets.
  final FormCraftFieldManager _manager;
  final bool _isUnmountedFieldValid;

  /// Creates a new instance of FormCraftValidatorManager.
  const FormCraftValidatorManager(
    this._manager, {
    bool isUnmountedFieldValid = true,
  }) : _isUnmountedFieldValid = isUnmountedFieldValid;

  /// Validates all FormCraftTextField widgets and returns true if all are valid.
  ///
  /// Iterates through each field, validates its content, and returns a boolean indicating overall validity.
  bool validate() {
    // List to store the validation results for each field
    var validate = <bool>[];
    _manager.controllers.forEach((key, value) {
      // Validate the current field and add the result to the list
      final state = value.globalKey.currentState;
      final isValid = state == null ? _isUnmountedFieldValid : state.validate();

      validate.add(isValid);
    });

    // Return true if all fields are valid, false otherwise
    return validate.every((element) => element);
  }

  FormCraftValidationResult validateDetailed() {
    final errorsByField = <String, String?>{};
    String? firstInvalidKey;

    _manager.controllers.forEach((key, controller) {
      final state = controller.globalKey.currentState;
      final isValid = state == null ? _isUnmountedFieldValid : state.validate();
      final error = state?._errorMessage ?? controller.errorMessage;
      errorsByField[key] = error;

      if (!isValid && firstInvalidKey == null) {
        firstInvalidKey = key;
      }
    });

    return FormCraftValidationResult(
      isValid: firstInvalidKey == null,
      errorsByField: errorsByField,
      firstInvalidKey: firstInvalidKey,
    );
  }

  /// Sets the validation type for all FormCraftTextField widgets.
  ///
  /// The [type] is the validation type to be set for all fields.
  void setValidationType(FormCraftValidationType type) {
    _manager.setValidationType(type);
  }
}
