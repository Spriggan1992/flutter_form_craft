library form_craft;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_craft/src/masks/mask_formatter.dart';
import 'package:flutter_form_craft/src/masks/mask_type.dart';
import 'package:flutter_form_craft/src/masks/masked_phone_input_formatter.dart';

import 'dart:ui' as ui;

import 'validation/form_craft_validation_type.dart';
import 'validation/validators/form_craft_validator.dart';
import 'masks/persistent_mask.dart';

part 'text_field/form_craft_text_field.dart';
part 'text_field/form_craft_field_manager.dart';
part 'validation/form_craft_validator_manager.dart';
part 'text_field/form_controller.dart';
part 'masks/form_craft_mask_text_editing_controller.dart';

/// A utility class that helps manage and interact with a collection of FormCraftTextField widgets.
class FormCraft {
  // Internal instance of FormCraftFieldManager.
  late FormCraftFieldManager _fieldManager;

  // Internal instance of FormCraftValidatorManager.
  late FormCraftValidatorManager _validatorManager;

  /// Create a new instance of FormCraft.
  ///
  /// The [isPersistState] parameter determines whether to persist the state of the FormCraftTextField widgets.
  FormCraft({
    bool isPersistState = true,
    List<String> preRegisteredFields = const [],
  }) {
    _fieldManager = FormCraftFieldManager(isPersistState, preRegisteredFields);
    _validatorManager = FormCraftValidatorManager(_fieldManager);
  }

  /// Create a new instance of FormCraft for testing purposes.
  ///
  /// The [fieldManager] parameter is required and must be an instance of FormCraftFieldManager.
  /// The [validatorManager] parameter is required and must be an instance of FormCraftValidatorManager.
  FormCraft.test(
    FormCraftFieldManager fieldManager,
    FormCraftValidatorManager validatorManager,
  )   : _fieldManager = fieldManager,
        _validatorManager = validatorManager;

  /// Builds a FormCraftTextField widget with the specified key and configuration.
  ///
  /// If a field with the given key already exists, it returns the existing widget to avoid duplicates.
  ///
  /// The [key] parameter is required and must be unique.
  /// The [textField] parameter is required and must be a function that returns a FormCraftTextField widget.
  ///
  /// Returns the created or existing FormCraftTextField widget.
  Widget buildTextField(
    String key,
    Widget Function(
      FormController formController,
    ) textField,
  ) {
    return _fieldManager.buildTextField(key, textField);
  }

  /// Validates all FormCraftTextField widgets and returns true if all are valid.
  ///
  /// Iterates through each field, validates its content, and returns a boolean indicating overall validity.
  bool validate() {
    return _validatorManager.validate();
  }

  /// Reassigns the input value for a specific field.
  ///
  /// The [key] parameter is required and must be the key of an existing field.
  /// The [value] parameter is required and must be a string.
  /// Updates the input value of the FormCraftTextField associated with the specified key.
  void reassignInputValue(
    String key,
    String value, {
    bool isRevalidate = false,
  }) {
    _fieldManager.reassignInputValue(key, value, isRevalidate);
  }

  GlobalKey getGlobalKey(String key) {
    return _fieldManager.getGlobalKey(key);
  }

  /// Gets [FocusNode] for a specific field.
  ///
  /// The [key] parameter is required and must be the key of an existing field.
  FocusNode getFocusNode(String key) {
    return _fieldManager.getFocusNode(key);
  }

  /// Submits the values of all FormCraftTextField widgets.
  ///
  /// Returns a map of field keys to their corresponding input values.
  Map<String, String> submitForm() {
    return _fieldManager.submitForm();
  }

  /// Refreshes the state of all FormCraftTextField widgets.
  ///
  /// Calls the _refreshForm method for each FormCraftTextField widget, if available.
  void refreshForm() {
    _fieldManager.refreshForm();
  }

  /// Sets a custom error message for a specific field.
  ///
  /// The [key] parameter is required and must be the key of an existing field.
  /// The [errorMessage] parameter is the custom error message to be set.
  /// The [isRedrawState] parameter determines whether to redraw the state after setting the error message.
  void setErrorMessage(
    String key,
    String? errorMessage, {
    bool isRedrawState = true,
  }) {
    _fieldManager.setErrorMessage(
      key,
      errorMessage,
      isRedrawState: isRedrawState,
    );
  }

  /// Sets the validation type for all FormCraftTextField widgets.
  ///
  /// The [type] is the validation type to be set for all fields.
  /// It is necessary to set the validation type after build widgets to apply the changes.
  /// Otherwise the default validation type will be not applied.
  void setValidationType(FormCraftValidationType type) {
    _validatorManager.setValidationType(type);
  }

  void disposeField(String key) {
    _fieldManager.disposeSpecificTextField(key);
  }

  /// Disposes of all resources and clears the field and global key maps.
  void dispose() {
    _fieldManager.dispose();
  }
}
