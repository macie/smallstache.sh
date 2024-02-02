.POSIX:
.SUFFIXES:

LINT=shellcheck
TEST=./unittest
TEST_SRC=https://raw.githubusercontent.com/macie/unittest.sh/master/unittest

# MAIN TARGETS

all: test check

clean:
	@echo '# Delete test runner: rm $(TEST)' >&2
	@rm $(TEST)

info:
	@printf '# OS info: '
	@uname -rsv;
	@echo '# Development dependencies:'
	@echo; $(LINT) -V || true
	@echo; $(TEST) -v || true

check: $(LINT)
	@printf '# Static analysis: $(LINT) smallstache tests/*.sh' >&2
	@$(LINT) smallstache tests/*.sh
	
test: $(TEST)
	@echo '# Unit tests: $(TEST)' >&2
	@$(TEST)

# HELPERS

$(LINT):
	@printf '# $@ installation path: ' >&2
	@command -v $@ >&2 || { echo "ERROR: Cannot find $@" >&2; exit 1; }

$(TEST):
	@echo '# Prepare $@:' >&2
	curl -fLO $(TEST_SRC)
	chmod +x $@

