# Tablet Problem Layout Development Plan

Target device: Samsung Galaxy Tab SM-T595N, landscape 16:10.

## Goal

Bring every problem screen to the same SM-T595N layout standard, not only the representative screens.

The final app should:

- Fit within one landscape tablet screen without accidental overflow.
- Keep the main problem board or interaction area visually dominant.
- Use consistent top navigation and bottom action controls.
- Keep debug skip controls in the app bar, not in the content or bottom action bar.
- Avoid tiny reference visuals, clipped previews, and isolated score/status blocks.

## Current Status

Some representative screens have been improved, but the full chapter-by-chapter pass is not complete.

Completed or mostly completed:

- Chapter 2 seesaw puzzle: redesigned with compact balance bar, split left/right scores, and top-right debug skip.
- Chapter 4 hidden word puzzle: redesigned as left word list plus larger right board.
- Chapter 3 hidden word puzzle: updated to the same left word list plus larger right board structure.
- Chapter 2 pattern puzzle target preview: fixed clipped target preview by replacing GridView preview with fixed 4x4 rendering.
- Debug skip buttons: moved away from bottom action bars on the main problem screens touched so far.

Not complete:

- MissionLowScreen common layouts are not fully standardized.
- Chapter 2 pattern puzzle full layout still needs a complete pass.
- QR screens need final type-level review.
- Brick puzzle screens need a full pass, especially board size, tool placement, and action placement.
- Choice quiz screens need final 2x2/tablet consistency check.

## Problem Inventory

| Chapter | Route | Screen | Type | Current State | Required Work |
| --- | --- | --- | --- | --- | --- |
| 1 | `/mission_low` | `MissionLowScreen` | Tessellation shape choice | Partially improved | Recheck prompt height, board priority, shape choice card sizing, result copy placement |
| 1 | `/mission_ch1_q2` | `MissionLowScreen` | Hanoi visual + choice | Not fully reviewed | Fit visual and choices without scroll-heavy layout, keep choices readable |
| 2 | `/mission_chapter2_q1` | `SeesawPuzzleScreen` | Balance board | Updated | Visual QA on SM-T595N size, verify no overflow |
| 2 | `/mission_chapter2_q2` | `Chapter2PuzzleQ2Screen` in `main.dart` | Pattern board puzzle | Updated | Left step panel + center board + right target/tray layout applied, target preview overflow fixed |
| 2 | `/mission_chapter2_q3_qr` | `Chapter2QrVerificationScreen` in `main.dart` | QR verification | Not fully reviewed | Move debug skip to app bar if needed, reduce debug/manual elements so layout stays stable |
| 3 | `/mission_chapter3_q1` | `MissionLowScreen` | Rod numeral + choice | Not fully reviewed | Ensure visual and 4-choice row fit in tablet landscape |
| 3 | `/mission_chapter3_quiz` | `Chapter3MathQuizScreen` | Choice quiz | Partially improved | Verify 4-choice rhythm and prompt/choice balance |
| 3 | `/mission_chapter3_word_search` | `Chapter3WordSearchScreen` | Hidden word board | Updated | Visual QA on SM-T595N size |
| 3 | `/mission_chapter3_q2` | `MissionLowScreen` | Magic square | Not fully reviewed | Board-first layout, keypad/answer controls fit, avoid oversized prompt |
| 4 | `/mission_chapter4_q1` | `BrickPuzzleScreen` | Brick board puzzle | Partially improved | Full board/tray pass, reduce prompt height, verify target boards and reusable pieces |
| 4 | `/mission_chapter4_quiz` | `Chapter4CodingQuizScreen` | Choice quiz | Partially improved | Confirm exactly 4 choices, stable 2x2 layout |
| 4 | `/mission_chapter4_q2` | `HiddenWordPuzzleScreen` | Hidden word board | Updated | Visual QA on SM-T595N size |
| 4 | `/mission_chapter4_rps_qr` | `Chapter4RpsQrScreen` | QR verification | Partially improved | Final QR type review, manual fallback text and layout stability |

## Layout Standards To Apply

### Shared

- App bar title remains `미션! 수학체험센터의 반짝별을 찾아서`.
- App bar action order in debug builds: sound, home, skip.
- Bottom action bar contains only learner actions.
- Debug skip must never add height to the content area.
- Prompt band should be compact and should not consume more space than the board.
- Cards use restrained radius, usually 6-10 px.
- Avoid nested cards where possible.

### Board Type

Use for tessellation, seesaw, hidden word, brick, pattern, magic square.

- Board or interaction area should be the largest element.
- Side tools should use clamped width, usually 240-340 px.
- Secondary information should sit near the related board side, not in the center unless it compares both sides.
- No important reference image may be clipped.

### Choice Type

Use for math quiz and coding quiz.

- Use 4 choices.
- Prefer stable 2x2 choice grid on tablet landscape.
- Avoid oversized question card if it compresses choices.

### QR Type

Use for chapter 2 and chapter 4 QR verification.

- QR scanner or QR confirmation area is the primary object.
- Manual input is fallback only.
- Do not reveal or invent answer strings in the UI unless the real-world flow requires it.

## Implementation Order

1. MissionLowScreen common layout audit and refactor
   - Tessellation shape choice
   - Hanoi visual
   - Rod numeral
   - Magic square

2. Chapter 2 pattern puzzle full layout pass
   - Remove or compress redundant step chips
   - Ensure target preview and tray are not clipped
   - Make board visually dominant

3. Brick puzzle layout pass
   - Chapter 4 brick puzzle first because it is routed
   - Check whether chapter 1 standalone brick file is still used; avoid spending time on unused code unless needed

4. QR screen pass
   - Chapter 2 QR in `main.dart`
   - Chapter 4 QR in `chapter4_rps_qr_screen.dart`

5. Choice quiz final pass
   - Chapter 3 math quiz
   - Chapter 4 coding quiz

6. Verification
   - `dart format`
   - `flutter analyze`
   - `flutter run -d emulator-5554 --no-resident`
   - Manual visual check on SM-T595N or matching 16:10 tablet screenshot

## Acceptance Checklist

Each problem screen is complete only when:

- It fits in landscape without unwanted scrolling or clipped elements.
- The main interactive area is visually dominant.
- Learner controls are consistent and reachable.
- Debug skip appears only in the app bar.
- Reference visuals and target images are fully visible.
- Text does not overlap or overflow.
- The layout still works when the debug skip icon is visible.
- The screen has been checked against the problem inventory table.

## Notes

- Do not build the final APK until this plan is complete.
- Do not mark the UI pass complete after only representative screens.
- Commit in meaningful groups, preferably by screen type or chapter.
