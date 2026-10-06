/// Detailed per-mode / per-option user guides.
/// Hand-marked points are the basic reliable method; snap/corners are optional assist.

class GuideStep {
  final String title;
  final String body;
  final String? tip;

  const GuideStep({required this.title, required this.body, this.tip});
}

class ModeGuide {
  final String id;
  final String name;
  final String summary;
  final List<GuideStep> steps;
  final List<String> keys; // buttons / options explained
  final List<String> options;

  const ModeGuide({
    required this.id,
    required this.name,
    required this.summary,
    required this.steps,
    this.keys = const [],
    this.options = const [],
  });
}

class ModeGuides {
  ModeGuides._();

  /// Core rule shown on every measure screen.
  static const handMarkRule =
      'Hand mark is the basic method: aim the reticle and tap START / SET END POINT. '
      'You do not need a corner. Corners and edges are optional snap assist only.';

  static const distance = ModeGuide(
    id: 'distance',
    name: 'Distance (two-point)',
    summary:
        'Measure the straight-line length between two points you mark with the phone.',
    steps: [
      GuideStep(
        title: '1. Aim at the start',
        body:
            'Hold the phone steady. Point the reticle at the place you want to start — '
            'a wall, floor mark, furniture edge, or any visible spot. '
            'You can mark with your hand (reticle + tap). A corner is not required.',
        tip: 'Green / stable reticle = good tracking. Move slowly if it turns amber.',
      ),
      GuideStep(
        title: '2. Tap START',
        body:
            'Press the primary START button. The app locks the start point only when you press it. '
            'It never auto-locks. Optional: hold still for a moment so more samples improve confidence.',
      ),
      GuideStep(
        title: '3. Move to the end',
        body:
            'Walk or pan the phone to the end location. The live line updates as you move. '
            'Again, aim at any point you choose — not only corners.',
      ),
      GuideStep(
        title: '4. Tap SET END POINT',
        body:
            'When the reticle is on your end mark, press SET END POINT. '
            'Only this deliberate action commits the measurement. Undo is always available.',
      ),
      GuideStep(
        title: '5. Read the result',
        body:
            'Distance is shown with confidence (High / Medium / Low) and an error range '
            '(example: 2.37 m +/- 0.03 m). Tap the badge for reasons (fast movement, low light, etc.).',
      ),
    ],
    keys: [
      'START — locks start point (hand mark or snap)',
      'SET END POINT — locks end point; never automatic',
      'Undo — removes last lock or last snap pull',
      'Nudge — fine adjust +/-1 mm when zoomed (if enabled)',
      'Axis lock — constrain to X / Y / Z while stretching',
    ],
    options: [
      'Snap (Off / Low / Med / High) — optional magnet to edges/corners; can be Off',
      'Precision mode — more samples when locking (slower, more stable)',
      'Unit — m, cm, mm, ft, in, ft+in, fractions',
    ],
  );

  static const path = ModeGuide(
    id: 'path',
    name: 'Path (multi-point)',
    summary: 'Measure a path made of several hand-marked segments (perimeter, cable run, etc.).',
    steps: [
      GuideStep(
        title: '1. Mark first point',
        body: 'Aim and tap START (or Add point). Hand mark any visible location.',
      ),
      GuideStep(
        title: '2. Add more points',
        body:
            'Move along the path. At each turn or joint, aim and tap to add a point. '
            'Corners help but are optional — mark mid-wall or free space if that is what you need.',
      ),
      GuideStep(
        title: '3. Finish',
        body: 'Tap Done / Complete when the path is finished. Total length and segments are saved.',
      ),
    ],
    keys: [
      'Add point — places next vertex at the reticle',
      'Done — finishes the path',
      'Undo — removes last vertex',
    ],
    options: ['Snap assist optional', 'Show segment lengths on/off'],
  );

  static const height = ModeGuide(
    id: 'height',
    name: 'Height',
    summary: 'Vertical distance from floor (or a base point) to a top point.',
    steps: [
      GuideStep(
        title: 'Ground-to-point',
        body:
            'Aim at the floor under the object, tap to set base (or use auto-floor if available). '
            'Aim at the top, tap SET END POINT. Hand marks work on walls, people, poles.',
      ),
      GuideStep(
        title: 'Two-point vertical',
        body: 'Mark base and top yourself if the floor is unclear.',
      ),
      GuideStep(
        title: 'Tree / pole estimate',
        body:
            'Stand at a known distance, aim at the top, use elevation angle. '
            'Marked as estimate — not as precise as two AR points.',
      ),
    ],
    keys: ['START / SET END POINT', 'Method switch: Ground / Two-point / Estimate'],
    options: ['Person height preset display', 'Tilt warning if phone pitch > 45 deg'],
  );

  static const area = ModeGuide(
    id: 'area',
    name: 'Area',
    summary: 'Polygon area by hand-marking vertices around a surface.',
    steps: [
      GuideStep(
        title: '1. Mark vertices',
        body:
            'Walk the outline. At each corner or along each edge, aim and tap to place a point. '
            'You may mark only corners, or add mid-edge points for irregular shapes.',
      ),
      GuideStep(
        title: '2. Close the shape',
        body: 'Tap Close / Done when back near the first point (or explicit close).',
      ),
      GuideStep(
        title: '3. Optional subtract',
        body: 'Add a hole (window, island) with a second polygon to subtract from the area.',
      ),
    ],
    keys: ['Add vertex', 'Close polygon', 'Subtract region', 'Undo'],
    options: ['Snap to wall edges optional', 'Paint / flooring estimator after result'],
  );

  static const angle = ModeGuide(
    id: 'angle',
    name: 'Angle / Slope',
    summary: 'Angle between two directions or slope of a line you mark.',
    steps: [
      GuideStep(
        title: 'Three points or two lines',
        body:
            'Mark vertex, then two arms — or mark two segments. Hand place each point with the reticle.',
      ),
    ],
    keys: ['Add point', 'Complete'],
    options: ['Show slope % and degrees'],
  );

  static const level = ModeGuide(
    id: 'level',
    name: 'Level / Vertical',
    summary: 'Bubble level and vertical check using sensors + optional plane.',
    steps: [
      GuideStep(
        title: 'Surface mode',
        body: 'Place the phone edge on the object. Read degrees from level.',
      ),
      GuideStep(
        title: 'Camera mode',
        body: 'Point at a surface; use detected plane tilt.',
      ),
      GuideStep(
        title: 'Calibrate',
        body: 'Put the phone on a known flat surface and tap Calibrate to zero offset.',
      ),
    ],
    keys: ['Calibrate', 'Surface / Camera toggle'],
    options: ['Haptic tick near 0 deg', 'Show degrees or mm/m'],
  );

  static const room = ModeGuide(
    id: 'room',
    name: 'Room scan',
    summary:
        'Build a floor plan. Mark walls by hand along edges or at corners — corners are helpful, not mandatory.',
    steps: [
      GuideStep(
        title: '1. Scan the floor',
        body:
            'Point at the floor and move slowly so the app sees the floor plane. '
            'Coverage meter fills as you go.',
        tip: 'Good lighting and textured floors track better than pure white.',
      ),
      GuideStep(
        title: '2. Mark the walls (hand marks)',
        body:
            'For each wall, aim the reticle at points along that wall and place marks. '
            'You can:\n'
            '• Tap near each corner (recommended for rectangle rooms), or\n'
            '• Tap several points along a long wall if corners are unclear, or\n'
            '• Mix both — corners where clear, freehand where not.\n'
            'Snap may gently pull toward a detected corner; you can undo a snap. '
            'Turning snap Off keeps pure hand placement.',
        tip: 'Basic reliable method = aim + tap. Do not wait for automatic corner detection only.',
      ),
      GuideStep(
        title: '3. Correct a bad corner',
        body:
            'If a corner is wrong: Undo the last point, stand closer, aim carefully, tap again. '
            'You can also Nudge after lock if fine adjust is enabled. '
            'Wrong corners are fixed by re-marking with your hand — not by hoping for auto-fix.',
      ),
      GuideStep(
        title: '4. Ceiling (optional)',
        body: 'Look up and capture ceiling height for volume. Skip if you only need floor area.',
      ),
      GuideStep(
        title: '5. Doors and windows',
        body:
            'Aim at the opening center (or bottom center), mark Door or Window. '
            'Adjust width/height if the sheet offers it.',
      ),
      GuideStep(
        title: '6. Finish and export',
        body:
            'Review the floor plan. Export SVG / PNG / PDF. Use Compare later against another scan.',
      ),
    ],
    keys: [
      'Next stage — floor → walls → ceiling → done',
      'Add point — hand mark on current wall/floor',
      'Undo — remove last mark (fix corner mistakes)',
      'Door / Window — place opening marker at reticle',
      'Snap Off — pure hand marks only',
    ],
    options: [
      'Snap strength for corners (optional)',
      'Coverage meter',
      'Export floor plan SVG',
    ],
  );

  static const objectMode = ModeGuide(
    id: 'object',
    name: 'Object (box / volume)',
    summary: 'Measure length, width, height of an object by hand-marking edges.',
    steps: [
      GuideStep(
        title: 'Mark three edges',
        body:
            'Aim along length, tap; width, tap; height, tap. '
            'Start and end of each edge are hand-marked. Corners of the box help but you can mark mid-edge.',
      ),
    ],
    keys: ['Next edge', 'Complete', 'Undo'],
    options: ['Parcel volumetric weight estimator'],
  );


  static const land = ModeGuide(
    id: 'land',
    name: 'Land / plot',
    summary:
        'Measure outdoor land, parcels, and landmarks with high precision. Not limited to rooms.',
    steps: [
      GuideStep(
        title: '1. Start at a boundary mark',
        body:
            'Stand at a clear corner or fence post of the plot. Aim the reticle and tap START. '
            'Hand mark is the basic method — corners help but are not required.',
        tip: 'Good light and slow movement improve outdoor accuracy.',
      ),
      GuideStep(
        title: '2. Walk the boundary',
        body:
            'Walk along the edge of the land. At every corner or change of direction, aim and add a point. '
            'You can mark fence posts, stones, or any visible landmark.',
      ),
      GuideStep(
        title: '3. Close the plot',
        body:
            'When you return near the start, tap Close. Perimeter and area are computed '
            '(m², acres, hectares). High-precision mode uses more samples per point.',
      ),
      GuideStep(
        title: '4. Review confidence',
        body:
            'Only use Medium/High confidence for legal or sale-related figures. '
            'Re-walk one side if values look inconsistent.',
      ),
    ],
    keys: [
      'START / Add point — boundary vertex at reticle',
      'Close — finishes the land loop',
      'Undo — removes last vertex',
      'High precision — on by default for land',
    ],
    options: [
      'Units: m, m², acres, hectares',
      'Snap optional along fence lines',
      'Export plan + area',
    ],
  );

  static const all = [
    distance,
    path,
    height,
    area,
    angle,
    level,
    room,
    objectMode,
    land,
  ];

  static ModeGuide? byId(String id) {
    try {
      return all.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
