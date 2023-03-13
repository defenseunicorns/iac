# Examples

This directory contains examples of how to use the various modules in this repository.

## How to Deploy

### Prerequisites

- *Nix operating system (Linux, macOS, WSL2)
- AWS CLI environment variables
  - At minimum: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and either `AWS_REGION` or `AWS_DEFAULT_REGION`
  - Preferred: the above plus `AWS_SESSION_TOKEN`, `AWS_SECURITY_TOKEN`, and `AWS_SESSION_EXPIRATION`
  > If the account is set up to require MFA, you'll be required to have the session stuff. We recommend that you use [aws-vault](https://github.com/99designs/aws-vault). Friends don't let friends use unencrypted AWS creds.
- `docker`
- `make`
- various standard CLI tools that usually come with running on *Nix (grep, sed, etc)

### Deploy

We'll be using our automated tests to stand up environments. They use [Terratest](https://github.com/gruntwork-io/terratest). Each test is based on one of examples in the `examples` directory. For example, if you want to stand up the "complete" example in "insecure" mode, you'll run the `test-complete-insecure` target.

```shell
export SKIP_TEARDOWN=1
unset SKIP_SETUP
unset SKIP_TEST
make <TheTargetYouWantToRun>
```
> `SKIP_TEARDOWN` tells Terratest to skip running the test stage called "TEARDOWN", which is the stage that destroys the environment. We want things to stay up, so we set this variable. We also make sure `SKIP_SETUP` and `SKIP_TEST` are unset.

> Run `make help` to see all the available targets. Any of them can be used to stand up an environment with different parameters. Do not run `make test` directly, as it will run all the tests in parallel and is not compatible with `SKIP_TEARDOWN`.

### Destroy

```shell
unset SKIP_TEARDOWN
export SKIP_SETUP=1
export SKIP_TEST=1
make <TheTargetYouWantToRun>
```
> Since we're tearing down this time, we don't want `SKIP_TEARDOWN` to be set. Instead, we are setting `SKIP_SETUP` and `SKIP_TEST` to skip the setup and test stages.
