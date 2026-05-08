# Project Overview

## Context

HCMUS seminar assignment: build a basic cross-platform drawing app that runs on **Windows desktop** and **Mobile** (Android or iOS — only one mobile platform required).

Frontend-only. No backend, no networking, no accounts.

---

## Scope

| In scope | Out of scope |
|---|---|
| Drawing 6 shape types | Selecting / moving / resizing / deleting existing shapes |
| Stroke color, fill color, stroke width | Undo / redo |
| Save & reload custom `.draw` binary file | Layers |
| Export canvas to PNG and JPEG | Text annotation, freehand smoothing, curves |
| Windows + Android targets | iOS, Web, Linux, macOS |
| Local-only storage | Cloud sync, accounts, multi-user |

---

## Functional requirements

Mapped 1-to-1 to the seminar spec:

| # | Requirement (verbatim) | How it's covered |
|---|---|---|
| 1 | Hỗ trợ vẽ các đối tượng cơ bản (điểm, đường thẳng, hình ellipse, hình tròn, hình vuông, hình chữ nhật) | 6 `Shape` subclasses: `PointShape`, `LineShape`, `EllipseShape`, `CircleShape`, `SquareShape`, `RectangleShape`. Rendered via `CustomPainter`. |
| 2 | Hỗ trợ tô màu | `ShapeStyle.fillColor` + `filled` flag. Toolbar fill-color picker + fill toggle. |
| 3 | Hỗ trợ xác định độ dày đường viền, màu đường viền | `ShapeStyle.strokeWidth` + `strokeColor`. Toolbar stroke-width slider + stroke-color picker. |
| 4 | Có thể lưu ở dạng nhị phân tự định nghĩa và nạp lại để vẽ tiếp | Custom `.draw` format — see [binary-format.md](binary-format.md). Save/load via `file_picker`. |
| 5 | Có thể xuất ra ảnh jpeg hoặc png | `RepaintBoundary.toImage()` → PNG via `dart:ui`. JPEG via `image` package. |

---

## Non-functional requirements

- **Cross-platform parity**: same UX and feature set on Windows and Android.
- **Performance**: smooth drawing with up to ~500 shapes on a mid-range device. `RepaintBoundary` isolates the canvas from the rest of the UI.
- **Testability**: serialization layer is pure Dart (no Flutter imports) so it's unit-testable without a device.
- **File-format stability**: `version` byte in the header allows future evolution without breaking old files.

---

## Technology choice

**Flutter** — single codebase for Windows + Android, strong `CustomPainter` for canvas work, pure-Dart serialization is easy to unit-test.

The seminar spec (`Phải chọn khác công nghệ mà đồ án đã sử dụng`) requires the platform to differ from the **course's main project**, which uses **WinUI**. Flutter is one of the 5 allowed alternatives (MAUI, Uno, KMP, React Native, Flutter) and satisfies this constraint.

---

## Deliverables (seminar submission checklist)

- [ ] **Source code** — submitted as GitHub link with a Personal Access Token
  - [ ] Token is **read-only**
  - [ ] Token expiry set to **2026-01-30**
- [ ] **`README.md`** at the repo root containing:
  - [ ] Group member info (name, student ID, role)
  - [ ] List of implemented features
  - [ ] Demo video link
- [ ] **Demo video**
  - [ ] Length ≤ 5 minutes
  - [ ] Shows the app running on **desktop (Windows)** AND **mobile (Android or iOS — pick one)**
  - [ ] No voiceover, no background music
  - [ ] Explanations typed in Notepad on-screen
  - [ ] YouTube visibility set to **Unlisted**

---

## Related documents

- [architecture.md](architecture.md) — layered architecture, design decisions
- [binary-format.md](binary-format.md) — `.draw` file specification
- [roadmap-7-days.md](roadmap-7-days.md) — 3-developer parallel work plan
