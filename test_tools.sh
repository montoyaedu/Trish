#!/bin/bash
readonly PATH=
readonly CAT=/bin/cat
function desc {
    if [ "$1" == "0" ]; then
        echo "PASSED"
    else
        echo "FAILED"
    fi
}

function can_compare_multiple_word_strings {
    assert_that "A B C" | is "A B C"
}

function desc_should_return_passed {
    assert_that $(desc 0) | is "PASSED"
}

function desc_should_return_failed {
    assert_that $(desc 1) | is "FAILED"
}

function id {
    echo "$1"
}

function read_input {
    "${CAT}" -
}

function is {
    local -r actual=$(read_input)
    local -r expected="${@}"
    if [ "${actual}" == "${expected}" ]; then
        return 0
    else
        echo "expected '${expected}' but got '${actual}'"
        return 1
    fi
}

function assert_that {
    eval local -r a="\${@}"
    echo "$a"
}

function id_should_return_input_number {
    assert_that $(id 1) | is 1
}

function id_should_return_input_string {
    assert_that $(id "hello") | is "hello"
}

function test_all {
    local -r tests=( "$@" )
    for i in "${tests[@]}"; do
        eval "$i"
        echo "[`desc $?`] - $i"
    done
}

function test {
    test_all \
       desc_should_return_passed \
       desc_should_return_failed \
       id_should_return_input_string \
       id_should_return_input_number \
       can_compare_multiple_word_strings
}

test
