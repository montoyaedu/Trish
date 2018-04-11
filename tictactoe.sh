#!/bin/bash
readonly DIRNAME=/usr/bin/dirname
. $("$DIRNAME" "$0")/test_tools.sh
test
readonly NONE=_
readonly CROSS=1
readonly NOUGHT=2
readonly ORDER=3
readonly ROWS="$ORDER"
readonly MESSAGE_INDEX=9
readonly FALSE=0

function asArray {
    local -r IFS=' '
    read -r -a "$1"
}

function game {
    echo _ _ _ _ _ _ _ _ _
}

function nextPlayer {
    # if number of placed figures are equal is X turn otherwise is O turn
    local -r board=$(read_input)
    when $(($(echo "$board" | count "$CROSS")==$(echo "$board" | count "$NOUGHT"))) | trueFalse "echo $CROSS" "echo $NOUGHT"
}

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
    | is "1 _ _ _ _ _ _ _ _ ItsNotYourTurn"
}

function testCannotPlaceNoughtIntoAnOccupiedSpace {
    assert_that $(game | play 1 0 0 | play 2 0 0) \
    | is "1 _ _ _ _ _ _ _ _ PlaceOccupied"
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

function checkWinner {
    local -r board=$(read_input)
    local -r board_sorted_vertically=$(echo "$board" | sortVertically "$ORDER")
    local -r diag1=$(echo "$board" | filterEven | skip 1 | take 3)
    local -r diag2=$(echo "$board" | filterMultipleOfFour)
    echo $(echo "$board" | winner)
}

function play {
    local -r board=$(read_input)
    local -r player="$1"
    local -r row="$2"
    local -r column="$3"
    local items
    asArray items <<< "$board"
    if [ "$player" != $(echo "$board" | nextPlayer) ]; then
        items["$MESSAGE_INDEX"]="ItsNotYourTurn"
        echo "${items[@]}"
        return 1;
    fi
    local -r value="${items[$ROWS*$row+$column]}"
    if [ "$value" != "$NONE" ]; then
        items["$MESSAGE_INDEX"]="PlaceOccupied"
        echo ${items[@]}
        return 1;
    fi
    items[$ROWS*$row+$column]="$player"
    echo "${items[@]}"
}

function take {
    local -r n="$1"
    local arr
    asArray arr <<< $(read_input)
    echo "${arr[@]::$n}"
}

function skip {
    local -r n="$1"
    local arr
    asArray arr <<< $(read_input)
    echo "${arr[@]:$n}"
}

function winner {
    local -r s=$(read_input | take $ORDER)
    local arr
    asArray arr <<< "$s"
    local -r head="${arr[0]}"
    local tail
    asArray tail <<< "${arr[@]:1}"
    if [ "$head" == "$NONE" ]; then
        echo $(echo $s | skip $ORDER | winner)
    else
        for i in "${tail[@]}"; do
            if [ "$i" != "$head" ]; then
                echo $(echo $s | skip $ORDER | winner)
            fi
        done
        echo "$head"
    fi
    echo $(echo $s | skip $ORDER | winner)
}

function testSkip {
    assert_that $(echo AAA BBB CCC DDD | skip 1) | is "BBB CCC DDD"
    assert_that $(echo AAA BBB CCC DDD | skip 3) | is "DDD"
}

function testTake {
    assert_that $(echo AAA BBB CCC DDD | take 1) | is "AAA"
    assert_that $(echo AAA BBB CCC DDD | take 3) | is "AAA BBB CCC"
    assert_that $(echo AAA BBB CCC DDD | take 4) | is "AAA BBB CCC DDD"
}

function testWinner {
    assert_that $(echo _ _ _ | winner) | is 0
    assert_that $(echo _ 1 1 | winner) | is 0
    assert_that $(echo 1 1 1 | winner) | is 1
    assert_that $(echo 2 2 2 | winner) | is 2
}

function sortVertically {
    local -r cells_per_side="$1"
    local -r g=$(read_input | take $(($cells_per_side*$cells_per_side)))
    local arr
    local returnArr
    asArray arr <<< "$g"
    for index in {0..8}; do
       local item="${arr[$index]}"
       returnArr["$index"]=$(sortItem "$index" "${arr[@]}")
    done
    echo "${returnArr[@]}"
}

function sortItem {
    local arr
    asArray arr <<< $(echo "$@" | skip 1)
    local -r i="$1"
    if isMultipleOfFour "$i"; then
        echo "${arr[$i]}"
        return 0
    fi
    if isEven "$i"; then
        echo "${arr[$((8-$i))]}"
        return 0
    fi
    local -r lo4=$(nearestLower4Multiple "$i")
    local -r hi4=$(nearestHigher4Multiple "$i")
    local -r sum=$(($lo4+$hi4))
    echo "${arr[$(($sum-$i))]}"
}

function nearestLower4Multiple {
    echo $(($1/4*4))
}

function nearestHigher4Multiple {
    echo $((($1+4-1)/4*4))
}

function isMultipleOfFour {
    return $(($1%4))
}

function isEven {
    return $(($1%2))
}

function testSortVertically {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | sortVertically 3) | is "0 3 6 1 4 7 2 5 8"
}

function testSortVerticallyAlpha {
    assert_that $(echo A B C D E F G H I | sortVertically 3) | is "A D G B E H C F I"
}

function testFilterEven {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | filterEven) | is "0 2 4 6 8"
}

function testFilterMultipleOfFour {
    assert_that $(echo 0 1 2 3 4 5 6 7 8 | filterMultipleOfFour) | is "0 4 8"
}

function filterMultipleOfFour {
    local arr
    local returnArr
    asArray arr <<< $(read_input)
    for index in {0..8}; do
        if isMultipleOfFour "$index"; then
            returnArr+=("${arr[$index]}")
        fi
    done
    echo ${returnArr[@]}
}

function filterEven {
    local arr
    local returnArr
    asArray arr <<< $(read_input)
    for index in {0..8}; do
        if isEven "$index"; then
            returnArr+=("${arr[$index]}")
        fi
    done
    echo ${returnArr[@]}
}

function count {
    local arr
    asArray arr <<< $(read_input)
    local count=0
    declare value
    for value in ${arr[@]}; do
        if [[ "$value" == "$1" ]]; then
            count=$((count+1))
        fi
    done
    echo "$count"
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

function when {
    echo $(($1==0))
    return 0
}

function trueFalse {
    if [[ $(read_input) -eq 0 ]]; then eval "$1"; else eval "$2"; fi
}

function testTrueFalse {
    assert_that $(echo 0 | trueFalse "echo A" "echo B") | is A
}

function test {
    test_all \
        testTrueFalse \
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
        testSkip \
        testTake \
        testWinner \
        testCanDetectWinnerAtFirstRow \
        testCanDetectWinnerAtSecondRow \
        testCanDetectWinnerAtThirdRow \
        testSortVertically \
        testSortVerticallyAlpha \
        testCanDetectWinnerAtFirstColumn \
        testCanDetectWinnerAtSecondColumn \
        testCanDetectWinnerAtThirdColumn \
        testFilterEven \
        testCanDetectWinnerAtDiagonal1 \
        testFilterMultipleOfFour \
        testCanDetectWinnerAtDiagonal2
}

test
