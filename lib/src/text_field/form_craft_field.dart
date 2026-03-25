part of '../form_craft.dart';

/// A convenience widget that binds a field key to [FormCraft]
/// and internally builds a [FormCraftTextField].
///
/// Use this when you want declarative widget syntax instead of
/// calling `form.buildField(...)` inline.
class FormCraftField extends StatelessWidget {
  final FormCraft form;
  final String fieldKey;
  final Function(String value) onChanged;
  final List<FormCraftValidator>? validators;
  final String? customErrorMessage;
  final String? initialValue;
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
  @Deprecated(
    'Use stylusHandwritingEnabled instead. '
    'This will be removed in a future release.',
  )
  final bool? scribbleEnabled;
  final bool? stylusHandwritingEnabled;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final InputDecoration Function(String? errorMessage)? decorationBuilder;
  final PersistentMask? mask;
  final bool stickyCustomError;

  const FormCraftField({
    required this.form,
    required this.fieldKey,
    required this.onChanged,
    this.validators,
    this.customErrorMessage,
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
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    @Deprecated(
      'Use stylusHandwritingEnabled instead. '
      'This will be removed in a future release.',
    )
    this.scribbleEnabled = true,
    this.stylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.decorationBuilder,
    this.mask,
    this.stickyCustomError = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return form.buildTextField(
      fieldKey,
      (controller) => FormCraftTextField(
        formController: controller,
        onChanged: onChanged,
        validators: validators,
        customErrorMessage: customErrorMessage,
        initialValue: initialValue,
        undoController: undoController,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        textDirection: textDirection,
        readOnly: readOnly,
        contextMenuBuilder: contextMenuBuilder,
        showCursor: showCursor,
        obscuringCharacter: obscuringCharacter,
        autofocus: autofocus,
        obscureText: obscureText,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        onAppPrivateCommand: onAppPrivateCommand,
        inputFormatters: inputFormatters,
        enabled: enabled,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorOpacityAnimates: cursorOpacityAnimates,
        cursorColor: cursorColor,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        dragStartBehavior: dragStartBehavior,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        onTap: onTap,
        onTapOutside: onTapOutside,
        mouseCursor: mouseCursor,
        buildCounter: buildCounter,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        contentInsertionConfiguration: contentInsertionConfiguration,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        scribbleEnabled: scribbleEnabled,
        stylusHandwritingEnabled: stylusHandwritingEnabled,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
        canRequestFocus: canRequestFocus,
        spellCheckConfiguration: spellCheckConfiguration,
        magnifierConfiguration: magnifierConfiguration,
        decorationBuilder: decorationBuilder,
        mask: mask,
        stickyCustomError: stickyCustomError,
      ),
    );
  }
}
