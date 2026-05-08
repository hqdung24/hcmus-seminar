# Module Reference

File-by-file walkthrough of `lib/`. Use this to navigate the codebase. Public API of each type is summarized; private members are noted only when they're load-bearing.

```
lib/
├── main.dart                          # entry point
├── app.dart                           # MaterialApp + theme
├── models/
│   ├── shape.dart                     # abstract Shape, ShapeType, distance helpers
│   ├── shape_style.dart               # ShapeStyle value object
│   └── shapes/
│       ├── point_shape.dart
│       ├── line_shape.dart
│       ├── rectangle_shape.dart
│       ├── square_shape.dart
│       ├── circle_shape.dart
│       └── ellipse_shape.dart
├── state/
│   └── canvas_controller.dart         # ChangeNotifier + DrawingTool enum
├── painter/
│   └── canvas_painter.dart            # CustomPainter
├── serialization/
│   ├── binary_writer.dart             # uint8/32, float32, bool writers
│   ├── binary_reader.dart             # mirror reader
│   └── shape_codec.dart               # encodeAll / decodeAll
├── services/
│   ├── file_service.dart              # save / load .draw via file_picker
│   └── export_service.dart            # PNG export via RepaintBoundary
└── ui/
    ├── pages/
    │   └── canvas_page.dart           # Scaffold, AppBar wiring
    └── widgets/
        ├── drawing_canvas.dart        # gestures + canvas + eraser indicator
        ├── toolbar.dart               # tool row + style row
        ├── color_swatch_picker.dart   # 8-swatch color row (stroke or fill)
        └── stroke_width_slider.dart   # 1–20 slider
```

---

## `lib/main.dart` & `lib/app.dart`

Standard Flutter entry. `main()` runs `DrawingApp`, which is a `MaterialApp` with `useMaterial3: true`, the debug banner disabled, and `CanvasPage` as `home`.

---

## `lib/models/shape.dart`

The polymorphic root for everything drawable.

```dart
enum ShapeType {                          // stable codes for the .draw format
  point(1), line(2), rectangle(3),
  square(4), circle(5), ellipse(6);
}

abstract class Shape {
  final Offset start;
  final Offset end;
  final ShapeStyle style;

  ShapeType get type;                     // used by codec
  void draw(Canvas canvas);               // paint to a Flutter canvas
  Shape withEnd(Offset newEnd);           // immutable copy used during drag
  Rect get bounds;                        // axis-aligned bbox
  bool hitTest(Offset point, {double tolerance = 10.0});
  static double distanceToRectBorder(Offset p, Rect r); // shared helper
}
```

**Why it's shaped this way**

- One file per concrete shape — adding a new shape is local
- Uniform `(start, end)` for all shapes — drag-to-draw and serialization stay simple
- `bounds` and `hitTest` are separate so shapes can override only one (default `hitTest` falls back to bbox)

---

## `lib/models/shape_style.dart`

Immutable value object for stroke / fill / width.

```dart
class ShapeStyle {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final bool filled;

  ShapeStyle copyWith({...});             // for incremental updates
  Paint get strokePaint;                  // builds a stroke Paint
  Paint? get fillPaint;                   // null when !filled — shapes use this to skip fill rendering
}
```

The `null` return from `fillPaint` is load-bearing: shape `draw()` methods do `if (fill != null) canvas.drawX(rect, fill);` to skip filling without an extra flag check.

---

## `lib/models/shapes/*.dart`

Each concrete shape:

1. Overrides `draw()` to render itself
2. Overrides `bounds` for the (now-fallback) bbox-based hit test
3. Overrides `hitTest()` with shape-specific geometry (so the eraser only triggers on the actual visible shape, not its bbox)

| Shape | `draw()` summary | `hitTest` math |
| --- | --- | --- |
| Point | `drawCircle` of radius `strokeWidth / 2` | distance to `start` |
| Line | `drawLine(start, end)` | distance from cursor to segment |
| Rectangle | `drawRect(Rect.fromPoints(start, end))` | filled: inside; outlined: distance to border |
| Square | Same as rect, but side = `max(|dx|, |dy|)` (private `_rect()`) | same as rectangle on the constrained rect |
| Circle | `drawCircle(start, radius)` where `radius = (end - start).distance` | filled: inside disc; outlined: `(dist - radius).abs()` ≤ tolerance |
| Ellipse | `drawOval(Rect.fromPoints(start, end))` | normalized ellipse equation: `(nx² + ny² - 1)` ≤ tolerance / scale |

---

## `lib/state/canvas_controller.dart`

Single source of truth for the canvas. `ChangeNotifier`, listened to by the painter and toolbar.

```dart
enum DrawingTool { point, line, rectangle, square, circle, ellipse, eraser }

class CanvasController extends ChangeNotifier {
  // state
  List<Shape> get shapes;                 // unmodifiable
  Shape? get draftShape;                  // shape being dragged (preview)
  DrawingTool tool;
  ShapeStyle style;

  // mutations (all call notifyListeners)
  void setTool(DrawingTool t);
  void setStyle(ShapeStyle s);
  void startDrawing(Offset start);        // no-op if tool == eraser
  void updateDrawing(Offset current);
  void endDrawing();                      // commits draft into shapes
  void eraseAt(Offset point);             // removes topmost shape under point
  void clear();
  void loadShapes(List<Shape> shapes);    // replaces all shapes (used after Load)
}
```

The `_createShape(start, end)` private helper switches on `tool` to construct the right concrete `Shape`. `eraser` throws — the lifecycle methods short-circuit before reaching it.

---

## `lib/painter/canvas_painter.dart`

Pure renderer. Does not own state.

```dart
class CanvasPainter extends CustomPainter {
  CanvasPainter({
    required Listenable repaint,          // hooked to controller
    required this.shapes,
    required this.draft,
  }) : super(repaint: repaint);

  void paint(Canvas, Size) {
    // 1. fill background white (so PNG export looks clean)
    // 2. draw each committed shape
    // 3. draw the draft on top (drag preview)
  }
}
```

Subscribing via `repaint: controller` means every `notifyListeners()` triggers exactly one repaint. No manual `setState` plumbing.

---

## `lib/serialization/`

### `binary_writer.dart` / `binary_reader.dart`

Thin wrappers over `ByteData`:

| Writer method | Reader method | Bytes |
| --- | --- | --- |
| `writeUint8(int)` | `readUint8()` | 1 |
| `writeUint32(int)` | `readUint32()` | 4 |
| `writeFloat32(double)` | `readFloat32()` | 4 |
| `writeBool(bool)` | `readBool()` | 1 |

All little-endian. Pure Dart; no Flutter imports. Unit-testable without a Flutter test harness.

### `shape_codec.dart`

Translates between `List<Shape>` and a flat `Uint8List`.

```dart
class ShapeCodec {
  static Uint8List encodeAll(List<Shape> shapes);  // header + per-shape rows
  static List<Shape> decodeAll(Uint8List bytes);   // reverse
}
```

Encoding: writes `magic = 0x44524157`, `version = 1`, `shapeCount`, then for each shape writes its `typeCode`, four floats `(startX, startY, endX, endY)`, two ARGB uint32s, `strokeWidth` float, and `filled` bool.

Decoding: reads the header, validates magic + version, then loops `shapeCount` times reconstructing the right `Shape` subclass via `ShapeType.fromCode`.

---

## `lib/services/`

### `file_service.dart`

```dart
class FileService {
  Future<String?> save(List<Shape> shapes);   // returns saved path, or null on cancel
  Future<List<Shape>?> load();                // returns shapes, or null on cancel
}
```

Uses `file_picker` for cross-platform dialogs. On desktop the path is returned and we write via `dart:io`; on Android the platform writes via the Storage Access Framework using the `bytes:` parameter.

### `export_service.dart`

```dart
class ExportService {
  Future<String?> exportPng(GlobalKey repaintKey);
}
```

Captures the widget under `repaintKey` at `pixelRatio: 2.0`, encodes to PNG, opens a save dialog. JPEG support was intentionally dropped — the spec accepts PNG **or** JPEG.

---

## `lib/ui/pages/canvas_page.dart`

The single page. Holds the controller, repaint key, and service instances. Wires:

- `AppBar` icons → `_load`, `_save`, `_exportPng`, `controller.clear`
- Body → `Column(DrawingToolbar, Expanded(DrawingCanvas))`
- All operations show a `SnackBar` with the result (`'Saved to <path>'` etc.)

---

## `lib/ui/widgets/drawing_canvas.dart`

Stateful. Tracks the eraser cursor position locally and renders the canvas.

Layout:

```
MouseRegion (cursor: none in eraser mode)
└── Stack
    ├── GestureDetector
    │   └── RepaintBoundary  (← only this is captured by PNG export)
    │       └── CustomPaint(painter: CanvasPainter)
    └── if (eraserActive && pos != null)
        Positioned(
          IgnorePointer(red translucent circle)
        )
```

Why the eraser indicator sits **outside** the `RepaintBoundary`: `boundary.toImage()` only captures its descendants, so the indicator is invisible in exports.

Gesture branching: `onPanStart / onPanUpdate / onPanEnd / onTapDown` all check `tool == eraser` first and call `controller.eraseAt(localPosition)` instead of the drawing lifecycle methods.

---

## `lib/ui/widgets/toolbar.dart`

Two scrollable rows, separated by a `Divider`:

1. **Tool row** — one `IconButton` per `DrawingTool` value. The selected tool is wrapped in a `Container` with `colorScheme.primaryContainer` background + a 2-px primary-color border.
2. **Style row** — three labelled groups (`Stroke`, `Fill`, `Width`) separated by short vertical dividers.

The whole toolbar is wrapped in a `ListenableBuilder` listening to the controller, so swatch borders, slider position, switch state, and selected-tool highlight all update immediately when style or tool changes.

---

## `lib/ui/widgets/color_swatch_picker.dart`

```dart
enum SwatchTarget { stroke, fill }

class ColorSwatchPicker extends StatelessWidget {
  final CanvasController controller;
  final SwatchTarget target;        // stroke or fill — same widget, different binding
}
```

Eight `Color` constants in `_palette`. Each swatch is a `Container` with a circle decoration; the currently-selected swatch (matching `style.strokeColor` or `style.fillColor` depending on `target`) gets a thicker blue-accent border.

---

## `lib/ui/widgets/stroke_width_slider.dart`

A bare `Slider` from 1 to 20 with `divisions: 19` (integer steps). Reads / writes `controller.style.strokeWidth`. Pure delegation; no local state.

---

## Where to start reading

If you want to trace the full flow of "I dragged a line on the canvas and saved the file":

1. `drawing_canvas.dart` — `onPanStart` → `onPanUpdate` → `onPanEnd`
2. `canvas_controller.dart` — `startDrawing` builds a `LineShape`, `endDrawing` commits it, `notifyListeners` fires
3. `canvas_painter.dart` — repaints the canvas
4. `canvas_page.dart` — `_save` calls `FileService.save(controller.shapes)`
5. `file_service.dart` → `shape_codec.dart` → `binary_writer.dart`
6. Bytes hit disk via `File.writeAsBytes`

The reverse (load) traces back the same chain: `binary_reader` → `shape_codec.decodeAll` → `controller.loadShapes` → painter repaints.
