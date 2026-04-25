# Example

This app demonstrates the package in a single screen:

- switch between `DROPDOWN`, `BOTTOM_SHEET`, and `DIALOG`
- toggle formatting, prefix mode, blank handling, and length checks
- validate, clear, and save the current number
- inspect the parsed phone number state as you type

## Run

```bash
flutter run -d <device>
```

The app currently calls `MetadataFinder.readMetadataJson(...)` during startup because the package depends on `phone_parser` metadata for formatting and validation.
