# DandersFrames Even/Odd Raid Layout

While enabled, this companion overrides Danders' **Group Display Order** and
**My Group First** settings. Changing those settings will not change the displayed
group order. Their saved values are preserved; disable the companion in WoW's
addon list and reload to use them again.


Orders Danders Frames' grouped raid frames from group 1 through the highest
displayed group, using pairs 1/2, 3/4, 5/6, and 7/8. Paired odd groups appear
first, followed by paired even groups. If the highest group is odd, it goes last.

Empty or hidden inner groups count as present for pairing. Danders continues to
control whether those groups occupy visible space. The built-in raid preview
uses its own highest displayed group, including its frame-count and visibility
settings.

| Displayed groups | Display order |
| --- | --- |
| 1-3 | `1, 2, 3` |
| 1-4 | `1, 3, 2, 4` |
| 1-5 | `1, 3, 2, 4, 5` |
| 1-6 | `1, 3, 5, 2, 4, 6` |
| 1-7 | `1, 3, 5, 2, 4, 6, 7` |
| 1-8 | `1, 3, 5, 7, 2, 4, 6, 8` |

Use Danders' grouped raid layout. With groups 1-4 displayed, members growing
right, and groups growing down:

```text
[1.1][1.2][1.3][1.4][1.5]
[3.1][3.2][3.3][3.4][3.5]
[2.1][2.2][2.3][2.4][2.5]
[4.1][4.2][4.3][4.4][4.5]
```

Danders continues to control all supported growth directions, wrapping, spacing,
member sorting, and group labels. The order follows the chosen growth directions
in both live frames and previews. Party and flat raid layouts retain their normal
behavior.

Pairing refreshes wait until combat ends and then use current display state.
Danders' native secure roster and child-visibility updates continue during combat.

Version `12.1.0-1` targets Retail 12.1.0 and Danders Frames v5.3.3. The integration
uses Danders' internal group-order and displayed-count interfaces, so a future
Danders update may require changes. It passes a Lua 5.1 syntax check; live and
preview layouts, hidden/empty group changes, growth directions and wrapping,
click casting, and combat transitions (including combat reloads) still need
in-game verification.
