# Changelog

## [12.1.0-1] - 2026-09-21

- Initial release for Retail 12.1.0 and Danders Frames v5.3.3.
- Order raid groups from 1 through the highest displayed group: paired odd groups
  first, then paired even groups, with an odd final group last. Empty or hidden
  inner groups count as present for pairing in live layouts and previews.
- Recalculate pairing after display changes, deferring companion layout updates
  during combat and using current state when combat ends.
- Take precedence over Danders Frames' **Group Display Order** and **My Group First**
  settings while enabled. Disable the companion and reload to restore those choices.
