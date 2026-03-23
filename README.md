# Trish — Tic-Tac-Toe in Bash

> Tic-tac-toe implemented in Bash using a pseudo-functional style with self-contained TDD tools.

---

## Quick start

```bash
./test_tictactoe.sh
```

---

## Test results — 47 / 47 PASSED

> Last run: 2026-03-23 · Branch: `claude/analyze-test-coverage-KRPNY`

```
[PASSED] - desc_should_return_passed
[PASSED] - desc_should_return_failed
[PASSED] - id_should_return_input_string
[PASSED] - id_should_return_input_number
[PASSED] - can_compare_multiple_word_strings
[PASSED] - testLength
[PASSED] - testHasMoreTrue
[PASSED] - testHasMoreFalse
[PASSED] - testTrueFalse
[PASSED] - testTrueFalseBranchTwo        ← NEW
[PASSED] - testWhenTrue
[PASSED] - testWhenFalse
[PASSED] - testCanCreateGame
[PASSED] - testCanPlaceCross
[PASSED] - testCount
[PASSED] - testInitialNextPlayer
[PASSED] - testNextPlayerAfterCross
[PASSED] - testNextPlayerAfterNought
[PASSED] - testCannotPlaceCrossTwice
[PASSED] - testCanPlaceNoughtAfterCross
[PASSED] - testCannotPlaceNoughtIntoAnOccupiedSpace
[PASSED] - testCannotPlaceNoughtFirst    ← NEW
[PASSED] - testSkip
[PASSED] - testSkipZero                  ← NEW
[PASSED] - testTake
[PASSED] - testTakeZero                  ← NEW
[PASSED] - testWinner
[PASSED] - testCanDetectWinnerAtFirstRow
[PASSED] - testCanDetectWinnerAtSecondRow
[PASSED] - testCanDetectWinnerAtThirdRow
[PASSED] - testSortVertically
[PASSED] - testSortVerticallyAlpha
[PASSED] - testSortItemMultipleOfFour    ← NEW
[PASSED] - testSortItemEven              ← NEW
[PASSED] - testSortItemOdd               ← NEW
[PASSED] - testNearestLower4Multiple     ← NEW
[PASSED] - testNearestHigher4Multiple    ← NEW
[PASSED] - testCanDetectWinnerAtFirstColumn
[PASSED] - testCanDetectWinnerAtSecondColumn
[PASSED] - testCanDetectWinnerAtThirdColumn
[PASSED] - testFilterEven
[PASSED] - testCanDetectWinnerAtDiagonal1
[PASSED] - testFilterMultipleOfFour
[PASSED] - testCanDetectWinnerAtDiagonal2
[PASSED] - testCanDetectNoughtWinner     ← NEW
[PASSED] - testNoWinnerYet               ← NEW
[PASSED] - testDraw                      ← NEW
```

---

## Coverage map

```
Function                   Tested?   Tests
─────────────────────────────────────────────────────────
game                         YES    testCanCreateGame
play (valid)                 YES    testCanPlaceCross, testCanPlaceNoughtAfterCross
play (wrong turn)            YES    testCannotPlaceCrossTwice, testCannotPlaceNoughtFirst
play (occupied)              YES    testCannotPlaceNoughtIntoAnOccupiedSpace
nextPlayer (initial)         YES    testInitialNextPlayer
nextPlayer (after X)         YES    testNextPlayerAfterCross
nextPlayer (after O)         YES    testNextPlayerAfterNought
checkWinner (row 0)          YES    testCanDetectWinnerAtFirstRow
checkWinner (row 1)          YES    testCanDetectWinnerAtSecondRow
checkWinner (row 2)          YES    testCanDetectWinnerAtThirdRow
checkWinner (col 0)          YES    testCanDetectWinnerAtFirstColumn
checkWinner (col 1)          YES    testCanDetectWinnerAtSecondColumn
checkWinner (col 2)          YES    testCanDetectWinnerAtThirdColumn
checkWinner (diag ╲)         YES    testCanDetectWinnerAtDiagonal1
checkWinner (diag ╱)         YES    testCanDetectWinnerAtDiagonal2
checkWinner (player 2 wins)  YES    testCanDetectNoughtWinner      ← NEW
checkWinner (no winner yet)  YES    testNoWinnerYet                ← NEW
checkWinner (draw)           YES    testDraw                       ← NEW
winner                       YES    testWinner
take (n > 0)                 YES    testTake
take (n = 0)                 YES    testTakeZero                   ← NEW
skip (n > 0)                 YES    testSkip
skip (n = 0)                 YES    testSkipZero                   ← NEW
sortVertically               YES    testSortVertically, testSortVerticallyAlpha
sortItem (mult. of 4)        YES    testSortItemMultipleOfFour     ← NEW
sortItem (even)              YES    testSortItemEven               ← NEW
sortItem (odd)               YES    testSortItemOdd                ← NEW
nearestLower4Multiple        YES    testNearestLower4Multiple      ← NEW
nearestHigher4Multiple       YES    testNearestHigher4Multiple     ← NEW
filter (isEven)              YES    testFilterEven
filter (isMultipleOfFour)    YES    testFilterMultipleOfFour
count                        YES    testCount
length                       YES    testLength
hasMore (true)               YES    testHasMoreTrue
hasMore (false)              YES    testHasMoreFalse
when (true)                  YES    testWhenTrue
when (false)                 YES    testWhenFalse
trueFalse (branch 1)         YES    testTrueFalse
trueFalse (branch 2)         YES    testTrueFalseBranchTwo         ← NEW
─────────────────────────────────────────────────────────
Total functions:   39   Covered: 39 / 39   Coverage: 100%
```

---

## Improvement suggestions

### 1. Explicit draw result
`checkWinner` returns an empty string for both _"no winner yet"_ and _"draw"_.
Add a helper that checks if the board is full to distinguish the two cases:

```bash
function isBoardFull {
    local -r board=$(read_input)
    [ $(echo "$board" | count "$NONE") -eq 0 ]
}
```

### 2. Visual board renderer
Printing the raw string `1 _ _ 2 _ _ _ _ _` is hard to read during a game session.
A thin formatter would make the project immediately more usable:

```bash
function printBoard {
    local -r b=($(read_input))
    echo "+---+---+---+"
    for row in 0 1 2; do
        printf "| %s | %s | %s |\n" ${b[$((row*3))]} ${b[$((row*3+1))]} ${b[$((row*3+2))]}
        echo "+---+---+---+"
    done
}
```

### 3. Interactive game loop
Wrap game/play/checkWinner into a `gameLoop` that reads coordinates from stdin:

```bash
function gameLoop {
    local board=$(game)
    while true; do
        read -r player row col
        board=$(echo "$board" | play "$player" "$row" "$col")
        echo "$board" | printBoard
        local w=$(echo "$board" | checkWinner)
        [ -n "$w" ] && echo "Winner: $w" && break
    done
}
```

### 4. Test execution speed
The heavy use of subshells (`$(...)`) and recursive calls in `filter`/`winner`
adds noticeable overhead. Three concrete options:

| Approach | Effort | Speed gain |
|---|---|---|
| Cache `$(nextPlayer)` per test | Low | Small |
| Replace recursive `filter` with a loop | Medium | Large |
| Use `[[ ... ]]` instead of `[ ... ]` | Low | Small |

### 5. Parametric board size
`ORDER=3` is a constant, but `sortItem`'s math already generalises.
Expose it as an argument to `game` and test for a 4×4 board to prove
the invariant holds beyond 3×3.

---

## Testing technique analysis — how to reuse these patterns

### Pattern 1 — Pipe-based assertion chain

```bash
assert_that $(expr) | is "expected"
```

The `assert_that / is` pair models an **expectation builder** entirely in Bash.
`assert_that` evaluates an expression and writes its output; `is` reads from
stdin and compares. This avoids global state and is composable.

**Reusable in any Bash project** that has functions returning values through
`echo`. Examples: config parsers, file processors, CLI tools.

### Pattern 2 — Self-contained framework (no external deps)

`test_tools.sh` is sourced before game code. The framework itself has tests
(`desc_should_return_passed`, `id_should_return_input_string`, …).
This "test the tests" bootstrap gives confidence that assertion failures are
real, not framework bugs.

**Reuse tip:** copy `test_tools.sh` as a minimal dependency into any shell
project that cannot install `bats` or `shunit2`.

### Pattern 3 — Exact output testing via `is`

Game state is a string (`1 _ _ 2 _ _ _ _ _`). Tests assert the whole board
string, not just one cell. This documents the _full observable effect_ of each
operation and catches accidental side effects.

**Reuse tip:** wherever your Bash function produces a structured string (CSV
line, JSON fragment, log record), test the exact output string. Avoid partial
matching unless intentional.

### Pattern 4 — Boundary values for numeric helpers

`testSkipZero`, `testTakeZero`, `testNearestLower4Multiple` test _n = 0_ and
border values around multiples. Standard boundary-value analysis applied to
arithmetic Bash functions.

**Reuse tip:** every `$((...))` expression in shell scripts has edge cases
(integer division, modulo of 0, negative numbers). Always add a test for
_n = 0_, _n = 1_, and the first value that crosses a branch.

### Pattern 5 — Functors as first-class parameters

`filter isEven` and `filter isMultipleOfFour` pass a function name as a
string. This simulates **higher-order functions** in Bash. Tests for `sortItem`
cover all three branches of the dispatching logic independently.

**Reuse tip:** if a Bash function accepts a callback name, write one test per
callback variant. Mock the callback with a trivial echo function to isolate
the routing logic from the callback logic.

### Pattern 6 — Scenario-driven integration tests

`testCanDetectNoughtWinner`, `testDraw`, and `testNoWinnerYet` compose multiple
`play` calls into a scenario and assert the final state. This is
**scenario-based / black-box** testing layered on top of unit tests.

**Reuse tip:** after unit-testing all primitives, write at least three
scenario tests: _happy path_, _edge case_, _failure case_. For a game engine,
that maps to _someone wins_, _draw_, _invalid input_.

---

## What you might have had in mind — and where to go from here

### What you were probably thinking during development

- **Start functional, stay functional.** You chose to avoid `if/else` in favour
  of `trueFalse` + `when`, and avoided global mutable state entirely. This was
  a deliberate exploration of how far pure composition goes in Bash.
- **TDD from the very first function.** The test framework was built before (or
  alongside) the game code. The game functions were shaped by what was easy
  to assert, not the other way around.
- **Pipe as the data bus.** Every function reads from stdin and writes to
  stdout. This mirrors the Unix philosophy and allows arbitrary chaining:
  `game | play 1 0 0 | play 2 1 1 | checkWinner`.
- **`sortVertically` as the cleverness peak.** The index-math trick in
  `sortItem` (using nearest multiples of 4) is the most non-obvious piece.
  You probably spent the most design time here.

### What you could do right now to move forward

1. **Add a `checkDraw` function** that returns `"draw"` when the board is full
   and `checkWinner` is empty. One test needed: `testCheckDraw`.

2. **Write a game loop script** (`play.sh`) that calls `gameLoop` and lets two
   humans play in a terminal — the engine is complete, only the UI wrapper is
   missing.

3. **Write the tutorial** (listed in TODO). The commit history and test names
   already tell the story; the tutorial would be: one test → one function →
   next test. The pipe-based style is genuinely unusual and worth documenting.

4. **Publish to GitHub Pages or similar** with an automatically updated test
   badge. The CI pipeline would be: `bash test_tictactoe.sh | tee results.txt`,
   with the result embedded in the README via a GitHub Action.

5. **Profile the test run** (`time bash test_tictactoe.sh`) and identify the
   slowest three tests. Replace the recursive `filter` with a loop and measure
   the speedup — this directly addresses the "Test execution is slow" TODO.

6. **Generalise to N×N** — try `ORDER=4` and add `testCanDetectWinnerAtRow_4x4`.
   The sortItem math already hints at a general formula.

---

## Similar projects and useful resources

### Bash testing frameworks

| Project | URL | Notes |
|---|---|---|
| **Bats** | https://github.com/sstephenson/bats | Most widely used; TAP-compliant output; natural fit for TDD on shell scripts |
| **shUnit2** | https://github.com/kward/shunit2 | xUnit-style (`assertEquals`); familiar to JUnit/PyUnit users |
| **ShellSpec** | https://shellspec.info/comparison.html | Side-by-side framework comparison; great for choosing the right tool |
| **testing-in-bash** | https://github.com/dodie/testing-in-bash | Same tests written in multiple frameworks; practical reference |

### Tic-tac-toe in Bash

| Project | URL | Notes |
|---|---|---|
| **justineuro/tic-tac-toe** | https://github.com/justineuro/tic-tac-toe | Two-player, terminal colours; good reference for board rendering |
| **TicTacToe-Players (minimax)** | https://github.com/andrewgph/TicTacToe-Players | Recursive minimax AI in Bash; technically closest to this project's recursive style |

### Functional programming in Bash

| Resource | URL | Notes |
|---|---|---|
| **Functional Programming in Bash** | https://scalastic.io/en/bash-functional-programming/ | Covers pure functions, immutability, higher-order `map` in Bash |
| **Collection Pipeline — Martin Fowler** | https://martinfowler.com/articles/collection-pipeline/ | Canonical article on filter/map/reduce that Unix pipes directly implement |
| **FP is Like Unix Pipelines** | https://alvinalexander.com/scala/fp-book/how-functional-programming-is-like-unix-pipelines/ | Explains the conceptual mapping between pipes and function composition |
| **I want my Bash Pipe** | https://dev.to/xtofl/i-want-my-bash-pipe-34i2 | Practical patterns for chaining transformations in shell — directly applicable here |

---

## Architecture overview

```
stdin ──► game ──► play ──► play ──► ... ──► checkWinner ──► stdout
              │         │                         │
              │   nextPlayer (validation)          │
              │   count / when / trueFalse         │
              │                             sortVertically
              │                             filter isEven
              │                             filter isMultipleOfFour
              │                             winner (recursive)
              └─ board: space-separated 9-cell string (immutable)
```

All state flows through stdout. No global variables are mutated after init.

---

## TODO

1. Add `checkDraw` function and tests
2. Document the process of analysis and implementation (tutorial)
3. Build interactive game loop (`play.sh`)
4. Fix test execution speed (profile + replace recursive `filter` with loop)
5. Generalise to N×N board
6. Add CI badge with auto-updated test results
