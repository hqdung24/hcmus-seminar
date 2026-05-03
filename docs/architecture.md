# Architecture

## Layers

```
┌──────────────────────────────────────────────┐
│  UI Layer        (lib/ui/)                   │
│  pages, widgets, toolbar, color picker        │
└─────────────┬────────────────────────────────┘
              │ reads + mutates
┌─────────────▼────────────────────────────────┐
│  State Layer     (lib/state/)                │
│  CanvasController (ChangeNotifier)            │
│  - shapes[], draftShape, tool, style          │
└─────────────┬────────────────────────────────┘
              │ reads
┌─────────────▼────────────────────────────────┐
│  Painter Layer   (lib/painter/)              │
│  CanvasPainter — pure draw logic              │
└─────────────┬────────────────────────────────┘
              │ uses
┌─────────────▼────────────────────────────────┐
│  Models          (lib/models/)               │
│  Shape (abstract), 6 concrete shapes, Style   │
└──────────────────────────────────────────────┘

  ↕ horizontal: Services & Serialization

┌──────────────────────────────────────────────┐
│  Services        (lib/services/)             │
│  FileService, ExportService                   │
└─────────────┬────────────────────────────────┘
              │ uses
┌─────────────▼────────────────────────────────┐
│  Serialization   (lib/serialization/)        │
│  BinaryWriter, BinaryReader, ShapeCodec       │
└──────────────────────────────────────────────┘
```

## Key choices

1. **Shape is polymorphic.** Each concrete shape (rectangle, circle, etc.) overrides `draw()` and `withEnd()`. Adding a new shape = one new file. No giant switch statements scattered around.

2. **Two-point representation.** Every shape is `(start, end, style)`. Even circles. This makes:
   - Drag-to-draw uniform across all tools
   - Serialization uniform — same 4 floats for every shape
   - Code dead simple

3. **State via `ChangeNotifier`.** Lightweight, built-in, no extra packages. `ListenableBuilder` rebuilds only the canvas when shapes change.

4. **Painter takes `repaint: controller`.** When the controller calls `notifyListeners()`, the painter repaints. No manual setState gymnastics.

5. **`RepaintBoundary` around the canvas** does double duty:
   - Isolates repaints from the toolbar
   - Allows export to PNG (`boundary.toImage()`)

6. **Serialization is Flutter-free.** Pure Dart in `serialization/` — testable without `flutter_test`.

7. **Services hide platform diffs.** `FileService` uses `file_picker` which abstracts Win32 dialogs vs Android SAF. UI doesn't care which platform it's on.

## Why not Provider/Riverpod?

For a single-screen app with one piece of shared state, `ChangeNotifier` + `ListenableBuilder` is enough. Adding a state library would be over-engineering. If the app grows to multiple screens with shared state, swap in Riverpod later — the controller class can wrap a `Notifier` with minimal changes.
