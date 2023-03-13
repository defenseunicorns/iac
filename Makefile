# The version of the build harness container to use
BUILD_HARNESS_REPO := ghcr.io/defenseunicorns/not-a-build-harness/not-a-build-harness
BUILD_HARNESS_VERSION := 0.0.8

.DEFAULT_GOAL := help

# Optionally add the "-it" flag for docker run commands if the env var "CI" is not set (meaning we are on a local machine and not in github actions)
TTY_ARG :=
ifndef CI
	TTY_ARG := -it
endif

# Silent mode by default. Run `make VERBOSE=1` to turn off silent mode.
ifndef VERBOSE
.SILENT:
endif

# Idiomatic way to force a target to always run, by having it depend on this dummy target
FORCE:

.PHONY: help
help: ## Show a list of all targets
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1:\3/p' \
	| column -t -s ":"

.PHONY: _test-all
_test-all:
	mkdir -p .cache/go
	mkdir -p .cache/go-build
	mkdir -p .cache/tmp
	echo "Running automated tests. This will take several minutes. At times it does not log anything to the console. If you interrupt the test run you will need to log into AWS console and manually delete any orphaned infrastructure."
	docker run $(TTY_ARG) --rm -v "${PWD}:/app" -v "${PWD}/.cache/tmp:/tmp" -v "${PWD}/.cache/go:/root/go" -v "${PWD}/.cache/go-build:/root/.cache/go-build" --workdir "/app/test/e2e" -e GOPATH=/root/go -e GOCACHE=/root/.cache/go-build -e REPO_URL -e GIT_BRANCH -e AWS_REGION -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_SECURITY_TOKEN -e AWS_SESSION_EXPIRATION -e SKIP_SETUP -e SKIP_TEST -e SKIP_TEARDOWN $(BUILD_HARNESS_REPO):$(BUILD_HARNESS_VERSION) bash -c 'asdf install && go test -v $(EXTRA_TEST_ARGS) ./...'

.PHONY: test
test: ## Run all automated tests. Requires access to an AWS account. Costs real money.
	$(MAKE) _test-all EXTRA_TEST_ARGS="-timeout 2h"

.PHONY: test-complete-insecure
test-complete-insecure: ## Run one test (TestExamplesCompleteInsecure). Requires access to an AWS account. Costs real money.
	$(MAKE) _test-all EXTRA_TEST_ARGS="-timeout 2h -run TestExamplesCompleteInsecure"

.PHONY: test-complete-secure
test-complete-secure: ## Run one test (TestExamplesCompleteSecure). Requires access to an AWS account. Costs real money.
	#$(MAKE) _test-all EXTRA_TEST_ARGS="-timeout 2h -run TestExamplesCompleteSecure"
	echo "TestExamplesCompleteSecure is still being worked on. For now feel free to use the complete-self-managed-nodegroup example."

.PHONY: docker-save-build-harness
docker-save-build-harness: ## Pulls the build harness docker image and saves it to a tarball
	mkdir -p .cache/docker
	docker pull $(BUILD_HARNESS_REPO):$(BUILD_HARNESS_VERSION)
	docker save -o .cache/docker/build-harness.tar $(BUILD_HARNESS_REPO):$(BUILD_HARNESS_VERSION)

.PHONY: docker-load-build-harness
docker-load-build-harness: ## Loads the saved build harness docker image
	docker load -i .cache/docker/build-harness.tar

.PHONY: run-pre-commit-hooks
run-pre-commit-hooks: ## Run all pre-commit hooks. Returns nonzero exit code if any hooks fail. Uses Docker for maximum compatibility
	mkdir -p .cache/pre-commit
	docker run $(TTY_ARG) --rm -v "${PWD}:/app" --workdir "/app" -e "PRE_COMMIT_HOME=/app/.cache/pre-commit" $(BUILD_HARNESS_REPO):$(BUILD_HARNESS_VERSION) bash -c 'asdf install && pre-commit run -a --show-diff-on-failure'

.PHONY: fix-cache-permissions
fix-cache-permissions: ## Fixes the permissions on the pre-commit cache
	docker run $(TTY_ARG) --rm -v "${PWD}:/app" --workdir "/app" -e "PRE_COMMIT_HOME=/app/.cache/pre-commit" $(BUILD_HARNESS_REPO):$(BUILD_HARNESS_VERSION) chmod -R a+rx .cache
