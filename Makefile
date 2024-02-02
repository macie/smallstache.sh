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

CLI     = smallstache
DESTDIR = ./dist
LINT    = shellcheck
TEST    = ./unittest


#
# INTERNAL MACROS
#

CLI_CURRENT_VER_TAG = $$(git tag | grep "^v" | sed 's/^v//' | sort -t. -k 1,1n -k 2,2n -k 3,3n | tail -1)
CLI_VERSION         = $$(grep "^ *smallstache_version *=" $(CLI) | sed 's/^ *smallstache_version *= *//')

TEST_SRC = https://raw.githubusercontent.com/macie/unittest.sh/master/unittest


#
# DEVELOPMENT TASKS
#

.PHONY: all
all: test check

.PHONY: clean
clean:
	@echo '# Delete test runner' >&2
	rm $(TEST)
	@echo '# Delete bulid directory' >&2
	rm -rf $(DESTDIR)

.PHONY: info
info:
	@printf '# OS info: '
	@uname -rsv;
	@echo '# Development dependencies:'
	@echo; $(LINT) -V || true
	@echo; $(TEST) -v || true

.PHONY: check
check: $(LINT)
	@printf '# Static analysis: $(LINT) $(CLI) tests/*.sh' >&2
	@$(LINT) $(CLI) tests/*.sh

.PHONY: test
test: $(TEST)
	@echo '# Unit tests: $(TEST)' >&2
	@$(TEST)

.PHONY: install
install:
	@echo '# Install in /usr/local/bin' >&2
	@mkdir -p /usr/local/bin; cp $(CLI) /usr/local/bin/

.PHONY: dist
dist:
	@echo '# Copy CLI executable to $(DESTDIR)/$(CLI)' >&2
	@mkdir -p $(DESTDIR); cp $(CLI) $(DESTDIR)/
	@echo '# Add executable checksum to: $(DESTDIR)/$(CLI).sha256sum' >&2
	@cd $(DESTDIR); sha256sum $(CLI) >> $(CLI).sha256sum

.PHONY: cli-release
cli-release: check test
	@echo '# Update local branch' >&2
	@git pull --rebase
	@printf '# Create release tag for CLI version %s\n' "$(CLI_VERSION)" >&2
	@if [ "$(CLI_CURRENT_VER_TAG)" = "$(CLI_VERSION)" ]; then \
			printf 'ERROR: version %s already released\n' "$(CLI_VERSION)" >&2; \
			exit 1; \
		fi
	@printf 'Are you sure you want to release version %s (prev: %s)? [y/N]: ' "$(CLI_VERSION)" "$(CLI_CURRENT_VER_TAG)"
	@read -r ANSWER; \
		if [ "$$ANSWER" != "y" ]; then \
			echo 'ERROR: canceled by user' >&2; \
			exit 1; \
		fi; \
		git tag "v$(CLI_VERSION)"; \
		git push --tags

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
