library form_craft_test;

import 'package:flutter/material.dart';
import 'package:flutter_form_craft/src/masks/persistent_mask.dart';
import 'package:flutter_form_craft/src/form_craft.dart';
import 'package:flutter_form_craft/src/validation/form_craft_validation_type.dart';
import 'package:flutter_form_craft/src/validation/validators/form_craft_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormCraft Integration Tests', () {
    testWidgets('Adding Fields', (WidgetTester tester) async {
      final formCraftFieldManager = FormCraftFieldManager(true);

      const key = 'field_key';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraftFieldManager.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (value) {},
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(formCraftFieldManager.controllers.containsKey(key), true);
    });

    testWidgets('Validation - Valid Input', (WidgetTester tester) async {
      final formCraft = FormCraft();
      const key = 'email_field';
      const email = 'test@example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraft.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (value) {},
                    validators: const [
                      FormCraftValidator.email(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      formCraft.reassignInputValue(key, email);
      final isValid = formCraft.validate();

      expect(isValid, true);
    });

    testWidgets('Validation - Invalid Input', (WidgetTester tester) async {
      final formCraft = FormCraft();
      const key = 'required_field';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraft.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (value) {},
                    validators: const [
                      FormCraftValidator.required(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Field is empty, should fail validation
      final isValid = formCraft.validate();

      expect(isValid, false);
    });

    testWidgets('Input Reassignment', (WidgetTester tester) async {
      final fieldManager = FormCraftFieldManager(true);
      final validatorManager = FormCraftValidatorManager(fieldManager);

      final formCraft = FormCraft.test(fieldManager, validatorManager);

      const key = 'input_field';
      const initialValue = 'initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraft.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (value) {},
                    initialValue: initialValue,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Change the input value
      const newValue = 'changed';

      await tester.pump();

      // Verify that the input value has been updated
      final inputFieldFinder = find.byKey(fieldManager.controllers[key]!.globalKey);
      expect(inputFieldFinder, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(fieldManager.controllers[key]!.globalKey),
        newValue,
      );
      expect(find.text(newValue), findsOneWidget);
    });

    testWidgets('Custom error clears on input by default', (WidgetTester tester) async {
      final formCraft = FormCraft();
      const key = 'custom_error_default_clear';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraft.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (_) {},
                    validators: const [FormCraftValidator.required()],
                  ),
                );
              },
            ),
          ),
        ),
      );

      formCraft.setErrorMessage(key, 'Server error');
      expect(formCraft.validate(), false);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();

      expect(formCraft.validate(), true);
    });

    testWidgets('Sticky custom error stays when enabled', (WidgetTester tester) async {
      final formCraft = FormCraft();
      const key = 'custom_error_sticky';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return formCraft.buildTextField(
                  key,
                  (controller) => FormCraftTextField(
                    formController: controller,
                    onChanged: (_) {},
                    validators: const [FormCraftValidator.required()],
                    stickyCustomError: true,
                  ),
                );
              },
            ),
          ),
        ),
      );

      formCraft.setErrorMessage(key, 'Server error');
      expect(formCraft.validate(), false);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();

      expect(formCraft.validate(), false);
      formCraft.setErrorMessage(key, null);
      expect(formCraft.validate(), true);
    });

    testWidgets('Unmounted field validation is configurable', (WidgetTester tester) async {
      final strictForm = FormCraft(
        preRegisteredFields: const ['phone'],
        isUnmountedFieldValid: false,
      );
      final permissiveForm = FormCraft(
        preRegisteredFields: const ['phone'],
        isUnmountedFieldValid: true,
      );

      await tester.pumpWidget(const SizedBox.shrink());

      expect(strictForm.validate(), false);
      expect(permissiveForm.validate(), true);
    });

    testWidgets('buildField helper and form-level operations', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                formCraft.buildField(
                  key: 'email',
                  onChanged: (_) {},
                ),
                formCraft.buildField(
                  key: 'password',
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      formCraft.setValue('email', 'first@site.com');
      formCraft.setValues({'password': '123456'});

      expect(formCraft.getValue('email'), 'first@site.com');
      expect(formCraft.getValue('password'), '123456');

      formCraft.clearField('email');
      expect(formCraft.getValue('email'), '');

      formCraft.clearForm();
      expect(formCraft.getValue('password'), '');
    });

    testWidgets('validateDetailed returns errors by key and first invalid', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                formCraft.buildField(
                  key: 'email',
                  onChanged: (_) {},
                  validators: const [
                    FormCraftValidator.required(),
                    FormCraftValidator.email(),
                  ],
                ),
                formCraft.buildField(
                  key: 'password',
                  onChanged: (_) {},
                  validators: const [FormCraftValidator.required()],
                ),
              ],
            ),
          ),
        ),
      );

      formCraft.setValue('email', 'not-email');
      formCraft.setValue('password', '');

      final result = formCraft.validateDetailed();

      expect(result.isValid, false);
      expect(result.firstInvalidKey, isNotNull);
      expect(result.errorsByField.containsKey('email'), true);
      expect(result.errorsByField.containsKey('password'), true);
      expect(formCraft.getErrors().containsKey('email'), true);
    });

    testWidgets('setValidationType applies to future fields', (WidgetTester tester) async {
      final formCraft = FormCraft();
      formCraft.setValidationType(FormCraftValidationType.always);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: formCraft.buildField(
              key: 'name',
              onChanged: (_) {},
              validators: const [FormCraftValidator.required()],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'A');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(formCraft.getError('name'), 'Required field');
    });

    testWidgets('phone mask supports configurable prefix', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: formCraft.buildField(
              key: 'phone',
              onChanged: (_) {},
              mask: PersistentMask.phone(
                maskPattern: '+0 (000) 000-00-00',
                fixedPrefix: '+1 ',
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '+1 5551234567');
      await tester.pumpAndSettle();

      expect(formCraft.getValue('phone').startsWith('+1 '), true);
    });

    testWidgets('registerField returns reusable controller', (WidgetTester tester) async {
      final formCraft = FormCraft();
      final controller = formCraft.registerField('login');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormCraftTextField(
              formController: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      formCraft.setValue('login', 'user');
      expect(formCraft.getValue('login'), 'user');
    });

    testWidgets('FormCraftField widget works as buildField replacement', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormCraftField(
              form: formCraft,
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
            ),
          ),
        ),
      );

      formCraft.setValue('email', 'person@example.com');
      expect(formCraft.validateField('email'), true);
      expect(find.text('person@example.com'), findsOneWidget);
    });

    testWidgets('FormCraftField forwards advanced text field params', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormCraftField(
              form: formCraft,
              fieldKey: 'password',
              onChanged: (_) {},
              obscureText: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              maxLength: 32,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
      expect(textField.textInputAction, TextInputAction.done);
      expect(textField.keyboardType, TextInputType.visiblePassword);
      expect(textField.maxLength, 32);
    });

    testWidgets('FormCraftPasswordField toggles obscure text', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormCraftPasswordField(
              form: formCraft,
              fieldKey: 'password',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, false);
    });

    testWidgets('FormCraftPasswordField has default required and minLength validators', (WidgetTester tester) async {
      final formCraft = FormCraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormCraftPasswordField(
              form: formCraft,
              fieldKey: 'password',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(formCraft.validateField('password'), false);
      expect(formCraft.getError('password'), 'Password is required');

      formCraft.setValue('password', '12345');
      expect(formCraft.validateField('password'), false);
      expect(formCraft.getError('password'), 'Password must be at least 8 characters');

      formCraft.setValue('password', '12345678');
      expect(formCraft.validateField('password'), true);
    });
  });
}
