# Claude Dev Session Summary

**Date**: 2026-05-03
**Project**: Cross-platform Flutter drawing application (Windows + Android)
**Repo**: https://github.com/hqdung24/hcmus-seminar

---

## What was done

### 1. Architecture design

Designed a clean, layered architecture for the drawing app:

```
UI Layer       (lib/ui/)             — pages, widgets
   ↓
State Layer    (lib/state/)          — CanvasController (ChangeNotifier)
   ↓
Painter Layer  (lib/painter/)        — CustomPainter
   ↓
Models         (lib/models/)         — Shape (abstract) + 6 concrete + Style

Cross-cutting:
- Services         (lib/services/)        — FileService, ExportService
- Serialization    (lib/serialization/)   — BinaryWriter, BinaryReader, ShapeCodec
```

**Key design decisions:**
- Shape as polymorphic base class — adding a new shape = one new file
- Two-point representation `(start, end)` for all shapes — uniform serialization
- `ChangeNotifier` for state (no extra packages)
- `CustomPainter` with `repaint: controller` — automatic invalidation
- `RepaintBoundary` for performance + PNG export
- Pure-Dart serialization (no Flutter imports) — fully unit-testable

Full doc: [`docs/architecture.md`](../docs/architecture.md)

---

### 2. Skeleton implementation

**Models (8 files):**
- `lib/models/shape.dart` — abstract Shape, ShapeType enum with stable codes
- `lib/models/shape_style.dart` — ShapeStyle (stroke/fill color, stroke width, filled flag)
- `lib/models/shapes/point_shape.dart`
- `lib/models/shapes/line_shape.dart`
- `lib/models/shapes/rectangle_shape.dart`
- `lib/models/shapes/square_shape.dart`
- `lib/models/shapes/circle_shape.dart`
- `lib/models/shapes/ellipse_shape.dart`

**State:**
- `lib/state/canvas_controller.dart` — draw lifecycle (start/update/end), tool selection, style updates, clear, loadShapes

**Painter:**
- `lib/painter/canvas_painter.dart` — renders committed shapes + draft, hooks `repaint: controller`

**UI:**
- `lib/main.dart`, `lib/app.dart` — app entry
- `lib/ui/pages/canvas_page.dart` — Scaffold with app bar (load/save/export/clear)
- `lib/ui/widgets/drawing_canvas.dart` — unified gesture handling (touch + mouse)
- `lib/ui/widgets/toolbar.dart` — shape tool buttons + color picker + stroke slider
- `lib/ui/widgets/color_swatch_picker.dart`
- `lib/ui/widgets/stroke_width_slider.dart`

**Serialization (pure Dart):**
- `lib/serialization/binary_writer.dart` — uint8/32, float32, bool writers (little-endian)
- `lib/serialization/binary_reader.dart` — mirror reader
- `lib/serialization/shape_codec.dart` — `encodeAll` / `decodeAll`

**Services:**
- `lib/services/file_service.dart` — save/load via `file_picker` (cross-platform)
- `lib/services/export_service.dart` — PNG export via `RepaintBoundary.toImage()`

**Tests:**
- `test/shapes/shape_codec_test.dart` — encode-then-decode roundtrip

---

### 3. Binary file format design

Designed a simple `.draw` format:

**Header (9 bytes):**
- `magic` (4B) = `"DRAW"` (0x44524157)
- `version` (1B) = 1
- `shapeCount` (4B) = uint32

**Per shape (30 bytes, fixed):**
- `typeCode` (1B) — 1=point, 2=line, 3=rect, 4=square, 5=circle, 6=ellipse
- `startX, startY, endX, endY` (4×4B) — float32
- `strokeColor, fillColor` (2×4B) — ARGB packed uint32
- `strokeWidth` (4B) — float32
- `filled` (1B) — bool

100 shapes ≈ 3 KB. All little-endian.

Full spec: [`docs/binary-format.md`](../docs/binary-format.md)

---

### 4. 7-day team roadmap

3 developers, parallel work, daily commits.

| Module | Owner |
|--------|-------|
| Drawing Engine + Shape Models | Dev A |
| Serialization + File Handling | Dev B |
| UI Layer | Dev C |

| Day | Critical milestone |
|-----|---------------------|
| 1 | Project structure agreed, all 3 devs branch off |
| 2 | Shape models + Codec + Toolbar UI in parallel |
| **3** | **Drawing actually works** (critical integration day) |
| 4 | Save / load / PNG export round-trip |
| 5 | Cross-platform fixes + bug bash |
| 6 | JPEG export, fill toggle, edge cases |
| 7 | Demo videos + README + tag v1.0.0 |

Includes commit strategy, integration points, risk management, fallback plan.

Full plan: [`docs/roadmap-7-days.md`](../docs/roadmap-7-days.md)

---

### 5. Repo setup

- Initialized git on `main` branch
- Added `.gitignore` for Flutter projects
- Connected to GitHub: `https://github.com/hqdung24/hcmus-seminar.git`
- Pushed 2 commits:
  1. `chore: initial project setup with docs and pubspec` — docs + setup files
  2. `feat: bootstrap drawing app skeleton` — full lib/ + test/ skeleton

---

## File inventory

```
hcmus-seminar/
├── .gitignore
├── README.md
├── pubspec.yaml                              # path_provider + file_picker deps
├── lib/                                      # 16 files
│   ├── main.dart
│   ├── app.dart
│   ├── models/                               # 8 files (base + 6 shapes + style)
│   ├── state/canvas_controller.dart
│   ├── painter/canvas_painter.dart
│   ├── serialization/                        # 3 files
│   ├── services/                             # 2 files
│   └── ui/                                   # 5 files
├── test/shapes/shape_codec_test.dart
├── docs/
│   ├── architecture.md
│   ├── binary-format.md
│   └── roadmap-7-days.md
└── claude-dev/
    └── summary.md (this file)
```

---

## What's NOT done (handed off to team)

1. **`flutter create .`** — platform folders (`android/`, `windows/`, `ios/`) not yet generated
2. **`flutter pub get`** — dependencies not installed
3. **Compilation verification** — possible API mismatches with current Flutter:
   - `Color.value` is deprecated in newer Flutter versions
   - `file_picker.saveFile()` signature varies by version
4. **JPEG export** — currently PNG-only (needs `image` package)
5. **Tests for binary primitives** — only roundtrip test exists, not unit tests for `BinaryWriter`/`BinaryReader`
6. **Platform-specific testing** — nothing actually run on Windows or Android yet

---

## Update: 2026-05-07

**Tasks Completed in Latest Session:**
1. **Windows Platform Support:** Ran `flutter create --platforms=windows .` to generate the Windows runner, enabling desktop testing and execution.
2. **Dependencies:** Ran `flutter pub get` successfully.
3. **JPEG Export:** Implemented full JPEG export functionality in `ExportService` by integrating the `image` package to correctly encode raw byte data to JPEG.
4. **Git Commit:** Committed the Windows platform setup and JPEG export features.
5. **README Update:** Added a "Future Improvements" section to the `README.md`.

**Remaining Items / Technical Debt:**
1. **Compilation Warnings:** `flutter analyze` currently reports some `info` warnings related to `Color.value` deprecation in `shape_codec.dart` and `shape_codec_test.dart` (suggesting `toARGB32()`), as well as some unnecessary imports. These are not breaking the build but should be cleaned up.
2. **Platform-specific testing:** Still need to run and verify on an Android device/emulator.

---

## Notes for future AI sessions

- The bootstrap **intentionally compresses Day 1-3 of the roadmap** into the initial commit, since the team will likely refactor anyway. If strict day-by-day commits are needed, the team can split this into smaller PRs.
- Serialization layer is **Flutter-free** — when running tests, can be unit-tested without `flutter_test`.
- `CanvasController` uses plain `ChangeNotifier`. If the app grows to multiple screens with shared state, swap in Riverpod with minimal changes.
- Binary format has a `version` byte for future evolution — bump it before adding fields.
