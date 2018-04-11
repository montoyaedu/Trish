#!/bin/bash
readonly NONE=_
readonly CROSS=1
readonly NOUGHT=2
readonly ORDER=3

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

function checkWinner {
    local -r board=$(read_input)
    local -r board_sorted_vertically=$(echo "$board" | sortVertically)
    local -r diag1=$(echo "$board" | filterEven | skip 1 | take 3)
    local -r diag2=$(echo "$board" | filterMultipleOfFour)
    echo $(echo "$board $board_sorted_vertically $diag1 $diag2" | winner)
}

function play {
    local -r board=$(read_input)
    local -r player="$1"
    local -r row="$2"
    local -r column="$3"
    local items
    asArray items <<< "$board"
    if [ "$player" != $(echo "$board" | nextPlayer) ]; then
        echo "${items[@]}"
        $(>&2 echo "Not your turn")
        return 1;
    fi
    local -r value="${items[$ORDER*$row+$column]}"
    if [ "$value" != "$NONE" ]; then
        echo ${items[@]}
        $(>&2 echo "Place is not available")
        return 1;
    fi
    items[$ORDER*$row+$column]="$player"
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
    local -r orig=$(read_input)
    local -r s=$(echo "$orig" | take $ORDER)
    local -r head=$(echo "$s" | take 1)
    if [ "$head" == "$NONE" ]; then
        echo $(echo $orig | skip $ORDER | winner)
        return 1
    fi
    local tail
    asArray tail <<< $(echo $s | skip 1)
    for i in "${tail[@]}"; do
        if [ "$i" != "$head" ]; then
            echo $(echo $orig | skip $ORDER | winner)
            return 1
        fi
    done
    echo "$head"
    return 0
}

function sortVertically {
    local arr
    local returnArr
    asArray arr <<< $(read_input | take $(($ORDER*$ORDER)))
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

function when {
    echo $(($1==0))
    return 0
}

function trueFalse {
    if [[ $(read_input) -eq 0 ]]; then eval "$1"; else eval "$2"; fi
}
