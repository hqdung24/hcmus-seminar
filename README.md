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
