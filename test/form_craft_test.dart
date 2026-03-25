library form_craft_test;

import 'package:flutter/material.dart';
import 'package:flutter_form_craft/src/form_craft.dart';
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
  });
}
