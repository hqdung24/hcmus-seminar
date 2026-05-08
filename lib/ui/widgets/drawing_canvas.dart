import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../painter/canvas_painter.dart';
import '../../state/canvas_controller.dart';

/// Unified gesture handler for both touch (Android) and mouse (Windows).
/// Both platforms emit pan events, so a single GestureDetector handles both.
/// Renders an eraser hit-zone indicator (outside the RepaintBoundary so it
/// doesn't end up in the exported PNG).
class DrawingCanvas extends StatefulWidget {
  final CanvasController controller;
  final GlobalKey repaintKey;

  const DrawingCanvas({
    super.key,
    required this.controller,
    required this.repaintKey,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  // Local position of the eraser cursor; null when not hovering / not in eraser mode.
  Offset? _eraserPos;

  // Must match `tolerance` arg in Shape.hitTest (default 10.0 in shape.dart).
  static const double _eraserRadius = 10.0;

  // Touch-only platforms have no hover, so the eraser indicator must be
  // cleared on lift; on desktop we let onHover keep refreshing the position.
  static final bool _isTouchOnly = Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (_, __) {
        // Always read the tool inside the builder so changes via the toolbar
        // (which only fires notifyListeners, not setState here) are reflected
        // in gesture branching. Reading once outside causes a stale-closure
        // bug on touch platforms where there's no hover-driven setState.
        final eraserActive = widget.controller.tool == DrawingTool.eraser;

        return MouseRegion(
          cursor: eraserActive
              ? SystemMouseCursors.none
              : SystemMouseCursors.basic,
          onHover: eraserActive
              ? (e) => setState(() => _eraserPos = e.localPosition)
              : null,
          onExit: (_) {
            if (_eraserPos != null) setState(() => _eraserPos = null);
          },
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: (d) {
                  if (eraserActive) {
                    setState(() => _eraserPos = d.localPosition);
                    widget.controller.eraseAt(d.localPosition);
                    return;
                  }
                  widget.controller.startDrawing(d.localPosition);
                },
                onPanUpdate: (d) {
                  if (eraserActive) {
                    setState(() => _eraserPos = d.localPosition);
                    widget.controller.eraseAt(d.localPosition);
                    return;
                  }
                  widget.controller.updateDrawing(d.localPosition);
                },
                onPanEnd: (_) {
                  if (eraserActive) {
                    if (_isTouchOnly) {
                      setState(() => _eraserPos = null);
                    }
                    return;
                  }
                  widget.controller.endDrawing();
                },
                onTapDown: (d) {
                  if (eraserActive) {
                    setState(() => _eraserPos = d.localPosition);
                    widget.controller.eraseAt(d.localPosition);
                    return;
                  }
                  widget.controller.startDrawing(d.localPosition);
                  widget.controller.endDrawing();
                },
                onTapUp: (_) {
                  if (eraserActive && _isTouchOnly) {
                    setState(() => _eraserPos = null);
                  }
                },
                onTapCancel: () {
                  if (eraserActive && _isTouchOnly) {
                    setState(() => _eraserPos = null);
                  }
                },
                child: RepaintBoundary(
                  key: widget.repaintKey,
                  child: CustomPaint(
                    painter: CanvasPainter(
                      repaint: widget.controller,
                      shapes: widget.controller.shapes,
                      draft: widget.controller.draftShape,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              if (eraserActive && _eraserPos != null)
                Positioned(
                  left: _eraserPos!.dx - _eraserRadius,
                  top: _eraserPos!.dy - _eraserRadius,
                  child: IgnorePointer(
                    child: Container(
                      width: _eraserRadius * 2,
                      height: _eraserRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
