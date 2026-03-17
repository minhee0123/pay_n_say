# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run app (auto-selects device)
flutter test                 # Run tests
flutter analyze              # Static analysis (uses flutter_lints)
flutter build apk            # Android build
flutter build ios            # iOS build
```

## Architecture

Feature-based structure using **Riverpod** for state and **GoRouter** for routing.

```
lib/
├── main.dart                          # ProviderScope + MaterialApp.router
├── core/
│   ├── router/app_router.dart         # GoRouter (5 routes)
│   └── theme/app_theme.dart           # Material 3, Neo-Minimal Fintech theme
└── features/
    ├── ledger/                        # 가계부 (main feature)
    │   ├── domain/models/             # Transaction model, enums
    │   └── presentation/
    │       ├── pages/                 # ledger_main, day_detail, manual_entry
    │       └── providers/             # StateNotifierProvider + family providers
    ├── ocr/                           # 영수증 스캔 (image_picker, no OCR engine yet)
    └── english_learning/              # 영어 학습 (placeholder)
```

## Key Patterns

**State management** — Riverpod with `StateNotifierProvider` for mutable state, `Provider.family` for derived/filtered state. Widgets extend `ConsumerWidget` or `ConsumerStatefulWidget`. No persistence layer yet (in-memory only).

**Routing** — GoRouter with `context.push('/path', extra: data)` for navigation. Routes: `/` (ledger main), `/add`, `/edit`, `/day/:date`, `/ocr`.

**Theme** — Use `AppColors` for semantic colors (accent, income, expense) and `AppTheme` for shared decorations (cardShadow, headerGradient). Material 3 enabled.

## Conventions

- UI language is Korean; currency is KRW (₩)
- Dart SDK >=3.0.6 <4.0.0
- Package ID: `com.mini.pay_n_say`
- iOS permissions configured for camera, photo library, microphone
