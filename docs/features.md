# Features

End-user feature reference. Each section describes what a feature does, how to use it, and where it lives in the codebase.

---

## 1. Drawing 6 shape primitives

The app supports six geometric primitives, all drawn by **drag** (mouse on Windows, touch on Android), except `Point` which is committed on **tap**.

| Tool | Gesture | What's stored |
| --- | --- | --- |
| Point | Tap | `start = end = tap position` |
| Line | Drag | `start → end` |
| Rectangle | Drag | Axis-aligned rect from `start` to `end` |
| Square | Drag | Constrained: side = `max(|dx|, |dy|)` |
| Circle | Drag | `start` is the center, `end` is on the circumference |
| Ellipse | Drag | Axis-aligned, fitted into the rect from `start` to `end` |

**How to use**: select a tool from the toolbar's top row, then draw on the canvas.

**Implementation**:

- Tool selection — `lib/ui/widgets/toolbar.dart` writes to `CanvasController.tool`
- Gesture capture — `lib/ui/widgets/drawing_canvas.dart` (GestureDetector → `controller.startDrawing/updateDrawing/endDrawing`)
- Shape creation per tool — `CanvasController._createShape` switch in `lib/state/canvas_controller.dart`
- Per-shape rendering — `lib/models/shapes/*.dart` (each overrides `Shape.draw(Canvas)`)
- Live preview during drag — `CanvasPainter` paints `controller.draftShape` on top of committed shapes

---

## 2. Stroke color, fill color, fill toggle, stroke width

The bottom toolbar row holds four style controls; changes apply to **the next shape drawn**, not retroactively to existing shapes.

| Control | Range / values |
| --- | --- |
| Stroke color | 8 swatches (black, red, green, blue, orange, purple, yellow, white) |
| Fill color | Same 8 swatches |
| Fill on/off | Material `Switch`. Off = stroke only; On = filled with the picked fill color |
| Stroke width | Slider 1–20 px (integer steps) |

**How to use**: tap a swatch / flip the switch / drag the slider before drawing. Selected swatches are highlighted with a thick blue border.

**Implementation**:

- Style data — `lib/models/shape_style.dart` (`ShapeStyle` value object with `copyWith`, `strokePaint`, `fillPaint`)
- Pickers — `lib/ui/widgets/color_swatch_picker.dart` (`SwatchTarget.stroke` vs `SwatchTarget.fill`)
- Slider — `lib/ui/widgets/stroke_width_slider.dart`
- All controls call `CanvasController.setStyle()`, which notifies listeners and updates the toolbar's selection borders

Filled rendering is handled per shape in `draw()`: each shape calls `style.fillPaint` first (returns `null` when `filled = false`, so the fill is skipped), then `style.strokePaint` for the outline.

---

## 3. Eraser

A non-destructive tool that removes the **topmost shape** under the cursor on tap or drag.

**How to use**: select the broom icon (last item in the tool row). Cursor is replaced by a translucent red 10-px circle showing the hit zone. Tap or drag over a shape to remove it.

**Behaviour**:

- Iterates shapes from newest to oldest, removes the first one whose geometry is within the eraser's reach.
- Hit-testing is **shape-aware**, not bounding-box based:
  - Point — distance from cursor to the point
  - Line — distance from cursor to the line segment (not its bbox)
  - Rectangle / Square — if filled, anywhere inside; if outlined, near the border only
  - Circle / Ellipse — same logic, using the shape's actual geometry
- Tolerance: 10 px + half the shape's stroke width.

**Implementation**:

- `DrawingTool.eraser` — added to the enum in `lib/state/canvas_controller.dart`
- `CanvasController.eraseAt(Offset)` — back-iterates `_shapes` and removes the first hit
- `Shape.hitTest(Offset, {tolerance})` — abstract method overridden per shape (see `lib/models/shapes/*.dart`)
- Shared rect-border distance helper — `Shape.distanceToRectBorder` in `lib/models/shape.dart`
- Visual hit indicator — rendered as a `Positioned` widget **outside** the `RepaintBoundary` in `lib/ui/widgets/drawing_canvas.dart`, so it never appears in PNG exports
- System cursor is hidden via `MouseRegion(cursor: SystemMouseCursors.none)` while eraser is active

---

## 4. Save / load custom binary format

Drawings are persisted in a custom `.draw` binary format and can be reloaded later to continue editing.

**How to use**:

- Save — AppBar `💾` icon → file dialog → choose location → writes `.draw`
- Load — AppBar `📂` icon → file dialog → pick `.draw` → canvas is replaced by the loaded shapes

**Format**: see [binary-format.md](binary-format.md). 9-byte header + 30 bytes per shape, all little-endian.

**Implementation**:

- Format spec & codec — `lib/serialization/shape_codec.dart` (`encodeAll` / `decodeAll`)
- Low-level byte IO — `lib/serialization/binary_writer.dart` and `binary_reader.dart` (pure Dart, no Flutter imports → unit-testable)
- File dialog + disk IO — `lib/services/file_service.dart` (uses `file_picker`)
- AppBar wiring — `lib/ui/pages/canvas_page.dart` (`_save` / `_load` methods)

The serialization layer is Flutter-free on purpose — all Flutter types (`Offset`, `Color`) are unpacked into raw doubles / uint32 before writing.

---

## 5. PNG export

Renders the current canvas to a PNG image and lets the user save it.

**How to use**: AppBar `🖼️` icon → save dialog → choose location → writes `.png`.

**Behaviour**:

- Captures the canvas at `pixelRatio: 2.0` (so the export is twice the on-screen resolution → sharp on hi-DPI displays)
- White background is included (painted by `CanvasPainter` before any shapes)
- The eraser hit indicator is **not** captured (it's rendered outside the `RepaintBoundary`)

**Implementation**:

- `lib/services/export_service.dart` — `exportPng(GlobalKey)` → `boundary.toImage()` → `toByteData(ImageByteFormat.png)` → file write
- `RepaintBoundary` with `_repaintKey` — declared in `lib/ui/widgets/drawing_canvas.dart`, key created in `_CanvasPageState`

---

## 6. Clear canvas

Removes every shape from the canvas.

**How to use**: AppBar 🗑️ icon → all shapes are deleted immediately (no confirmation).

**Implementation**: `CanvasController.clear()` in `lib/state/canvas_controller.dart`.

---

## Cross-platform behaviour

The same code runs on Windows desktop and Android mobile. Differences are abstracted in two places:

| Concern | Desktop | Mobile |
| --- | --- | --- |
| Pointer input | Mouse pan / hover via `GestureDetector` + `MouseRegion` | Touch pan via `GestureDetector` (hover unsupported) |
| File dialog | Win32 dialog returns a path; we write bytes via `dart:io` | `file_picker.saveFile(bytes:)` writes through Storage Access Framework |
| Cursor | System cursor hidden during eraser | No cursor concept; eraser indicator follows the touch point |

Both branches live in `FileService` and `DrawingCanvas` and are guarded by `Platform.isAndroid / isIOS`.
