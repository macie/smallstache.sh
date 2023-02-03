.POSIX:
.SUFFIXES:

LINT=shellcheck
TEST=unittest
TEST_SRC=https://raw.githubusercontent.com/macie/unittest.sh/master/unittest

# MAIN TARGETS

all: test check

clean:
	@echo "> Delete $(TEST)" >&2
	rm $(TEST)

debug:
	@echo "> List development dependencies" >&2
	@echo; $(LINT) -V
	@echo; ./$(TEST) -v

check: $(LINT)
	@echo "> Start static analysis" >&2
	$(LINT) smallstache tests/*.sh
	
test: $(TEST)
	@echo "> Start unit tests" >&2
	./$(TEST)

# HELPERS

$(LINT):
	@echo "> Show where $@ is installed:" >&2
	@command -v $@ >&2 || { echo "ERROR: Cannot find $@" >&2; exit 1; }

$(TEST):
	@echo "> Prepare $@" >&2
	curl -fLO $(TEST_SRC)
	chmod +x $@

