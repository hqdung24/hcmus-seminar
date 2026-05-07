# Drawing App (HCMUS Seminar)

A cross-platform Flutter drawing app for Windows + Android.
Frontend-only. No backend, no auth, no server.

## Features

- 6 shape types: point, line, rectangle, square, circle, ellipse
- Stroke color, fill color, stroke width
- Save / load custom binary format (`.draw`)
- Export canvas to PNG / JPEG

## Run

```bash
flutter pub get
flutter run -d windows   # or -d <android-device-id>
```

## Test

```bash
flutter test
```

## Documentation

- [Architecture](docs/architecture.md)
- [Binary file format](docs/binary-format.md)
- [7-Day roadmap](docs/roadmap-7-days.md)

## Future Improvements

While this application fulfills all current seminar requirements, several features could be added to enhance its utility as a fully-featured drawing tool:

- **Free-hand drawing:** Allow continuous stroke drawing in addition to geometric shapes.
- **Undo / Redo system:** Implement an action stack to easily revert or reapply changes.
- **Object Manipulation:** Allow selecting, moving, resizing, and deleting shapes after they have been drawn.
- **Layer Management:** Introduce a layered canvas system to handle background and foreground elements separately.
- **Additional Platforms:** Expand testing and deployment to the Web and macOS using Flutter's multi-platform capabilities.
