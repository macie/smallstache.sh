# This Makefile intended to be POSIX-compliant (2018 edition with .PHONY target).
#
# .PHONY targets are used by:
#  - task definintions
#  - compilation of Go code (force usage of `go build` to changes detection).
#
# More info:
#  - docs: <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html>
#  - .PHONY: <https://www.austingroupbugs.net/view.php?id=523>
#
.POSIX:
.SUFFIXES:


#
# PUBLIC MACROS
#

LINT=shellcheck
TEST=./unittest


#
# INTERNAL MACROS
#

TEST_SRC=https://raw.githubusercontent.com/macie/unittest.sh/master/unittest


#
# DEVELOPMENT TASKS
#

.PHONY: all
all: test check

.PHONY: clean
clean:
	@echo '# Delete test runner: rm $(TEST)' >&2
	@rm $(TEST)

.PHONY: info
info:
	@printf '# OS info: '
	@uname -rsv;
	@echo '# Development dependencies:'
	@echo; $(LINT) -V || true
	@echo; $(TEST) -v || true

.PHONY: check
check: $(LINT)
	@printf '# Static analysis: $(LINT) smallstache tests/*.sh' >&2
	@$(LINT) smallstache tests/*.sh

.PHONY: test
test: $(TEST)
	@echo '# Unit tests: $(TEST)' >&2
	@$(TEST)


#
# DEPENDENCIES
#

$(LINT):
	@printf '# $@ installation path: ' >&2
	@command -v $@ >&2 || { echo "ERROR: Cannot find $@" >&2; exit 1; }

$(TEST):
	@echo '# Prepare $@:' >&2
	curl -fLO $(TEST_SRC)
	chmod +x $@
