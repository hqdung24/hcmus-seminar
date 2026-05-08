# Drawing App — HCMUS Seminar

Cross-platform basic drawing application for **Windows desktop** and **Android**, built in Flutter for the Windows Programming course seminar at HCMUS.

---

## Group members

| # | Họ và tên | MSSV |
|---|-----------|------|
| 1 | Huỳnh Quốc Dũng | 22127077 |
| 2 | Nguyễn Thiên Đức | 22127072 |
| 3 | Trần Phan Thiên Bửu | 22127039 |

---

## Demo video

🎥 **[Watch on YouTube (Unlisted)](TODO-INSERT-YOUTUBE-LINK-AFTER-UPLOAD)**

The video shows the application running on Windows desktop and on a physical Android device, demonstrating every feature listed below.

---

## Implemented features

Mapping to the seminar requirements:

| #   | Requirement                                                                  | Status |
| --- | ---------------------------------------------------------------------------- | ------ |
| 1   | Vẽ điểm, đường thẳng, hình ellipse, hình tròn, hình vuông, hình chữ nhật     | ✅     |
| 2   | Tô màu (fill color picker + on/off toggle)                                   | ✅     |
| 3   | Độ dày + màu đường viền (stroke width slider 1–20px + stroke color picker)   | ✅     |
| 4   | Lưu / nạp định dạng nhị phân tự định nghĩa (`.draw`)                          | ✅     |
| 5   | Xuất ảnh PNG                                                                 | ✅     |

Additional features implemented beyond the spec:

- **Eraser tool** — tap-to-erase or drag-to-erase, with a visible 10px hit-zone indicator that follows the cursor / finger
- **Per-shape geometry-aware hit-testing** — eraser only triggers on the actual visible shape, not its bounding box (e.g. clicking inside a hollow rectangle does not erase it)
- **Live drag preview** — shapes update in real time as the user drags, before the gesture ends
- **High-DPI PNG export** — captured at 2× pixel ratio for sharpness on retina-class displays
- **Adaptive toolbar** — two scrollable rows (tools + style controls) that work on phone and desktop screen sizes

---

## Technology

**Flutter (Dart).** Chosen because it differs from the course's main project stack (WinUI) — satisfying the seminar's "khác công nghệ mà đồ án đã sử dụng" constraint — and supports both Windows desktop and Android from a single codebase.

**No third-party drawing or canvas library.** All shape rendering, hit-testing, and binary serialization are implemented directly on Flutter's built-in `CustomPainter` / `Canvas` API and pure Dart.

Runtime dependencies (see [`pubspec.yaml`](pubspec.yaml)):

- `cupertino_icons` — Material/Cupertino icon set
- `path_provider` — cross-platform filesystem paths
- `file_picker` — cross-platform save / open dialogs (Win32 dialog on desktop, Storage Access Framework on Android)

---

## How to run

### Prerequisites

- Flutter 3.10 or newer
- Windows: Visual Studio 2022 with the "Desktop development with C++" workload
- Android: Android SDK 33+, Android NDK, a connected device or running emulator (arm64 / armv7)

### Commands

```powershell
flutter pub get

# Windows desktop
flutter run -d windows

# Android — list devices first to find the ID
flutter devices
flutter run -d <device-id>
```

---

## Project structure

```text
lib/
├── main.dart, app.dart           # entry point + MaterialApp
├── models/
│   ├── shape.dart                # Shape (abstract), ShapeType, distance helpers
│   ├── shape_style.dart          # ShapeStyle value object
│   └── shapes/                   # 6 concrete shape classes
├── state/
│   └── canvas_controller.dart    # ChangeNotifier + DrawingTool enum
├── painter/
│   └── canvas_painter.dart       # CustomPainter
├── serialization/
│   ├── binary_writer.dart        # uint8 / uint32 / float32 / bool writers
│   ├── binary_reader.dart        # mirror reader
│   └── shape_codec.dart          # encodeAll / decodeAll
├── services/
│   ├── file_service.dart         # save / load .draw via file_picker
│   └── export_service.dart       # PNG export via RepaintBoundary
└── ui/
    ├── pages/canvas_page.dart    # Scaffold, AppBar, layout
    └── widgets/                  # canvas, toolbar, color picker, slider
```

---

## Documentation

Detailed project documentation is in [`docs/`](docs/):

- [overview.md](docs/overview.md) — scope, requirements mapping, submission checklist
- [features.md](docs/features.md) — every feature with usage and implementation pointers
- [architecture.md](docs/architecture.md) — layered architecture and design decisions
- [modules.md](docs/modules.md) — file-by-file API reference
- [binary-format.md](docs/binary-format.md) — `.draw` file specification
- [roadmap-7-days.md](docs/roadmap-7-days.md) — initial implementation roadmap

---

## Timeline & contribution

The project was developed over **two weeks** in two phases, with work split equally across the three members.

### Phase 1 — Week 1 (foundations)

- Project scaffolding, architecture design, and Flutter setup
- `Shape` abstract class + 6 concrete shapes
- `CanvasController` state management
- `CanvasPainter` rendering
- Binary file format design ([docs/binary-format.md](docs/binary-format.md))
- Initial UI (canvas page + draft toolbar)

### Phase 2 — Week 2 (features & cross-platform polish)

- Toolbar with stroke / fill / width controls (two-row card layout)
- Custom binary format encoder & decoder
- Save / load roundtrip via `file_picker`
- PNG and JPEG export via `RepaintBoundary.toImage` + `image` package
- Eraser tool with shape-aware hit-testing and visible hit-zone indicator
- Paint-bucket tool — click any drawn shape to fill it with the current colour
- Windows desktop runner and Android build configuration (ABI filtering for arm64 / armv7)
- Mobile-specific UX: hide indicator on touch lift, file-picker fallback for custom extensions
- Graceful error dialog for invalid `.draw` files
- Demo video recording, README, documentation

Each member contributed across both phases; tasks were rotated weekly to share knowledge of all layers.

---

## Submission notes

- Source code submitted as a `.zip` archive (no GitHub link).
- Demo video uploaded as **Unlisted** on YouTube; only graders with the link can access it.
- Tested on Windows 11 and Android 11 (Xiaomi M2012K11AC).

---

## Future improvements

Beyond the current seminar requirements, several features could extend the application:

- **Free-hand drawing** — continuous stroke drawing in addition to geometric shapes
- **Undo / redo** — action stack to revert and reapply changes
- **Object manipulation** — select, move, resize, and delete shapes after drawing
- **Layer management** — layered canvas with separate background / foreground groups
- **Additional platforms** — testing and deployment to Web and macOS using Flutter's multi-platform support
