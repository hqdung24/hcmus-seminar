# Binary File Format (`.draw`)

All values are **little-endian**.

## Header (9 bytes)

| Offset | Size | Field        | Description                |
|--------|------|--------------|----------------------------|
| 0      | 4    | `magic`      | `0x44524157` ("DRAW")      |
| 4      | 1    | `version`    | Format version (currently 1) |
| 5      | 4    | `shapeCount` | Number of shapes that follow |

## Shape entry (26 bytes)

| Offset | Size | Field          | Description                          |
|--------|------|----------------|--------------------------------------|
| 0      | 1    | `typeCode`     | 1=Point, 2=Line, 3=Rect, 4=Square, 5=Circle, 6=Ellipse |
| 1      | 4    | `startX`       | Float32                              |
| 5      | 4    | `startY`       | Float32                              |
| 9      | 4    | `endX`         | Float32                              |
| 13     | 4    | `endY`         | Float32                              |
| 17     | 4    | `strokeColor`  | ARGB packed in uint32                |
| 21     | 4    | `fillColor`    | ARGB packed in uint32                |
| 25     | 4    | `strokeWidth`  | Float32                              |
| 29     | 1    | `filled`       | 0 = stroke only, 1 = filled          |

(Size is fixed per shape — easy to seek if we ever need an index.)

## File size

- Header: 9 bytes
- Per shape: 30 bytes
- 100 shapes ≈ 3 KB

## Versioning

The `version` byte allows backward-compatible reads. If we ever add a field, bump the version, and the reader can branch on it. For v1, refuse to read anything else.

## Example bytes (1 line shape)

```
57 41 52 44 01 01 00 00 00     <- header (magic + ver + count=1)
02                              <- typeCode = line
00 00 20 41                     <- startX = 10.0
00 00 A0 41                     <- startY = 20.0
00 00 C8 42                     <- endX   = 100.0
00 00 48 43                     <- endY   = 200.0
FF 00 00 00                     <- strokeColor (black opaque, ARGB=0xFF000000)
00 00 00 00                     <- fillColor  (transparent)
00 00 00 40                     <- strokeWidth = 2.0
00                              <- filled = false
```
