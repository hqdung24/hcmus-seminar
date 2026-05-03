# 7-Day Development Roadmap

**Team**: 3 developers
**Tech**: Flutter (Windows + Android)
**Project**: Frontend-only drawing app

---

## Module split

| Module | Lives in | Owner |
|--------|----------|-------|
| **UI Layer** | `lib/ui/` (pages, toolbar, color picker, slider) | **Dev C** |
| **Drawing Engine** | `lib/painter/`, `lib/state/canvas_controller.dart` | **Dev A** |
| **Shape Models** | `lib/models/`, `lib/models/shapes/` | **Dev A** |
| **Serialization** | `lib/serialization/` | **Dev B** |
| **File Handling** | `lib/services/file_service.dart`, `lib/services/export_service.dart` | **Dev B** |

Cross-cutting:
- Tests: each dev writes tests for their own module
- Code review: PR + 1 reviewer minimum

---

## Daily plan

### Day 1 — Setup & contracts

| Dev | Task | Commit |
|-----|------|--------|
| A | Init project, lock down folder structure, write Shape base class + ShapeStyle | `feat: project structure + Shape base class` |
| B | Add `BinaryWriter` + `BinaryReader` skeletons + unit tests for primitives | `feat: binary primitives + tests` |
| C | Set up `MaterialApp`, blank `CanvasPage` with placeholder toolbar | `feat: app shell + canvas page scaffold` |

**Output**: Project compiles, blank canvas opens on Windows + Android. `flutter test` passes empty.
**Dependency**: A finishes folder structure first (~1 hour). Then B and C can branch off freely.
**Integration**: End of day — merge all 3 PRs to `main`.

---

### Day 2 — Concrete shapes & painter

| Dev | Task | Commit |
|-----|------|--------|
| A | Implement all 6 shape classes (Point, Line, Rect, Square, Circle, Ellipse) + CanvasPainter | `feat: 6 shape types + CustomPainter` |
| B | Implement `ShapeCodec.encodeAll` + `decodeAll` for all 6 shapes + tests | `feat: shape codec + roundtrip tests` |
| C | Build toolbar UI with shape buttons (no-op handlers), color swatches, stroke slider | `feat: toolbar + color/stroke widgets` |

**Output**: Tests pass for codec; UI shows toolbar but doesn't draw yet.
**Dependency**: B's codec needs A's shape models (use git rebase or merge).
**Integration**: Quick PR sync at end of day. No actual feature integration yet.

---

### Day 3 — Wire it together (drawing works!)

| Dev | Task | Commit |
|-----|------|--------|
| A | Implement `CanvasController` (start/update/end drawing, tool, style). Wire painter to controller via `ListenableBuilder` | `feat: CanvasController with draw lifecycle` |
| B | Implement `FileService.save()` and `load()` with `file_picker`, error handling | `feat: file save/load via file_picker` |
| C | Wire toolbar buttons to controller (`controller.setTool`, `setStyle`). Add GestureDetector to canvas widget | `feat: wire UI to controller + gesture handling` |

**Output**: 🎉 You can actually draw shapes on the canvas! No save yet.
**Integration**: End of Day 3 = mid-week demo. All devs run the app on both platforms, verify drawing works.
**Risk**: This is the critical integration point. Plan a 30-min pair session at end of day.

---

### Day 4 — Save / Load / Export

| Dev | Task | Commit |
|-----|------|--------|
| A | Add "Clear canvas" button + undo last shape (bonus). Refactor controller for cleanliness | `feat: clear + undo last shape` |
| B | Implement `ExportService` for PNG via `RepaintBoundary.toImage()`. Hook to FileService | `feat: PNG export via RepaintBoundary` |
| C | Add Save / Load / Export buttons in app bar. Show snackbars on success/failure | `feat: file actions in app bar with feedback` |

**Output**: Full save/load/export round-trip works. Open a saved file → shapes redraw correctly.
**Integration**: End of day — full file workflow demo on Windows + Android.

---

### Day 5 — Cross-platform fixes & polish

| Dev | Task | Commit |
|-----|------|--------|
| A | Test all 6 shapes on Android (touch) + Windows (mouse). Fix gesture differences (e.g. point shape on tap-only) | `fix: tap vs drag gesture handling` |
| B | Test save/load on Android (SAF) and Windows file dialog. Add proper error handling for invalid files | `fix: cross-platform file access + error UX` |
| C | Polish toolbar layout for narrow Android screens (scrollable). Add file name display | `feat: responsive toolbar + file name display` |

**Output**: App feels solid on both platforms. No platform-specific crashes.
**Integration**: Bug bash — each dev tries to break the others' features for 30 min.

---

### Day 6 — Edge cases & extras

| Dev | Task | Commit |
|-----|------|--------|
| A | Add JPEG export (use `image` package), add square aspect lock, tighten ellipse drawing | `feat: JPEG export + square aspect + ellipse polish` |
| B | Add file format version check tests (corrupt file, wrong magic, wrong version) | `test: error handling for invalid .draw files` |
| C | Add a "Fill / Stroke only" toggle in toolbar. Color picker for fill color | `feat: fill toggle + fill color picker` |

**Output**: All requirements met (PNG **and** JPEG export, fill colors, stroke colors).
**Integration**: Final feature freeze at end of day.

---

### Day 7 — Demo prep

| Dev | Task | Commit |
|-----|------|--------|
| A | Record demo video on Windows (drawing all 6 shapes, save, load, clear) | `docs: demo video Windows` |
| B | Record demo video on Android (touch drawing, save, load, export) | `docs: demo video Android` |
| C | Write `README.md`: how to build, screenshots, feature list. Final UI polish | `docs: README + final polish` |

**Submission checklist (end of Day 7):**
- [ ] App builds and runs on Windows
- [ ] App builds and runs on Android
- [ ] All 6 shape types draw correctly
- [ ] Stroke color, fill color, stroke width all work
- [ ] Save → close → load reproduces the drawing exactly
- [ ] Export to PNG opens in any image viewer
- [ ] Export to JPEG opens in any image viewer
- [ ] No crashes when opening an invalid `.draw` file
- [ ] README has build instructions
- [ ] Demo videos uploaded
- [ ] Code is tagged with `v1.0.0`

---

## Commit strategy

**Rules:**
1. **Every dev commits at least once per day** — even if the feature isn't complete, push WIP to a branch
2. **One commit = one logical change** — no "fix everything" commits
3. **Conventional commit prefixes**: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
4. **Branch naming**: `<dev>/<feature>` e.g. `dev-a/circle-shape`, `dev-b/file-service`
5. **PR + 1 reviewer** before merging to `main`
6. **Daily merge window**: end of each day, sync `main` with all 3 branches

**Example daily commit log (Day 3):**
```
e3a2f1b dev-a: feat: CanvasController with draw lifecycle
8c9d4e2 dev-b: feat: file save/load via file_picker
1f7c2a8 dev-c: feat: wire UI to controller + gesture handling
9b0d6c3 dev-c: fix: gesture detector swallows toolbar taps
```

---

## Integration points

| Day | Integration | Owner |
|-----|-------------|-------|
| End of Day 1 | Project structure agreed, branches set up | Dev A leads |
| End of Day 2 | Codec ↔ Shape contract verified | A + B pair |
| **End of Day 3** | **Full app drawing works** (critical) | All three pair |
| End of Day 4 | Save/load round-trip on both platforms | B + C pair |
| End of Day 5 | Bug bash | All three |
| End of Day 6 | Feature freeze | All three |
| Day 7 | Demo recording + README | All three |

---

## Risk management

| Risk | Probability | Mitigation |
|------|-------------|------------|
| `file_picker` behaves differently on Android vs Windows | High | Build on both platforms from Day 1, not Day 5 |
| `RepaintBoundary.toImage()` returns null on Android | Medium | Test export early in Day 4 |
| GestureDetector swallows taps on toolbar buttons | Medium | Wrap canvas in `Listener` if needed; test Day 3 |
| Binary format off-by-one bug | Low (we have tests) | Day 2 unit tests catch this |
| One dev's PR blocks another | Medium | Daily merge window keeps `main` fresh |
| JPEG export needs extra package | Medium | Day 6 has buffer; can drop to PNG-only if blocked |
| Last-day platform-specific bug | High | Buffer Day 7 morning for emergency fixes |

**Fallback plan if behind by Day 5:**
- Drop JPEG (PNG only)
- Drop fill color picker (stroke only)
- Drop undo
- Keep: 6 shapes, save/load, PNG export, both platforms working

---

## Definition of "Done"

A task is done when:
1. Code is on `main` (merged via PR)
2. App builds on both Windows and Android
3. Feature works manually on both platforms
4. If logic-heavy (codec, controller): unit tests pass
5. No teammate can crash the feature in 5 min of trying
