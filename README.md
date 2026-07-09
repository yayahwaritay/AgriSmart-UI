# AgriSmart

AgriSmart is an open-source Flutter app for detecting plant pests and diseases from a photo. Point your camera at a leaf, get a diagnosis with a confidence score, and follow step-by-step treatment guidance — all backed by a pluggable diagnosis backend so a real model can be dropped in without touching the UI.

## Design system

- **Liquid neumorphism** — soft dual-shadow extruded cards (`NeuCard`), frosted-glass panels (`GlassCard`, built on `BackdropFilter`), and an organic morphing blob viewfinder (`ScanViewfinder`) for the Scan screen.
- **Light / dark themes** driven by a single `ThemeExtension<AgriSmartColors>` (`lib/core/theme/agrismart_colors.dart`), registered on both `ThemeData.light` and `ThemeData.dark`. The user's choice is persisted with `shared_preferences` and defaults to system brightness.
- **Typography** via `google_fonts`: Space Grotesk for display text, Inter for body copy, JetBrains Mono for confidence/data readouts.

## Architecture

Feature-first, clean-architecture-flavored layout:

```
lib/
  main.dart, app.dart            # bootstrap, MaterialApp.router, theme wiring
  core/
    theme/                       # color tokens, ThemeExtension, text theme, persistence
    widgets/                     # NeuCard, GlassCard, buttons, badges, ScanViewfinder, ...
    router/                      # go_router config + bottom-nav shell
    constants/, utils/
  features/
    home/        presentation + application
    scan/        presentation + application + domain + data
    result/      presentation
    history/     presentation + application + domain + data
    profile/     presentation
  services/
    diagnosis_service.dart       # abstract inference interface
    mock_diagnosis_service.dart  # fake implementation used today
```

Each feature keeps UI (`presentation/`), Riverpod state (`application/`), and — where it owns real business logic (`scan`, `history`) — a `domain/` (entities + repository interfaces) and `data/` (repository implementations) layer.

State management is [Riverpod](https://riverpod.dev), with providers scoped per feature rather than one global store. Navigation is [go_router](https://pub.dev/packages/go_router), with Home/Scan/History/Profile as bottom-nav tabs inside a `StatefulShellRoute` and Result pushed full-screen on top.

## Getting started

```bash
flutter pub get
flutter run
```

Camera capture uses `image_picker`, which needs a real device or simulator with camera/photo-library access. Android and iOS permission entries are already declared in `AndroidManifest.xml` / `Info.plist`.

Run the analyzer and tests before sending a PR:

```bash
flutter analyze
flutter test
```

## Swapping in a real diagnosis backend

Every diagnosis today comes from `MockDiagnosisService` (`lib/services/mock_diagnosis_service.dart`), which returns one of a few canned results after a simulated delay. To wire up a real model or hosted API:

1. Create a new class implementing `DiagnosisService` (`lib/services/diagnosis_service.dart`):
   ```dart
   class TFLiteDiagnosisService implements DiagnosisService {
     @override
     Future<DiagnosisResult> diagnose(File image) async {
       // run inference, map the output to a DiagnosisResult
     }
   }
   ```
2. Point `diagnosisServiceProvider` at it in `lib/features/scan/application/scan_providers.dart`:
   ```dart
   final diagnosisServiceProvider = Provider<DiagnosisService>((ref) {
     return TFLiteDiagnosisService();
   });
   ```

That's it — no changes needed anywhere in `features/scan`, `features/result`, or `features/history`; they all depend on the `DiagnosisService`/`DiagnosisRepository` abstractions, not the mock.

## Contributing

Contributions are welcome!

- Open an issue before starting significant work so we can align on approach.
- Keep PRs focused — one feature or fix per PR.
- Run `flutter analyze` and `flutter test` locally; both must be clean.
- Match the existing feature-first structure and design-system widgets (`core/widgets`) rather than one-off styling.
- Explain the *why* in your PR description, not just the *what*.

## License

MIT — see [LICENSE](LICENSE).
