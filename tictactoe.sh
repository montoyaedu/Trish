#!/bin/bash
readonly NONE=_
readonly CROSS=1
readonly NOUGHT=2
readonly ORDER=3

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
    local -r diag1=$(echo "$board" | filter isEven | skip 1 | take 3)
    local -r diag2=$(echo "$board" | filter isMultipleOfFour)
    echo $(echo "$board $board_sorted_vertically $diag1 $diag2" | winner)
}

function play {
    local -r board=$(read_input)
    local -r player="$1"
    local -r row="$2"
    local -r column="$3"
    local items=($board)
    if [ "$player" != $(echo "$board" | nextPlayer) ]; then
        echo "${items[@]}"
        $(debug "Not your turn")
        return 1;
    fi
    local -r value="${items[$ORDER*$row+$column]}"
    if [ "$value" != "$NONE" ]; then
        echo ${items[@]}
        $(debug "Place is not available")
        return 1;
    fi
    items[$ORDER*$row+$column]="$player"
    echo "${items[@]}"
}

function take {
    local -r n="$1"
    local -r arr=($(read_input))
    echo "${arr[@]::$n}"
}

function skip {
    local -r n="$1"
    local -r arr=($(read_input))
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
    local -r tail=($(echo $s | skip 1))
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
    local returnArr
    local -r arr=($(read_input | take $(($ORDER*$ORDER))))
    for index in {0..8}; do
       local item="${arr[$index]}"
       returnArr["$index"]=$(sortItem "$index" "${arr[@]}")
    done
    echo "${returnArr[@]}"
}

function sortItem {
    local arr=($(echo "$@" | skip 1))
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

function length {
    local -r arr=($(read_input))
    echo ${#arr[@]}
}

function hasMore {
    return $(($(echo "$@" | skip 1 | length)<=0))
}

function filter {
    local -r fn=$1
    local -r index=${2:-0}
    local -r input=$(read_input)
    if $(eval "$fn" "$index"); then
        printf "%s " "$(echo $input | take 1)"
    fi
    if hasMore $input; then
        echo $input | skip 1 | filter "$fn" $(($index+1))
    fi
}

function count {
    echo $(read_input | ${GREP} -o $1 | ${WC} -l)
}

function when {
    echo $(($1==0))
    return 0
}

function trueFalse {
    if [[ $(read_input) -eq 0 ]]; then eval "$1"; else eval "$2"; fi
}
