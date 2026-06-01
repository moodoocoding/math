# SM-T595N Problem Screen UX Guidelines

Target device: Samsung Galaxy Tab SM-T595N, 10.5 inch, 1920x1200, 16:10 landscape.

## Layout Principles

- Treat the problem board as the primary object. The board or interactive area should occupy the largest visual weight on every problem screen.
- Use fixed responsive clamps instead of raw percentages. Side panels should usually stay between 240 and 340 px on landscape tablet layouts.
- Keep the problem prompt compact. A prompt band should normally stay under 96 px after the app bar.
- Keep the bottom action bar compact. Debug skip controls should be visually quiet and should not compete with the main action.
- Use one stable control grammar across problem screens: hint on the left, reset in the middle, submit/check on the right.
- Avoid decorative panels that do not help the task. Empty space should either enlarge the board, clarify the step flow, or improve touch targets.
- Minimum touch target: 56 px. Primary action height: 56-64 px on tablet landscape.

## Screen Types

### Board Type

Examples: tessellation, seesaw, brick puzzle, hidden word, magic square.

- Left or right side panel may contain tools, word list, or stage guide.
- The board should be centered in the remaining space and use at least 90% of the smaller available dimension.
- Side panels should use concise labels and avoid large headers unless the header explains a step.

### Choice Type

Examples: math quiz, coding quiz.

- Question card may be wide, but answer choices should keep a consistent 2x2 rhythm.
- Four choices is the default. Avoid six-choice layouts unless the activity explicitly requires sorting or grouping.

### QR Type

Examples: chapter 4 QR verification.

- The QR flow should describe a real-life completion check, not invent a hidden answer.
- Manual input exists only as a fallback for teacher guidance.

## Current Priority Fixes

1. Chapter 2 seesaw puzzle: restore a clear left-side stage guide, reduce the feeling of a tiny storage drawer, and keep score information close to the board.
2. Chapter 4 hidden word puzzle: place all eight words in a left column and allocate the remaining space to a larger 10x10 board.
3. Common bottom bars: keep debug skip secondary and prevent it from increasing the bar height too much.

## Implementation Matrix

| Chapter | Route | Screen | Type | Status |
| --- | --- | --- | --- | --- |
| 1 | `/mission_low` | `MissionLowScreen` | tessellation shape choice | Needs full SM-T595N pass |
| 1 | `/mission_ch1_q2` | `MissionLowScreen` | Hanoi / choice | Needs full SM-T595N pass |
| 2 | `/mission_chapter2_q1` | `SeesawPuzzleScreen` | board / balance | Updated |
| 2 | `/mission_chapter2_q2` | `Chapter2PuzzleQ2Screen` | board / pattern puzzle | Partially updated; target preview fixed |
| 2 | `/mission_chapter2_q3_qr` | `Chapter2QrVerificationScreen` | QR | Needs full SM-T595N pass |
| 3 | `/mission_chapter3_q1` | `MissionLowScreen` | rod numeral / choice | Needs full SM-T595N pass |
| 3 | `/mission_chapter3_quiz` | `Chapter3MathQuizScreen` | choice quiz | Partially updated |
| 3 | `/mission_chapter3_word_search` | `Chapter3WordSearchScreen` | hidden word board | Needs side-list layout |
| 3 | `/mission_chapter3_q2` | `MissionLowScreen` | magic square | Needs full SM-T595N pass |
| 4 | `/mission_chapter4_q1` | `BrickPuzzleScreen` | board / brick puzzle | Partially updated |
| 4 | `/mission_chapter4_quiz` | `Chapter4CodingQuizScreen` | choice quiz | Partially updated |
| 4 | `/mission_chapter4_q2` | `HiddenWordPuzzleScreen` | hidden word board | Updated |
| 4 | `/mission_chapter4_rps_qr` | `Chapter4RpsQrScreen` | QR | Partially updated |
