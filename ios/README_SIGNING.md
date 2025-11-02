# iOS Signing (Mac only)

- Requires Apple Developer account (paid).
- Open `ios/Runner.xcworkspace` in Xcode, set your Team, fix signing.
- Do NOT commit certificates or provisioning profiles.
- Local build (unsigned):
  ```bash
  flutter build ipa --no-codesign
  ```

## Note
iOS builds require a Mac with Xcode installed. The `.gitignore` already excludes certificates and provisioning profiles.

