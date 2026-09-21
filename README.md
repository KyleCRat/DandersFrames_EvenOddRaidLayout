# DandersFrames Even/Odd Raid Layout

Displays Danders Frames' raid groups in this order:

`1, 3, 5, 7, 2, 4, 6, 8`

Use Danders' grouped raid layout. With only groups 1-4 displayed, their order is
`1, 3, 2, 4`. When members grow right and groups grow down, that gives:

```text
[1.1][1.2][1.3][1.4][1.5]
[3.1][3.2][3.3][3.4][3.5]
[2.1][2.2][2.3][2.4][2.5]
[4.1][4.2][4.3][4.4][4.5]
```

Danders continues to control growth directions, wrapping, spacing, hidden and
empty groups, member sorting, group labels, and combat updates. Its built-in
raid preview uses the same odd/even order. Party and flat raid layouts retain
their normal behavior.

While enabled, this companion's order takes precedence over Danders' **Group
Display Order** and **My Group First** settings. Their saved values are unchanged.
Disable the companion in WoW's addon list and reload to restore those choices.
There are no additional controls, slash commands, or SavedVariables.

Version `12.1.0-1` targets Retail 12.1.0 and Danders Frames v5.3.3. The integration
uses Danders' internal group-order function, so a future Danders update may require
changes.
It passes a Lua 5.1 syntax check; live rendering, previews, click casting, and
combat transitions still need in-game verification.
