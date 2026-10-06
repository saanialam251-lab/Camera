/// Points to mark when measuring a room for sale / listing.
/// Works with hand marks; corners preferred when visible, freehand when not.
/// Camera must be usable — follow quality tips if blurry.

class SellPoint {
  final String id;
  final String label;
  final String how;
  final bool required;

  const SellPoint({
    required this.id,
    required this.label,
    required this.how,
    this.required = true,
  });
}

class RoomSellingChecklist {
  RoomSellingChecklist._();

  static const intro =
      'For a listing, mark clear, repeatable points. Use hand mark (aim + tap). '
      'If the camera is blurry: hold still, add light, pinch-adjust, then lock. '
      'Do not publish numbers when confidence is Low.';

  static const points = <SellPoint>[
    SellPoint(
      id: 'length',
      label: 'Room length',
      how:
          'Hand mark one wall end (corner if clear, or where wall meets floor), '
          'then the opposite end. Prefer floor-wall junction — easier to repeat.',
    ),
    SellPoint(
      id: 'width',
      label: 'Room width',
      how: 'Same on the adjacent wall. Two distances define a rectangular plan.',
    ),
    SellPoint(
      id: 'height',
      label: 'Ceiling height',
      how:
          'Base on floor under the same spot, top on ceiling or top of wall. '
          'Mark by hand; do not guess.',
    ),
    SellPoint(
      id: 'corners',
      label: 'Four corners (plan)',
      how:
          'If doing full room scan: mark each corner at floor level. '
          'If a corner is hidden, mark the nearest visible wall point and note it.',
      required: false,
    ),
    SellPoint(
      id: 'door',
      label: 'Door opening',
      how: 'Width between jambs; height floor to head. Mark clear edges by hand.',
      required: false,
    ),
    SellPoint(
      id: 'window',
      label: 'Window openings',
      how: 'Width and height of each window you want on the listing.',
      required: false,
    ),
    SellPoint(
      id: 'alcove',
      label: 'Alcoves / bay / irregular',
      how:
          'Extra path or area points along the irregular edge. '
          'Hand mark every change of direction.',
      required: false,
    ),
  ];

  static const cameraTipsWhenSelling = [
    'Stand 1–2 m from the wall; too far increases error.',
    'Turn on room lights; avoid backlight and pure white walls.',
    'If blurry: tap to focus, hold 1 second, use loupe, pinch-nudge, then SET END POINT.',
    'Only share measurements with Medium or High confidence.',
    'Re-measure length/width once; if they differ by more than ~2%, measure again.',
  ];
}
