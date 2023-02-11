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

test_text() {
    echo "Do {{ who }} feel {{ how }}?" >"${FIXTURES}/template"
    printf "who=I\nhow=lucky\n" >"${FIXTURES}/data"
    echo "Do I feel lucky?" >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

test_number() {
    echo "e^{{ exp }} = {{ product }}" >"${FIXTURES}/template"
    printf "exp=0\nproduct=1.001\n" >"${FIXTURES}/data"
    echo "e^0 = 1.001" >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

test_partial() {
    echo "{{ sth }} ipsum {{ else }} sit {{ what }}" >"${FIXTURES}/template"
    printf "sth=Lorem\n" >"${FIXTURES}/data"
    echo "Lorem ipsum {{ else }} sit {{ what }}" >"${FIXTURES}/want"

    <"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

    diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

