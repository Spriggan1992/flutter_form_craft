part of '../form_craft.dart';

/// A class that represents a controller for a FormCraftTextField widget.
///
///
/// The [controller]  responsible for managing the text input of the FormCraftTextField widget.
/// The [focusNode] responsible for managing keyboard focus and to handle keyboard events.
/// The [globalKey] responsible for managing the state of the FormCraftTextField widget.
base class FormController {
  /// The focus node for the FormCraftTextField widget.
  final FocusNode focusNode;

  /// The global key for state management of the FormCraftTextField widget.
  final GlobalKey<FormCraftTextFieldState> globalKey;

  /// A flag that determines whether to persist the state of the FormCraftTextField widget.
  final bool isPersistState;

  /// Validation mode for this field.
  FormCraftValidationType validationType;

// The initial value of the FormCraftTextField widget.
  String? get initialValue => _initialValue;

  // The error message of the FormCraftTextField widget.
  String? get errorMessage => _errorMessage;

  /// The controller for the FormCraftTextField widget.
  TextEditingController get controller => _controller;

  // A flag that determines whether the FormCraftTextField widget has been initialized.
  bool _isInit = false;
  String? _initialValue;
  String? _errorMessage;
  late TextEditingController _controller;

  FormController({
    required this.globalKey,
    required this.focusNode,
    required this.isPersistState,
    this.validationType = FormCraftValidationType.onSubmit,
  });

  void setController(TextEditingController controller) {
    _controller = controller;
  }

  void _setInitialValue(
    String value,
    Function(String value) callback,
  ) {
    if (!_isInit) {
      _isInit = true;
      callback(value);
    }
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
  }

  void _resetForm() {
    controller.clear();
    _errorMessage = null;
    _isInit = false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormController &&
        other.controller == controller &&
        other.focusNode == focusNode &&
        other.globalKey == globalKey &&
        other.initialValue == initialValue &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return controller.hashCode ^
        focusNode.hashCode ^
        globalKey.hashCode ^
        initialValue.hashCode ^
        errorMessage.hashCode;
  }
}
