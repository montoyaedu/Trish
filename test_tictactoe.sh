#!/bin/bash
readonly DIRNAME=/usr/bin/dirname
. $("$DIRNAME" "$0")/test_tools.sh
. $("$DIRNAME" "$0")/tictactoe.sh

function testCanCreateGame {
    assert_that $(game) | is "_ _ _ _ _ _ _ _ _"
}

function testCanPlaceCross {
    assert_that $(game | play 1 0 0) | is "1 _ _ _ _ _ _ _ _"
}

function testCanPlaceNoughtAfterCross {
    assert_that $(game | play 1 0 0 | play 2 1 1) | is "1 _ _ _ 2 _ _ _ _"
}

function testCannotPlaceCrossTwice {
    assert_that $(game | play 1 0 0 | play 1 1 1) \
    | is "1 _ _ _ _ _ _ _ _"
}

function testCannotPlaceNoughtIntoAnOccupiedSpace {
    assert_that $(game | play 1 0 0 | play 2 0 0) \
    | is "1 _ _ _ _ _ _ _ _"
}

function testCannotPlaceNoughtFirst {
    assert_that $(game | play 2 0 0) | is "_ _ _ _ _ _ _ _ _"
}

function testInitialNextPlayer {
    assert_that $(echo _ _ _ _ _ _ _ _ _ | nextPlayer) | is "1"
}

function testNextPlayerAfterCross {
    assert_that $(echo 1 _ _ _ _ _ _ _ _ | nextPlayer) | is "2"
}

function testNextPlayerAfterNought {
    assert_that $(echo 1 2 _ _ _ _ _ _ _ | nextPlayer) | is "1"
}

function testCanDetectWinnerAtFirstRow {
    assert_that $(game | play 1 0 0 | play 2 1 0 | play 1 0 1 | play 2 1 1 | play 1 0 2 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtSecondRow {
    assert_that $(game | play 1 1 0 | play 2 0 0 | play 1 1 1 | play 2 0 1 | play 1 1 2 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtThirdRow {
    assert_that $(game | play 1 2 0 | play 2 0 0 | play 1 2 1 | play 2 0 1 | play 1 2 2 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtFirstColumn {
    assert_that $(game | play 1 0 0 | play 2 0 1 | play 1 1 0 | play 2 1 1 | play 1 2 0 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtSecondColumn {
    assert_that $(game | play 1 0 1 | play 2 0 0 | play 1 1 1 | play 2 1 0 | play 1 2 1 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtThirdColumn {
    assert_that $(game | play 1 0 2 | play 2 0 0 | play 1 1 2 | play 2 1 0 | play 1 2 2 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtDiagonal1 {
    assert_that $(game | play 1 2 0 | play 2 0 0 | play 1 1 1 | play 2 2 2 | play 1 0 2 | checkWinner) \
    | is 1
}

function testCanDetectWinnerAtDiagonal2 {
    assert_that $(game | play 1 0 0 | play 2 2 0 | play 1 1 1 | play 2 0 2 | play 1 2 2 | checkWinner) \
    | is 1
}

function testCanDetectNoughtWinner {
    assert_that $(game | play 1 0 0 | play 2 1 0 | play 1 0 1 | play 2 1 1 | play 1 2 2 | play 2 1 2 | checkWinner) \
    | is 2
}

function testNoWinnerYet {
    assert_that "$(game | play 1 0 0 | play 2 1 1 | checkWinner)" | is ''
}

function testDraw {
    assert_that "$(game | play 1 0 0 | play 2 0 1 | play 1 0 2 | play 2 1 1 | play 1 1 0 | play 2 1 2 | play 1 2 1 | play 2 2 0 | play 1 2 2 | checkWinner)" \
    | is ''
}

function testCheckDraw {
    assert_that "$(game | play 1 0 0 | play 2 0 1 | play 1 0 2 | play 2 1 1 | play 1 1 0 | play 2 1 2 | play 1 2 1 | play 2 2 0 | play 1 2 2 | checkDraw)" \
    | is 'draw' && \
    assert_that "$(game | play 1 0 0 | play 2 1 1 | checkDraw)" | is ''
}

function testSkip {
    assert_that $(echo AAA BBB CCC DDD | skip 1) | is "BBB CCC DDD"
    assert_that $(echo AAA BBB CCC DDD | skip 3) | is "DDD"
}

function testSkipZero {
    assert_that $(echo AAA BBB CCC | skip 0) | is "AAA BBB CCC"
}

function testTake {
    assert_that $(echo AAA BBB CCC DDD | take 1) | is "AAA"
    assert_that $(echo AAA BBB CCC DDD | take 3) | is "AAA BBB CCC"
    assert_that $(echo AAA BBB CCC DDD | take 4) | is "AAA BBB CCC DDD"
}

function testTakeZero {
    assert_that "$(echo AAA BBB CCC | take 0)" | is ''
}

function testWinner {
    assert_that $(echo _ _ _ | winner) | is '' && \
    assert_that $(echo _ 1 1 | winner) | is '' && \
    assert_that $(echo 1 1 1 | winner) | is 1 && \
    assert_that $(echo 2 2 2 | winner) | is 2
}

function testSortVertically {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | sortVertically) | is "0 3 6 1 4 7 2 5 8"
}

function testSortVerticallyAlpha {
    assert_that $(echo A B C D E F G H I | sortVertically) | is "A D G B E H C F I"
}

function testSortItemMultipleOfFour {
    assert_that $(sortItem 0 A B C D E F G H I) | is "A"
}

function testSortItemEven {
    assert_that $(sortItem 2 A B C D E F G H I) | is "G"
}

function testSortItemOdd {
    assert_that $(sortItem 1 A B C D E F G H I) | is "D"
}

function testNearestLower4Multiple {
    assert_that $(nearestLower4Multiple 1) | is 0 && \
    assert_that $(nearestLower4Multiple 3) | is 0 && \
    assert_that $(nearestLower4Multiple 5) | is 4
}

function testNearestHigher4Multiple {
    assert_that $(nearestHigher4Multiple 1) | is 4 && \
    assert_that $(nearestHigher4Multiple 3) | is 4 && \
    assert_that $(nearestHigher4Multiple 5) | is 8
}

function testFilterEven {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | filter isEven) | is "0 2 4 6 8"
}

function testFilterMultipleOfFour {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | filter isMultipleOfFour) | is "0 4 8"
}

function testCount {
    assert_that $(echo A A B B C C | count A) | is 2 && \
    assert_that $(echo A A B B C C | count D) | is 0
}

function testWhenFalse {
    assert_that "$(when 1)" | is 0
}

function testWhenTrue {
    assert_that "$(when 0)" | is 1
}

function testTrueFalse {
    assert_that $(echo 0 | trueFalse "echo A" "echo B") | is A
}

function testTrueFalseBranchTwo {
    assert_that $(echo 1 | trueFalse "echo A" "echo B") | is B
}

function testHasMoreTrue {
    hasMore 1 2 3
    local -r r=$?
    assert_that "$r" | is 0
}

function testHasMoreFalse {
    hasMore 1
    local -r r=$?
    assert_that "$r" | is 1
}

function testLength {
    assert_that $(echo 1 2 3 | length) | is 3 && \
    assert_that $(echo 2 3 | length) | is 2 && \
    assert_that $(echo 3 | length) | is 1 && \
    assert_that $(echo | length) | is 0 
}

function test {
    test_all \
        testLength \
        testHasMoreTrue \
        testHasMoreFalse \
        testTrueFalse \
        testTrueFalseBranchTwo \
        testWhenTrue \
        testWhenFalse \
        testCanCreateGame \
        testCanPlaceCross \
        testCount \
        testInitialNextPlayer \
        testNextPlayerAfterCross \
        testNextPlayerAfterNought \
        testCannotPlaceCrossTwice \
        testCanPlaceNoughtAfterCross \
        testCannotPlaceNoughtIntoAnOccupiedSpace \
        testCannotPlaceNoughtFirst \
        testSkip \
        testSkipZero \
        testTake \
        testTakeZero \
        testWinner \
        testCanDetectWinnerAtFirstRow \
        testCanDetectWinnerAtSecondRow \
        testCanDetectWinnerAtThirdRow \
        testSortVertically \
        testSortVerticallyAlpha \
        testSortItemMultipleOfFour \
        testSortItemEven \
        testSortItemOdd \
        testNearestLower4Multiple \
        testNearestHigher4Multiple \
        testCanDetectWinnerAtFirstColumn \
        testCanDetectWinnerAtSecondColumn \
        testCanDetectWinnerAtThirdColumn \
        testFilterEven \
        testCanDetectWinnerAtDiagonal1 \
        testFilterMultipleOfFour \
        testCanDetectWinnerAtDiagonal2 \
        testCanDetectNoughtWinner \
        testNoWinnerYet \
        testDraw \
        testCheckDraw
}

test
