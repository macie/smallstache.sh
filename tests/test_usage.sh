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

test_help() {
    ./smallstache -h 2>"${FIXTURES}/error_msg"

    test $? -eq 0
    test -s "${FIXTURES}/error_msg"
}

test_version() {
    ./smallstache -v 2>"${FIXTURES}/error_msg"

    test $? -eq 0
    test -s "${FIXTURES}/error_msg"
}

test_verbose() {
    touch "${FIXTURES}/empty_file"
    echo 'key=value' | ./smallstache --verbose /dev/null >"${FIXTURES}/got" 2>"${FIXTURES}/error_msg"

    test $? -eq 0
    test -s "${FIXTURES}/error_msg"
    diff "${FIXTURES}/empty_file" "${FIXTURES}/got"
}

test_no_args() {
    ./smallstache 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_2_args() {
    ./smallstache -h -v 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_3_args() {
    ./smallstache -h -v --unknown 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_invalid_option() {
    ./smallstache -h /dev/null 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}

test_2_options() {
    ./smallstache -h --verbose /dev/null 2>"${FIXTURES}/error_msg"

    test $? -eq 64
    test -s "${FIXTURES}/error_msg"
}