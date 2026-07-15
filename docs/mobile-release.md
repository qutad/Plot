# Mobile release

Plot uses the same Flutter application and local Drift database on Android and
iOS. Data remains local to each installation in the first mobile release.

## Verification

Run before creating release artifacts:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

An iOS build requires macOS and Xcode:

```bash
flutter build ios --release --no-codesign
flutter build ipa --release
```

CI performs Android debug/release builds and an unsigned iOS release build.

## Android signing

Confirm that `app.plot.plot` is the permanent Play Store application ID before
publishing. Create an upload keystore outside version control, then create
`android/key.properties` with:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=<alias>
storeFile=<absolute-or-android-relative-keystore-path>
```

`android/key.properties` and keystore files are ignored by Git. When the file is
present, Gradle signs release artifacts with it. Without it, release builds use
debug signing only so CI can validate compilation; those artifacts must not be
uploaded to Google Play.

## iOS signing

Confirm that `app.plot.plot` is owned by the intended Apple Developer account.
Open `ios/Runner.xcworkspace` in Xcode, select the distribution team, configure
the App Store provisioning profile, and archive the Runner target. Keep signing
certificates and provisioning profiles out of the repository.

## Store checklist

- Replace template launcher icons and verify adaptive Android icon assets.
- Capture phone and tablet screenshots.
- Publish a privacy policy describing local-only habit data.
- Confirm version and build numbers in `pubspec.yaml`.
- Test the signed Android bundle through Play internal testing.
- Test the signed iOS archive through TestFlight.
- Verify database persistence after updating from an older build.
