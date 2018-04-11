#!/bin/bash
PATH=
DIRNAME=/usr/bin/dirname
. $("$DIRNAME" "$0")/test_tools.sh
test
NONE=None
CROSS=Cross
NOUGHT=Nought
ORDER=3
ROWS="$ORDER"
MESSAGE_INDEX=10
TRUE=true
FALSE=false

function asArray {
    local IFS=' '
    read -r -a "$1"
}

function game {
    local board
    board=(None None None None None None None None None)
    echo "${board[@]}"
}

function nextPlayer {
    local player="$1"
    if [[ "$player" == "$CROSS" ]]; then
         echo "$NOUGHT"
         return 0
    fi
    echo "$CROSS"
}

function testCanCreateGame {
    local g
    g=$(game) || return "$?"
    assert_that "${g[@]}" | is "None None None None None None None None None"
}

function testCanPlaceCross {
    local g
    g=$(game | place Cross 0 0) || return "$?"
    assert_that "$g" | is "Cross None None None None None None None None Nought"
}

function testCanPlaceNoughtAfterCross {
    local g
    g=$(game | place Cross 0 0 | place Nought 1 1) || return "$?"
    assert_that "$g" | is "Cross None None None Nought None None None None Cross"
}

function testCannotPlaceCrossTwice {
    local g
    g=$(game | place Cross 0 0 | place Cross 1 1)
    assert_that "$?" | is 1
    assert_that "$g" | is "Cross None None None None None None None None Nought Error=ItsNotYourTurn"
}

function testCannotPlaceNoughtIntoAnOccupiedSpace {
    local g
    g=$(game | place Cross 0 0 | place Nought 0 0)
    assert_that "$?" | is 1
    assert_that "$g" | is "Cross None None None None None None None None Nought Error=PlaceOccupied"
}

function testInitialNextPlayer {
    assert_that $(nextPlayer) | is "Cross"
}

function testNextPlayerAfterCross {
    assert_that $(nextPlayer Cross) | is "Nought"
}

function testNextPlayerAfterNought {
    assert_that $(nextPlayer Nought) | is "Cross"
}

function testCanDetectWinnerAtFirstRow {
    local g
    g=$(game | place Cross 0 0 | place Nought 1 0 | place Cross 0 1 | place Nought 1 1 | place Cross 0 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Cross Cross Cross Nought Nought None None None None Nought Halt=CrossWins"
}

function testCanDetectWinnerAtSecondRow {
    local g
    g=$(game | place Cross 1 0 | place Nought 0 0 | place Cross 1 1 | place Nought 0 1 | place Cross 1 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Nought Nought None Cross Cross Cross None None None Nought Halt=CrossWins"
}

function testCanDetectWinnerAtThirdRow {
    local g
    g=$(game | place Cross 2 0 | place Nought 0 0 | place Cross 2 1 | place Nought 0 1 | place Cross 2 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Nought Nought None None None None Cross Cross Cross Nought Halt=CrossWins"
}

function testCanDetectWinnerAtFirstColumn {
    local g
    g=$(game | place Cross 0 0 | place Nought 0 1 | place Cross 1 0 | place Nought 1 1 | place Cross 2 0 | checkWinner) || return "$?"
    assert_that "$g" | is "Cross Nought None Cross Nought None Cross None None Nought Halt=CrossWins"
}

function testCanDetectWinnerAtSecondColumn {
    local g
    g=$(game | place Cross 0 1 | place Nought 0 0 | place Cross 1 1 | place Nought 1 0 | place Cross 2 1 | checkWinner) || return "$?"
    assert_that "$g" | is "Nought Cross None Nought Cross None None Cross None Nought Halt=CrossWins"
}

function testCanDetectWinnerAtThirdColumn {
    local g
    g=$(game | place Cross 0 2 | place Nought 0 0 | place Cross 1 2 | place Nought 1 0 | place Cross 2 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Nought None Cross Nought None Cross None None Cross Nought Halt=CrossWins"
}

function testCanDetectWinnerAtDiagonal1 {
    local g
    g=$(game | place Cross 2 0 | place Nought 0 0 | place Cross 1 1 | place Nought 2 2 | place Cross 0 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Nought None Cross None Cross None Cross None Nought Nought Halt=CrossWins"
}

function testCanDetectWinnerAtDiagonal2 {
    local g
    g=$(game | place Cross 0 0 | place Nought 2 0 | place Cross 1 1 | place Nought 0 2 | place Cross 2 2 | checkWinner) || return "$?"
    assert_that "$g" | is "Cross None Nought None Cross None Nought None Cross Nought Halt=CrossWins"
}

function checkWinner {
    local board=$(read_input)
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
        local board_sorted_vertically=$(echo "$board" | sortVertically "$ORDER")
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

function place {
    local board=$(read_input)
    local player="$1"
    local row="$2"
    local column="$3"
    local items
    asArray items <<< "$board"
    local expectedPlayer="${items[9]}"
    if [ -z "$expectedPlayer" ]; then
        expectedPlayer=$(nextPlayer "$expectedPlayer")
    fi
    if [ "$player" != "$expectedPlayer" ]; then
        items["$MESSAGE_INDEX"]="Error=ItsNotYourTurn"
        echo "${items[@]}"
        return 1;
    fi
    local value="${items[$ROWS*$row+$column]}"
    if [ "$value" != "$NONE" ]; then
        items["$MESSAGE_INDEX"]="Error=PlaceOccupied"
        echo ${items[@]}
        return 1;
    fi
    items[$ROWS*$row+$column]="$player"
    items[9]=$(nextPlayer "$player")
    echo "${items[@]}"
}

function take {
    local n="$1"
    local arr
    asArray arr <<< $(read_input)
    echo "${arr[@]::$n}"
}

function skip {
    local n="$1"
    local arr
    asArray arr <<< $(read_input)
    echo "${arr[@]:$n}"
}

function winner {
    local n="$1"
    local s=$(read_input)
    local arr
    asArray arr <<< "$s"
    local head="${arr[0]}"
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
    local g
    g=$(echo AAA BBB CCC DDD | skip 1) || return "$?"
    assert_that "$g" | is "BBB CCC DDD"
    g=$(echo AAA BBB CCC DDD | skip 3) || return "$?"
    assert_that "$g" | is "DDD"
}

function testTake {
    local g
    g=$(echo AAA BBB CCC DDD | take 1) || return "$?"
    assert_that "$g" | is "AAA"
    g=$(echo AAA BBB CCC DDD | take 3) || return "$?"
    assert_that "$g" | is "AAA BBB CCC"
    g=$(echo AAA BBB CCC DDD | take 4) || return "$?"
    assert_that "$g" | is "AAA BBB CCC DDD"
}

function testWinner {
    local g
    g=$(echo None None None | winner) || return "$?"
    assert_that "$g" | is false
    g=$(echo None Cross Cross | winner) || return "$?"
    assert_that "$g" | is false
    g=$(echo Cross Cross Cross | winner) || return "$?"
    assert_that "$g" | is Cross
    g=$(echo Nought Nought Nought | winner) || return "$?"
    assert_that "$g" | is Nought
}

function sortVertically {
    local cells_per_side="$1"
    local g
    g=$(read_input | take $(($cells_per_side*$cells_per_side)))
    local arr
    local returnArr
    asArray arr <<< "$g"
    for index in {0..8}; do
       local item
       item="${arr[$index]}"
       returnArr["$index"]=$(sortItem "$index" "${arr[@]}")
    done
    echo "${returnArr[@]}"
}

function sortItem {
    local i
    local arr
    asArray arr <<< $(echo "$@" | skip 1)
    i="$1"
    if isMultipleOfFour "$i"; then
        echo "${arr[$i]}"
        return 0
    fi
    if isEven "$i"; then
        echo "${arr[$((8-$i))]}"
        return 0
    fi
    local lo4
    local hi4
    local sum
    lo4=$(nearestLower4Multiple "$i")
    hi4=$(nearestHigher4Multiple "$i")
    sum=$(($lo4+$hi4))
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
    local g
    g=$(echo 0 1 2 3 4 5 6 7 8 | sortVertically 3) || return "$?"
    assert_that "$g" | is "0 3 6 1 4 7 2 5 8"
}

function testSortVerticallyAlpha {
    local g
    g=$(echo A B C D E F G H I | sortVertically 3) || return "$?"
    assert_that "$g" | is "A D G B E H C F I"
}

function testFilterEven {
    local g
    g=$(echo 0 1 2 3 4 5 6 7 8 | filterEven) || return "$?"
    assert_that "$g" | is "0 2 4 6 8"
}

function testFilterMultipleOfFour {
    local g
    g=$(echo 0 1 2 3 4 5 6 7 8 | filterMultipleOfFour) || return "$?"
    assert_that "$g" | is "0 4 8"
}

function filterMultipleOfFour {
    local g
    local arr
    g=$(read_input)
    asArray arr <<< "$g"
    for index in {0..8}; do
        if isMultipleOfFour "$index"; then
            echo "${arr[$index]}"
        fi
    done
}

function filterEven {
    local g
    local arr
    g=$(read_input)
    asArray arr <<< "$g"
    for index in {0..8}; do
        if isEven "$index"; then
            echo "${arr[$index]}"
        fi
    done
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
