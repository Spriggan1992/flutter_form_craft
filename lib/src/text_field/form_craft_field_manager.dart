part of '../form_craft.dart';

/// A class that provides a set of utility methods for managing and interacting with a collection of FormCraftTextField widgets.
base class FormCraftFieldManager {
  /// A flag that determines whether to persist the state of the FormCraftTextField widgets.
  late final bool _isPersistState;
  FormCraftValidationType _validationType = FormCraftValidationType.onSubmit;

  /// A map that stores the FormCraftTextField controllers.
  ///
  /// The key is the unique identifier of the FormCraftTextField widget.
  /// The value is the FormCraftTextField controller.
  /// The [FormController] class is responsible for managing the state of the FormCraftTextField widget.
  final Map<String, FormController> controllers = {};

  /// Set only when this manager was created via [FormCraft.withCache].
  final FormCraftCacheController? _cache;

  /// Guards against the cache listener re-scheduling a save while a cached
  /// value is being applied back onto a controller.
  bool _isApplyingCache = false;

  FormCraftFieldManager(
    bool isPersistState, [
    List<String> preRegisteredFields = const [],
    FormCraftValidationType validationType = FormCraftValidationType.onSubmit,
    FormCraftCacheController? cache,
  ]) : _cache = cache {
    _isPersistState = isPersistState;
    _validationType = validationType;
    if (preRegisteredFields.isNotEmpty) {
      for (var key in preRegisteredFields) {
        registerField(key);
      }
    }
  }

  FormController registerField(String key) {
    final existing = controllers[key];
    if (existing != null) {
      return existing;
    }

    final formController = FormController(
      focusNode: FocusNode(),
      globalKey: GlobalKey<FormCraftTextFieldState>(),
      isPersistState: _isPersistState,
      validationType: _validationType,
    ).._controller = TextEditingController();

    controllers[key] = formController;

    final cache = _cache;
    if (cache != null) {
      final cachedValue = cache.pendingRestoredValues?[key];
      if (cachedValue != null) {
        _applyCachedValue(formController, cachedValue);
      }

      formController.controller.addListener(() {
        if (_isApplyingCache) return;
        cache.scheduleSave(submitForm);
      });
    }

    return formController;
  }

  /// Sets a restored value on [formController] and marks it as already
  /// initialized so [FormCraftTextField.initState] (which unconditionally
  /// applies `initialValue ?? ''` the first time a field mounts) doesn't
  /// clobber it when the widget mounts after the value was restored.
  void _applyCachedValue(FormController formController, String value) {
    _isApplyingCache = true;
    formController._isInit = true;
    formController.controller.text = value;
    _isApplyingCache = false;
  }

  /// Loads values persisted under this form's cache key and applies them to
  /// whichever fields are already registered. Values for fields that get
  /// registered later (built after this call resolves) are still applied,
  /// since [registerField] consults [FormCraftCacheController.pendingRestoredValues].
  ///
  /// No-op if this manager wasn't created via [FormCraft.withCache].
  Future<void> restoreFromCache() async {
    final cache = _cache;
    if (cache == null) return;

    final values = await cache.load();
    if (values == null || values.isEmpty) return;

    cache.pendingRestoredValues = values;

    values.forEach((key, value) {
      final controller = controllers[key];
      if (controller != null) {
        _applyCachedValue(controller, value);
      }
    });
  }

  /// Deletes the persisted draft for this form. No-op if this manager wasn't
  /// created via [FormCraft.withCache].
  Future<void> clearCache() async {
    await _cache?.clear();
  }

  FormController getFormController(String key) {
    return registerField(key);
  }

  /// Adds a FormCraftTextField controller to the internal map.
  ///
  /// The [key] is the unique identifier of the FormCraftTextField widget.
  /// The [formController] is the FormCraftTextField controller.
  void addFormController(
    String key,
    FormController formController,
  ) {
    controllers[key] = formController;
  }

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
    final controller = registerField(key);
    return textField(controller);
  }

  /// Reassigns the input value for a specific field.
  ///
  /// The [key] parameter is required and must be the key of an existing field.
  /// The [value] parameter is required and must be a string.
  /// Updates the input value of the FormCraftTextField associated with the specified key.
  void reassignInputValue(
    String key,
    String value, [
    bool isRevalidate = false,
  ]) {
    _checkIfKeyExist(key);

    // Call the private method to reassign the input value for the specified field
    controllers[key]!.controller.text = value;
    if (isRevalidate) {
      controllers[key]!.globalKey.currentState?.validate();
    }
  }

  String getFieldValue(String key) {
    _checkIfKeyExist(key);
    return controllers[key]!.controller.text;
  }

  String? getFieldError(String key) {
    _checkIfKeyExist(key);
    return controllers[key]!.globalKey.currentState?._errorMessage ??
        controllers[key]!.errorMessage;
  }

  Map<String, String?> getAllFieldErrors() {
    final errors = <String, String?>{};
    controllers.forEach((key, _) {
      errors[key] = getFieldError(key);
    });
    return errors;
  }

  bool validateField(
    String key, {
    bool isUnmountedFieldValid = true,
  }) {
    _checkIfKeyExist(key);
    final state = controllers[key]!.globalKey.currentState;
    return state == null ? isUnmountedFieldValid : state.validate();
  }

  /// Gets the [GlobalKey] for a specific field.
  GlobalKey getGlobalKey(String key) {
    _checkIfKeyExist(key);

    // return controllers[key]!.globalKey;
    return controllers[key]!.globalKey;
  }

  /// Gets [FocusNode] for a specific field.
  ///
  /// The [key] parameter is required and must be the key of an existing field.
  FocusNode getFocusNode(String key) {
    _checkIfKeyExist(key);

    // return controllers[key]!.globalKey.currentState!._focusNode;
    return controllers[key]!.focusNode;
  }

  /// Submits the values of all FormCraftTextField widgets.
  ///
  /// Returns a map of field keys to their corresponding input values.
  Map<String, String> submitForm() {
    // Map to store the submitted values of each field
    final items = <String, String>{};

    // Iterate through each field and get its input value
    controllers.forEach((key, formController) {
      items.addAll(
        {key: formController.controller.text},
      );
    });
    // globalKeys.forEach((key, globalKey) {
    //   items.addAll(
    //     {key: globalKey.currentState?._getInputValue() ?? ''},
    //   );
    // });

    // Return the map of field keys and their input values
    return items;
  }

  /// Refreshes the state of all FormCraftTextField widgets.
  ///
  /// Calls the _refreshForm method for each FormCraftTextField widget, if available.
  void refreshForm() {
    // Iterate through each field and call the private method to refresh its state
    controllers.forEach((key, formController) {
      formController.globalKey.currentState?._refreshForm();
    });
    // globalKeys.forEach((key, globalKey) {
    //   globalKey.currentState?._refreshForm();
    // });
  }

  void clearField(String key, {bool isRevalidate = false}) {
    _checkIfKeyExist(key);

    final controller = controllers[key]!;
    controller.controller.clear();
    controller.globalKey.currentState?._reassignError(null);
    controller._setErrorMessage(null);

    if (isRevalidate) {
      controller.globalKey.currentState?.validate();
    }
  }

  void setValues(
    Map<String, String> values, {
    bool isRevalidate = false,
    bool ignoreMissingKeys = false,
  }) {
    values.forEach((key, value) {
      if (!ignoreMissingKeys) {
        reassignInputValue(key, value, isRevalidate);
      } else if (controllers.containsKey(key)) {
        reassignInputValue(key, value, isRevalidate);
      }
    });
  }

  void clearValues(Iterable<String> keys, {bool isRevalidate = false}) {
    for (final key in keys) {
      clearField(key, isRevalidate: isRevalidate);
    }
  }

  /// Resets validation errors for all fields, preserving field values.
  ///
  /// Fields listed in [ignore] are skipped and keep their current error state.
  void resetValidation({List<String> ignore = const []}) {
    controllers.forEach((key, controller) {
      if (ignore.contains(key)) return;
      controller._setErrorMessage(null);
      controller.globalKey.currentState?._reassignError(null);
    });
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
    _checkIfKeyExist(key);

    final state = controllers[key]!.globalKey.currentState;
    if (state == null) {
      throw StateError(
        'Cannot set error message for key $key because the field is not mounted yet or already disposed.',
      );
    }

    // Call the private method to assign a custom error message for the specified field
    state._assignCustomError(
      errorMessage,
      isRedrawState,
    );
  }

  /// Disposes of all resources and clears the field and global key maps.
  void dispose() {
    final cache = _cache;
    if (cache != null) {
      // Flush whatever hasn't been written yet so a debounce window that
      // hasn't fired isn't lost when the user navigates away.
      unawaited(cache.flush(submitForm));
      cache.dispose();
    }

    // Clear the internal maps to release resources
    controllers.forEach((key, formController) {
      formController.controller.dispose();
      formController.focusNode.dispose();
    });
    controllers.clear();
  }

  void disposeSpecificTextField(String key) {
    final controller = controllers.remove(key);
    controller?.focusNode.dispose();
    controller?.controller.dispose();
  }

  void setValidationType(FormCraftValidationType type) {
    _validationType = type;
    controllers.forEach((_, controller) {
      controller.validationType = type;
      controller.globalKey.currentState?._setValidationType(type);
    });
  }

  // Checks if a field with the given key exists in the internal map.
  void _checkIfKeyExist(String key) {
    if (!controllers.keys.contains(key)) {
      throw ArgumentError('The key $key does not exist');
    }
  }
}
