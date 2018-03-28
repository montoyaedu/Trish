# Trish

tic-tac-toe implemented in Bash using kinda pseudo functional style with self contained TDD tools.

Work in progress. some tests are yet failing.

## Try it:

```
    ./tictactoe.sh
```

## Current result:

```
[PASSED] - desc_should_return_passed
[PASSED] - desc_should_return_failed
[PASSED] - id_should_return_input_string
[PASSED] - id_should_return_input_number
[PASSED] - can_compare_multiple_word_strings
[PASSED] - testCanCreateGame
[PASSED] - testCanPlaceCross
[PASSED] - testInitialNextPlayer
[PASSED] - testNextPlayerAfterCross
[PASSED] - testNextPlayerAfterNought
[PASSED] - testCannotPlaceCrossTwice
[PASSED] - testCanPlaceNoughtAfterCross
[PASSED] - testCannotPlaceNoughtIntoAnOccupiedSpace
[PASSED] - testSkip
[PASSED] - testTake
[PASSED] - testWinner
[PASSED] - testCanDetectWinnerAtFirstRow
[PASSED] - testCanDetectWinnerAtSecondRow
[PASSED] - testCanDetectWinnerAtThirdRow
expected '0 3 6 1 4 7 2 5 8' but got '0 1 2 3 4 5 6 7 8'
[FAILED] - testSortVertically
expected 'Cross Nought None Cross Nought None Cross None None Nought Halt=CrossWins' but got 'Cross Nought None Cross Nought None Cross None None Nought'
[FAILED] - testCanDetectWinnerAtFirstColumn
```

## TODO:

1. Fix failing tests.
2. Document the process of analysis and implementation.
3. Make a tutorial.
