## 0.1.0

- Added form-level operations: `setValue`, `setValues`, `getValue`, `clearField`, `clearForm`, `validateField`, `getError`, `getErrors`.
- Added simplified field registration and building: `registerField`, `getController`, `buildField`.
- Added `validateDetailed()` with `FormCraftValidationResult` (`isValid`, `errorsByField`, `firstInvalidKey`).
- Improved validation lifecycle: `setValidationType` now applies to mounted and future fields.
- Added configurable phone mask prefix via `PersistentMask.phone(fixedPrefix: ...)`.
- Reworked README to a concise quickstart + cookbook format.
- Added edge-case tests for the new API and validation/mask behavior.
- Fixed a `RangeError` risk in `MaskedPhoneInputFormatter` separator cleanup.

### Migration Notes

- If you configured phone masks, you can now provide a country prefix explicitly:
	`PersistentMask.phone(maskPattern: ..., fixedPrefix: '+1 ')`.
- Prefer `validateDetailed()` when you need field-level errors in UI.
- Existing `validate()` behavior remains backward compatible and continues returning `bool`.

## 0.0.1

- Initial release.
