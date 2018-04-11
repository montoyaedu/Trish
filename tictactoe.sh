#!/bin/bash
readonly DIRNAME=/usr/bin/dirname
. $("$DIRNAME" "$0")/test_tools.sh
test
readonly NONE=_
readonly CROSS=X
readonly NOUGHT=O
readonly ORDER=3
readonly ROWS="$ORDER"
readonly MESSAGE_INDEX=10
readonly NEXT_PLAYER_INDEX=9
readonly TRUE=true
readonly FALSE=false

function asArray {
    local -r IFS=' '
    read -r -a "$1"
}

function game {
    echo _ _ _ _ _ _ _ _ _
}

function nextPlayer {
    local -r player="$1"
    if [[ "$player" == "$CROSS" ]]; then
         echo "$NOUGHT"
         return 0
    fi
    echo "$CROSS"
}

function testCanCreateGame {
    assert_that $(game) | is "_ _ _ _ _ _ _ _ _"
}

function testCanPlaceCross {
    assert_that $(game | play X 0 0) | is "X _ _ _ _ _ _ _ _ O"
}

function testCanPlaceNoughtAfterCross {
    assert_that $(game | play X 0 0 | play O 1 1) | is "X _ _ _ O _ _ _ _ X"
}

function testCannotPlaceCrossTwice {
    assert_that $(game | play X 0 0 | play X 1 1) \
    | is "X _ _ _ _ _ _ _ _ O Error=ItsNotYourTurn"
}

function testCannotPlaceNoughtIntoAnOccupiedSpace {
    assert_that $(game | play X 0 0 | play O 0 0) \
    | is "X _ _ _ _ _ _ _ _ O Error=PlaceOccupied"
}

function testInitialNextPlayer {
    assert_that $(nextPlayer) | is "X"
}

function testNextPlayerAfterCross {
    assert_that $(nextPlayer X) | is "O"
}

function testNextPlayerAfterNought {
    assert_that $(nextPlayer O) | is "X"
}

function testCanDetectWinnerAtFirstRow {
    assert_that $(game | play X 0 0 | play O 1 0 | play X 0 1 | play O 1 1 | play X 0 2 | checkWinner)  \
    | is "X X X O O _ _ _ _ O Halt=XWins"
}

function testCanDetectWinnerAtSecondRow {
    assert_that $(game | play X 1 0 | play O 0 0 | play X 1 1 | play O 0 1 | play X 1 2 | checkWinner) \
    | is "O O _ X X X _ _ _ O Halt=XWins"
}

function testCanDetectWinnerAtThirdRow {
    assert_that $(game | play X 2 0 | play O 0 0 | play X 2 1 | play O 0 1 | play X 2 2 | checkWinner) \
    | is "O O _ _ _ _ X X X O Halt=XWins"
}

function testCanDetectWinnerAtFirstColumn {
    assert_that $(game | play X 0 0 | play O 0 1 | play X 1 0 | play O 1 1 | play X 2 0 | checkWinner) \
    | is "X O _ X O _ X _ _ O Halt=XWins"
}

function testCanDetectWinnerAtSecondColumn {
    assert_that $(game | play X 0 1 | play O 0 0 | play X 1 1 | play O 1 0 | play X 2 1 | checkWinner) \
    | is "O X _ O X _ _ X _ O Halt=XWins"
}

function testCanDetectWinnerAtThirdColumn {
    assert_that $(game | play X 0 2 | play O 0 0 | play X 1 2 | play O 1 0 | play X 2 2 | checkWinner) \
    | is "O _ X O _ X _ _ X O Halt=XWins"
}

function testCanDetectWinnerAtDiagonal1 {
    assert_that $(game | play X 2 0 | play O 0 0 | play X 1 1 | play O 2 2 | play X 0 2 | checkWinner) \
    | is "O _ X _ X _ X _ O O Halt=XWins"
}

function testCanDetectWinnerAtDiagonal2 {
    assert_that $(game | play X 0 0 | play O 2 0 | play X 1 1 | play O 0 2 | play X 2 2 | checkWinner) \
    | is "X _ O _ X _ O _ X O Halt=XWins"
}

function checkWinner {
    local -r board=$(read_input)
    local arr
    asArray arr <<< "$board"
    local winner
    for index in {0..2}; do
        winner=$(echo "$board" | skip $(($index*$ORDER)) | take "$ORDER" | winner)
        if [ "$winner" != "$FALSE" ]; then
            arr["$MESSAGE_INDEX"]="Halt=${winner}Wins"
            break
        fi
    done
    if [ "$winner" == "$FALSE" ]; then
        local -r board_sorted_vertically=$(echo "$board" | sortVertically "$ORDER")
    for index in {0..2}; do
        winner=$(echo $board_sorted_vertically | skip $(($index*$ORDER)) | take "$ORDER" | winner)
        if [ "$winner" != "$FALSE" ]; then
            arr["$MESSAGE_INDEX"]="Halt=${winner}Wins"
            break
        fi
    done
    fi
    if [ "$winner" == "$FALSE" ]; then
        winner=$(echo "$board" | filterEven | skip 1 | take 3 | winner)
        if [ "$winner" != "$FALSE" ]; then
            arr["$MESSAGE_INDEX"]="Halt=${winner}Wins"
        fi
    fi
    if [ "$winner" == "$FALSE" ]; then
        winner=$(echo "$board" | filterMultipleOfFour | winner)
        if [ "$winner" != "$FALSE" ]; then
            arr["$MESSAGE_INDEX"]="Halt=${winner}Wins"
        fi
    fi
    echo "${arr[@]}"
}

function play {
    local -r board=$(read_input)
    local -r player="$1"
    local -r row="$2"
    local -r column="$3"
    local items
    asArray items <<< "$board"
    local expectedPlayer="${items[$NEXT_PLAYER_INDEX]}"
    if [ -z "$expectedPlayer" ]; then
        expectedPlayer=$(nextPlayer "$expectedPlayer")
    fi
    if [ "$player" != "$expectedPlayer" ]; then
        items["$MESSAGE_INDEX"]="Error=ItsNotYourTurn"
        echo "${items[@]}"
        return 1;
    fi
    local -r value="${items[$ROWS*$row+$column]}"
    if [ "$value" != "$NONE" ]; then
        items["$MESSAGE_INDEX"]="Error=PlaceOccupied"
        echo ${items[@]}
        return 1;
    fi
    items[$ROWS*$row+$column]="$player"
    items["$NEXT_PLAYER_INDEX"]=$(nextPlayer "$player")
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
    local -r n="$1"
    local -r s=$(read_input)
    local arr
    asArray arr <<< "$s"
    local -r head="${arr[0]}"
    local tail
    asArray tail <<< "${arr[@]:1}"
    if [ "$head" == "$NONE" ]; then
        echo 'false'
        return 0
    else
        for i in "${tail[@]}"; do
            if [ "$i" != "$head" ]; then
                echo 'false'
                return 0
            fi
        done
        echo "$head"
        return 0
    fi
    echo 'false'
    return 1
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
    assert_that $(echo _ _ _ | winner) | is false
    assert_that $(echo _ X X | winner) | is false
    assert_that $(echo X X X | winner) | is X
    assert_that $(echo O O O | winner) | is O
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

function test {
    test_all \
        testCanCreateGame \
        testCanPlaceCross \
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
