part of '../form_craft.dart';

/// A FormCraftTextField widget that can be used to build a FormCraft form.
///
///
/// [onChanged] is a required callback that is called whenever the input value changes.
/// [validators] is an optional list of [FormCraftValidator] functions that are called whenever the input value changes.
/// [initialValue] is an optional string that is used to set the initial value of the input.
/// [formController] is a required key that is used to manage the state of the FormCraftTextField widget.
/// [decorationBuilder] is an optional callback that provides custom decoration based on the validation error message.
///
/// This widget is a wrapper around the [TextField] widget and provides additional functionality.
/// It can be used to build a FormCraft form by passing it to the [FormCraft.buildTextField] method.
class FormCraftTextField extends StatefulWidget {
  /// Required callback that is called whenever the input value changes.
  final Function(String value) onChanged;

  /// An optional list of [FormCraftValidator] functions that are called
  ///
  ///
  /// whenever the input value changes.
  /// If the input value is invalid, the error message returned by the validator is displayed.
  /// If validators is null, the input value is considered valid.
  final List<FormCraftValidator>? validators;

  /// An optional string that is used to set error message for the input.
  ///
  /// If the error message not provided, the default error message will be displayed.
  /// If the error message is provided, the custom error message will be displayed first and the     default error messages will be displayed after the custom error message.
  final String? customErrorMessage;

  /// An optional string that is used to set the initial value of the input.
  ///
  /// If the initial value is not provided, the input will be empty.
  final String? initialValue;

  /// An optional callback that provides custom decoration based on the validation error message.
  ///
  /// It's necessary to provide the error message to the decorationBuilder function.
  /// Otherwise if the error message will not be displayed.
  final InputDecoration Function(String? errorMessage)? decorationBuilder;

  /// Controller for managing the state of the FormCraftTextField widget.
  final FormController formController;

  final UndoHistoryController? undoController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final MouseCursor? mouseCursor;
  final Widget? Function(
    BuildContext, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  })? buildCounter;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final PersistentMask? mask;

  /// Constructor for initializing the FormCraftTextField.
  FormCraftTextField({
    required this.onChanged,
    this.validators,
    this.initialValue,
    this.undoController,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.contextMenuBuilder,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.keyboardAppearance,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.contentInsertionConfiguration,
    this.restorationId,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.decorationBuilder,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.cursorWidth = 2.0,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.expands = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.customErrorMessage,
    required this.formController,
    this.mask,
  }) : super(key: formController.globalKey);

  @override
  State<FormCraftTextField> createState() => FormCraftTextFieldState();
}

class FormCraftTextFieldState extends State<FormCraftTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorMessage;
  String? _customErrorMessage;
  List<FormCraftValidator>? _validators;
  FormCraftValidationType _validateType = FormCraftValidationType.onSubmit;

  @override
  void initState() {
    _validators = [
      if (widget.mask?.validator != null) widget.mask!.validator!,
      ...widget.validators ?? []
    ];
    _customErrorMessage = widget.customErrorMessage;
    _focusNode = widget.formController.focusNode;

    if (widget.mask != null) {
      widget.formController.setController(MaskedTextController(widget.mask!));
    }
    _controller = widget.formController.controller;

    widget.formController._setInitialValue(
      widget.initialValue ?? '',
      (value) {
        if (widget.mask != null) {
          final formattedValue = switch (widget.mask!.maskType) {
            MaskType.custom =>
              MaskedInputFormatter(widget.mask!.maskPattern).maskedValue,
            MaskType.phone => MaskedPhoneInputFormatter(
                    widget.mask!.maskPattern,
                    fixedPrefix: '+7 ',
                    initialValue: value)
                .maskedValue,
          };
          _controller.text = formattedValue;
        } else {
          _controller.text = value;
        }
      },
    );
    _errorMessage = widget.formController.errorMessage;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormCraftTextField oldWidget) {
    // _focusNode = widget.formController.focusNode;
    // _controller = widget.formController.controller;
    // _errorMessage = widget.formController.errorMessage;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _focusNode = widget.formController.focusNode;
    _controller = widget.formController.controller;
    _errorMessage = widget.formController.errorMessage;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!widget.formController.isPersistState) {
      widget.formController._resetForm();
    }
    super.dispose();
  }

  void _setValidationType(FormCraftValidationType type) {
    setState(() {
      _validateType = type;
    });
  }

// Reassigns the validation error for the field.
  void _reassignError(String? value) {
    setState(() {
      _errorMessage = value;
    });
    widget.formController._setErrorMessage(_errorMessage);
  }

// Retrieves the current input value.
  String _getInputValue() {
    return _controller.text;
  }

// Refreshes the state of the input field.
  void _refreshForm() {
    _reassignError(null);
    _controller.clear();
  }

// Validates the input field.
  bool validate() {
    if (_customErrorMessage?.isEmpty ?? true) {
      if (_validators == null) {
        return true;
      } else {
        for (var validator in _validators!) {
          _reassignError(validator.validate(_controller.text));

          if (validator.validate(_controller.text) != null) {
            break;
          }
        }

        return _errorMessage == null;
      }
    } else {
      _reassignError(_customErrorMessage);

      return false;
    }
  }

// Assigns a custom error message for the field.
// If [isRedrawState] is true, the state is redrawn after setting the error message.
  void _assignCustomError(
    String? errorMessage, [
    bool isRedrawState = true,
  ]) {
    _customErrorMessage = errorMessage;
    _errorMessage = errorMessage;
    if (isRedrawState) {
      setState(() {});
    }
  }

// Callback when the input value changes.
  void _onChanged(String value) {
    if (_validateType == FormCraftValidationType.onSubmit) {
      _reassignError(null);
    } else {
      validate();
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      undoController: widget.undoController,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      contextMenuBuilder: widget.contextMenuBuilder,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: [
        if (widget.mask != null)
          switch (widget.mask!.maskType) {
            MaskType.custom => MaskedInputFormatter(widget.mask!.maskPattern),
            MaskType.phone => MaskedPhoneInputFormatter(
                widget.mask!.maskPattern,
                fixedPrefix: '+7 ',
                initialValue: widget.initialValue ?? ''),
          },
        ...widget.inputFormatters ?? []
      ],
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      scribbleEnabled: widget.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      canRequestFocus: widget.canRequestFocus,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
      onChanged: _onChanged,
      decoration: widget.decorationBuilder?.call(_errorMessage) ??
          InputDecoration(
            errorText: _errorMessage,
          ),
    );
  }
}
