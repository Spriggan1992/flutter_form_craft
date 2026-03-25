import 'package:flutter/material.dart';
import 'package:flutter_form_craft/form_craft.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleFormScreen(),
    );
  }
}

class ExampleFormScreen extends StatefulWidget {
  const ExampleFormScreen({super.key});

  @override
  State<ExampleFormScreen> createState() => _ExampleFormScreenState();
}

class _ExampleFormScreenState extends State<ExampleFormScreen> {
  late final FormCraft _form;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _form = FormCraft(
      validationType: FormCraftValidationType.onSubmit,
      preRegisteredFields: const ['email', 'phone'],
    );

    _form.setValues(
      {
        'email': 'john@doe.com',
      },
      ignoreMissingKeys: true,
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit() {
    final validation = _form.validateDetailed();

    if (!validation.isValid) {
      setState(() {
        _result = 'Invalid: ${validation.errorsByField}';
      });
      if (validation.firstInvalidKey != null) {
        _form.getFocusNode(validation.firstInvalidKey!).requestFocus();
      }
      return;
    }

    final payload = _form.submitForm();
    setState(() {
      _result = 'Submit payload: $payload';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormCraft Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FormCraftField(
              form: _form,
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
            const SizedBox(height: 12),
            FormCraftField(
              form: _form,
              fieldKey: 'phone',
              onChanged: (_) {},
              validators: const [FormCraftValidator.required()],
              mask: PersistentMask.phone(
                maskPattern: '+0 (000) 000-00-00',
                fixedPrefix: '+1 ',
              ),
              decorationBuilder: (error) => InputDecoration(
                labelText: 'Phone',
                errorText: error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Validate & Submit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _form.clearForm();
                      setState(() {
                        _result = 'Form cleared';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
