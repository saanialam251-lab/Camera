# Measure Reality — Detailed User Guide

## Golden rule: hand mark first

**Aim the reticle → tap START / SET END POINT.**

That is the basic, reliable method. You mark points with the phone (your “hand”).  
You do **not** need a corner, an edge, or automatic detection.

| Assist | Role |
|--------|------|
| Hand mark (reticle + button) | **Primary** — always available |
| Snap to corner / edge | **Optional** — turn Off if you want pure freehand |
| Undo | Fixes a wrong mark or a bad snap |

The endpoint is **never** auto-locked. Only **SET END POINT** commits it.

---

## Distance

1. Aim at any start spot (floor, wall, furniture, free space).  
2. Tap **START**.  
3. Move; aim at any end spot.  
4. Tap **SET END POINT**.  
5. Read value + confidence + error range.

**Keys:** START · SET END POINT · Undo · optional Nudge / Axis lock  

**Options:** Snap Off/Low/Med/High · Precision mode · Units  

---

## Path

Mark a chain of points along a route (cable, skirting, fence).  
At each joint: aim → add point. Finish with **Done**.

---

## Height

- **Ground-to-point:** base on floor (or auto-floor), top by hand mark.  
- **Two-point vertical:** mark base and top yourself.  
- **Tree/pole estimate:** distance + elevation angle (labeled estimate).

---

## Area

Walk the outline. Tap vertices at corners **or** mid-edge. Close the polygon.  
Optional: subtract windows/doors. Estimators for paint/flooring after result.

---

## Angle / Slope

Mark the vertex and two arms (or two lines). Hand place each point.

---

## Level / Vertical

Surface: phone on object. Camera: plane tilt. **Calibrate** on a known flat surface.

---

## Room scan (corners optional)

### Floor
Point at the floor, move slowly. Coverage meter fills.

### Walls — hand marks
For each wall you may:

- Tap **near each corner** (good for rectangular rooms), **or**
- Tap **several points along the wall** if corners are unclear, **or**
- **Mix** both.

Snap may pull toward a detected corner — **Undo** if wrong.  
**Snap Off** = only your hand marks.

### Correcting a corner
Undo → stand closer → aim carefully → tap again.  
Do not rely on automatic “fix corner”; re-mark by hand.

### Ceiling (optional)
Look up for height/volume.

### Doors / windows
Aim at opening → Door or Window marker.

### Finish
Review floor plan → export SVG / PNG / PDF.

---

## Object (box)

Mark length, width, height edges with start/end hand marks on each edge.

---

## Settings (keys)

| Setting | Meaning |
|---------|---------|
| Snap | Optional magnet to edge/corner; Off = freehand only |
| Precision | More samples when locking a point |
| Units | m, cm, mm, ft, in, fractions |
| Haptics / Sound / Voice | Feedback when placing points |
| Confidence badge | High/Med/Low + error range + reasons |

---

## Confidence

Every number shows **confidence** and **+/- error**.  
Tap the badge for reasons (fast movement, low light, no depth, etc.).  
Phone AR is typically within about 1–3% in good conditions — not a certified instrument.

---

## Camera quality (must be viable)

If the image is **blurry**, dark, or tracking is lost, marks are not listing-grade.

| Level | What you see | What to do |
|-------|----------------|------------|
| **Good** | Clear picture, stable reticle | Mark start/end normally |
| **Fair** | Soft or dim | Hold still; optional loupe |
| **Poor** | Blurry / weak | Loupe + **pinch** to fine-adjust, then lock |
| **Unusable** | Not viable | START / SET END blocked until view improves |

**Tips when blurry**
1. Add light; avoid pure white walls.
2. Tap to focus; hold the phone still 1 second.
3. Move closer (1–2 m from the wall for listing lengths).
4. Open **loupe**; **pinch** to nudge the mark; then press SET END POINT.
5. Only share **Medium** or **High** confidence numbers.

Blur and low light also lower the confidence badge and widen the error range.

---

## Selling a room — which points to mark

1. **Length** — floor-wall junction, one end → opposite end (hand mark).  
2. **Width** — same on the adjacent wall.  
3. **Ceiling height** — floor base → ceiling (or top of wall).  
4. **Corners** (optional but best for plan) — each floor corner if visible.  
5. **Door / windows** (optional) — clear jamb edges.  
6. **Alcoves** — every direction change by hand.

Hidden corner? Mark the nearest visible wall point and note it.  
Re-measure length/width once; if they differ by more than ~2%, measure again.

---

## Land / plot (not only rooms)

The app measures **rooms and land**. Land mode is for outdoor parcels, fields, and landmarks.

1. START at a boundary mark (post, corner, stone).  
2. Walk the edge; add a point at every turn (hand mark).  
3. **Close** the loop → **perimeter** + **area** (m², acres, hectares).  
4. High precision is default for land — more samples per point.  
5. Share only Medium/High confidence values.

Rooms remain available for indoor work; land is separate and built for larger outdoor loops.

---

## Units & white UI

- Units stay fully supported (m, cm, mm, ft, in, fractions, m², acres, ha).  
- Results, history, settings, and unit pickers use a **white** surface theme.  
- Camera measure view stays dark over the live feed.  
- Buttons, values, and cards use **motion** (scale, fade, slide) across the app.
