part of '../form_craft.dart';

/// A convenience password field built on top of [FormCraftField].
///
/// Includes:
/// - obscure/show toggle button
/// - secure text defaults
/// - optional built-in required and min-length validators
class FormCraftPasswordField extends StatefulWidget {
  final FormCraft form;
  final String fieldKey;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final String? customErrorMessage;
  final List<FormCraftValidator>? validators;

  final bool requireNotEmpty;
  final String requiredMessage;
  final int? minLength;
  final String? minLengthMessage;

  final String labelText;
  final InputDecoration Function(String? errorMessage)? decorationBuilder;
  final bool stickyCustomError;

  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool? enabled;
  final bool canRequestFocus;

  final Widget? iconHide;
  final Widget? iconShow;

  const FormCraftPasswordField({
    required this.form,
    required this.fieldKey,
    required this.onChanged,
    this.initialValue,
    this.customErrorMessage,
    this.validators,
    this.requireNotEmpty = true,
    this.requiredMessage = 'Password is required',
    this.minLength = 8,
    this.minLengthMessage,
    this.labelText = 'Password',
    this.decorationBuilder,
    this.stickyCustomError = false,
    this.textInputAction,
    this.autofocus = false,
    this.enabled,
    this.canRequestFocus = true,
    this.iconHide,
    this.iconShow,
    super.key,
  });

  @override
  State<FormCraftPasswordField> createState() =>
      _FormCraftPasswordFieldState();
}

class _FormCraftPasswordFieldState extends State<FormCraftPasswordField> {
  bool _obscureText = true;

  List<FormCraftValidator> _buildValidators() {
    final result = <FormCraftValidator>[];

    if (widget.requireNotEmpty) {
      result.add(FormCraftValidator.required(widget.requiredMessage));
    }

    if ((widget.minLength ?? 0) > 0) {
      final minLength = widget.minLength!;
      result.add(
        FormCraftValidator.custom(
          message:
              widget.minLengthMessage ?? 'Password must be at least $minLength characters',
          predicate: (input) {
            final value = input ?? '';
            if (value.isEmpty && !widget.requireNotEmpty) {
              return true;
            }
            return value.length >= minLength;
          },
        ),
      );
    }

    result.addAll(widget.validators ?? const []);
    return result;
  }

  InputDecoration _buildDecoration(String? errorMessage) {
    final base = widget.decorationBuilder?.call(errorMessage) ??
        InputDecoration(
          labelText: widget.labelText,
          errorText: errorMessage,
        );

    return base.copyWith(
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: _obscureText
            ? (widget.iconHide ?? const Icon(Icons.visibility_off))
            : (widget.iconShow ?? const Icon(Icons.visibility)),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormCraftField(
      form: widget.form,
      fieldKey: widget.fieldKey,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,
      customErrorMessage: widget.customErrorMessage,
      validators: _buildValidators(),
      stickyCustomError: widget.stickyCustomError,
      decorationBuilder: _buildDecoration,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      canRequestFocus: widget.canRequestFocus,
    );
  }
}
