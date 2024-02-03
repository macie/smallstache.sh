#!/bin/sh

beforeAll() {
    FIXTURES=$(mktemp -d -t 'smallstache_testXXXXXX')
}

afterEach() {
    rm -R "${FIXTURES:-/tmp/smallstache}"/* 2>/dev/null
}

afterAll() {
	rmdir "${FIXTURES:-/tmp/smallstache}"
}

#
# TEST CASES
#

test_no_template() {
    ./smallstache 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_nonexistent() {
    ./smallstache "${FIXTURES}/nonexistent_file" 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_device() {
    touch "${FIXTURES}/empty_file"
    echo 'key=val' | ./smallstache /dev/null >"${FIXTURES}/got"

    test $? -eq 0
    diff "${FIXTURES}/empty_file" "${FIXTURES}/got" >&2
}

test_directory() {
    ./smallstache / 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_empty() {
    printf ' \n ' >"${FIXTURES}/empty_file"

    echo 'key=val' | ./smallstache "${FIXTURES}/empty_file" >"${FIXTURES}/got"

    test $? -eq 0
    diff "${FIXTURES}/empty_file" "${FIXTURES}/got" >&2
}

test_braces_whitespaces() {
    echo 'Ring-{{ say }}-{{say}}-{{say }}-{{  say}}eringe{{ say  }}!' >"${FIXTURES}/template"
    echo 'say=ding' >"${FIXTURES}/data"
    echo 'Ring-ding-ding-ding-dingeringeding!' >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    test $? -eq 0
    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

test_braces_nested() {
    echo 'This is so {{{{ wrong }}}}' >"${FIXTURES}/template"
    echo 'wrong=good' >"${FIXTURES}/data"
    echo 'This is so {{good}}' >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    test $? -eq 0
    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

test_braces_unbalanced() {
    echo 'Something went {{{{{ how }}' >"${FIXTURES}/template"
    echo 'how=wrong' >"${FIXTURES}/data"
    echo 'Something went {{{wrong' >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    test $? -eq 0
    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}
