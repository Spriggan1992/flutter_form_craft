# FormCraft

FormCraft is a Flutter package for building and validating forms with less boilerplate.

It provides:
- central form manager for multiple fields
- per-field and full-form validation
- built-in validators and custom validators
- mask support (custom and phone)
- field controller/focus access by key

## Install

```yaml
dependencies:
  flutter_form_craft: ^0.0.1
```

## Quickstart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_craft/form_craft.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final FormCraft form;

  @override
  void initState() {
    super.initState();
    form = FormCraft(
      validationType: FormCraftValidationType.onSubmit,
    );
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            form.buildField(
              key: 'email',
              onChanged: (_) {},
              validators: const [
                FormCraftValidator.required(),
                FormCraftValidator.email(),
              ],
              decorationBuilder: (error) => InputDecoration(
                labelText: 'Email',
                errorText: error,
              ),
            ),
            const SizedBox(height: 12),
            form.buildField(
              key: 'password',
              onChanged: (_) {},
              validators: const [
                FormCraftValidator.required('Password is required'),
              ],
              decorationBuilder: (error) => InputDecoration(
                labelText: 'Password',
                errorText: error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final result = form.validateDetailed();
                if (result.isValid) {
                  final data = form.submitForm();
                  debugPrint('Submit: $data');
                } else {
                  debugPrint('Errors: ${result.errorsByField}');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Cookbook

### 1) Build with custom widget via buildTextField

```dart
form.buildTextField(
  'name',
  (controller) => FormCraftTextField(
    formController: controller,
    onChanged: (_) {},
    validators: const [FormCraftValidator.required()],
    decorationBuilder: (error) => InputDecoration(
      labelText: 'Name',
      errorText: error,
    ),
  ),
);
```

### 1.1) Use FormCraftField widget (buildField alternative)

```dart
FormCraftField(
  form: form,
  fieldKey: 'email',
  onChanged: (_) {},
  validators: const [
    FormCraftValidator.required(),
    FormCraftValidator.email(),
  ],
  decorationBuilder: (error) => InputDecoration(
    labelText: 'Email',
    errorText: error,
  ),
)
```

### 1.2) Use FormCraftPasswordField

```dart
FormCraftPasswordField(
  form: form,
  fieldKey: 'password',
  onChanged: (_) {},
  minLength: 8,
  textInputAction: TextInputAction.done,
)
```

Built-in behavior:
- show/hide password toggle icon
- secure defaults (`obscureText: true`, `enableSuggestions: false`, `autocorrect: false`)
- default validators: required + min length

You can customize messages:

```dart
FormCraftPasswordField(
  form: form,
  fieldKey: 'password',
  onChanged: (_) {},
  requiredMessage: 'Enter your password',
  minLengthMessage: 'At least 10 chars',
  minLength: 10,
)
```

Advanced params are also available directly on `FormCraftField`:

```dart
FormCraftField(
  form: form,
  fieldKey: 'password',
  onChanged: (_) {},
  obscureText: true,
  textInputAction: TextInputAction.done,
  keyboardType: TextInputType.visiblePassword,
  maxLength: 32,
)
```

### 2) Register fields first, build later

```dart
final emailController = form.registerField('email');

FormCraftTextField(
  formController: emailController,
  onChanged: (_) {},
)
```

### 3) Form-level operations

```dart
form.setValue('email', 'user@example.com');
form.setValues({
  'email': 'user@example.com',
  'password': 'secret',
});

final email = form.getValue('email');
final errors = form.getErrors();

form.clearField('email');
form.clearForm();
```

### 4) Validation modes

```dart
final form = FormCraft(
  validationType: FormCraftValidationType.always,
);

form.setValidationType(FormCraftValidationType.onSubmit);
```

Validation type is now applied for both mounted and future fields.

### 5) Per-field and detailed validation

```dart
final isEmailValid = form.validateField('email');

final result = form.validateDetailed();
if (!result.isValid) {
  debugPrint('First invalid key: ${result.firstInvalidKey}');
  debugPrint('Errors by field: ${result.errorsByField}');
}
```

### 6) Server-side error handling

```dart
form.setErrorMessage('email', 'Email already exists');

// Clear manually
form.setErrorMessage('email', null);
```

Set `stickyCustomError: true` to keep server errors until manual clear.

### 7) Masks

Custom mask:

```dart
mask: PersistentMask.defaultValidator(
  maskPattern: '000-000',
)
```

Phone mask with configurable prefix:

```dart
mask: PersistentMask.phone(
  maskPattern: '+0 (000) 000-00-00',
  fixedPrefix: '+1 ',
)
```

### 8) Focus and controller access

```dart
form.getFocusNode('email').requestFocus();

final controller = form.getController('email');
controller.controller.text = 'hello@site.com';
```

## API Overview

Main class:
- `FormCraft`

Common methods:
- `FormCraftField` widget
- `FormCraftPasswordField` widget
- `buildField`
- `buildTextField`
- `registerField`
- `getController`
- `validate`
- `validateDetailed`
- `validateField`
- `submitForm`
- `setValue`
- `setValues`
- `getValue`
- `clearField`
- `clearForm`
- `setErrorMessage`
- `getError`
- `getErrors`
- `setValidationType`
- `getFocusNode`
- `dispose`

## Notes

- Field keys must be unique.
- If you use `isUnmountedFieldValid: false`, pre-registered but unmounted fields fail validation.
- Call `dispose()` on `FormCraft` when the owning widget is disposed.
