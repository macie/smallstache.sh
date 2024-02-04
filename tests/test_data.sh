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

test_multiline() {
	cat >"${FIXTURES}/template" <<-'EOF'
		Numbah {{ day_no }} day of Christmas
		My tutu gave to me
		{{ gifts }}
		EOF
	cat >"${FIXTURES}/data" <<-'EOF'
		day_no=three
		gifts=3 dried squid\n2 coconuts and\nOne mynah bird in one papaya tree
		EOF
	cat >"${FIXTURES}/want" <<-'EOF'
		Numbah three day of Christmas
		My tutu gave to me
		3 dried squid
		2 coconuts and
		One mynah bird in one papaya tree
		EOF

	<"${FIXTURES}/data" ./smallstache "${FIXTURES}/template" >"${FIXTURES}/got"

	diff "${FIXTURES}/want" "${FIXTURES}/got" >&2
}

test_delimiter_in_key() {
	echo '{{ ke_y }}' >"${FIXTURES}/template"
	echo "ke_y=value" | ./smallstache -d _ "${FIXTURES}/template" 2>"${FIXTURES}/error_msg"

	test $? -eq 64
	test -s "${FIXTURES}/error_msg"
}

test_delimiter_in_value() {
	echo '{{ key }}' >"${FIXTURES}/template"
	echo "key=val|ue" | ./smallstache "${FIXTURES}/template" 2>"${FIXTURES}/error_msg"

	test $? -eq 1
	test -s "${FIXTURES}/error_msg"
}
