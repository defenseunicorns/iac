# Contributor Guide

Thanks so much for wanting to help out! :tada:

Most of what you'll see in this document is our attempt at documenting the lightweight development process that works for our team. We're always open to feedback and suggestions for improvement. The intention is not to force people to follow this process step by step, rather to document it as a norm and provide a baseline for discussion.

## Developer Experience

Continuous Delivery is core to our development philosophy. Check out [https://minimumcd.org](https://minimumcd.org/) for a good baseline agreement on what that means.

Specifically:

- We do trunk-based development (`main`) with short-lived feature branches that originate from the trunk, get merged to the trunk, and are deleted after the merge.
- We don't merge work into `main` that isn't releasable.
- We perform automated testing on all pushes to `main`. Fixing failing pipelines in `main` are prioritized over all other work.
- We create immutable release artifacts.

### Developer Workflow

:key: == Required by automation

1. Pick an issue to work on, assign it to yourself, and drop a comment in the issue to let everyone know you're working on it.
2. Create a Draft Pull Request targeting the `main` branch as soon as you are able to, even if it is just 5 minutes after you started working on it. We lean towards working in the open as much as we can. If you're not sure what to put in the PR description, just put a link to the issue you're working on. If you're not sure what to put in the PR title, just put "WIP" (Work In Progress) and we'll help you out with the rest.
3. :key: Automated tests will run on your PR when you create it and for each commit you push to it. The PR will also have manually triggered workflows that you can run (if you have write access to the repo) by commenting on the PR with `/test all`
4. If your PR is still set as a Draft transition it to "Ready for Review"
5. Get it reviewed by a [CODEOWNER](./CODEOWNERS)
6. Merge the PR and delete the branch
7. If the issue is fully resolved, close it. _Hint: You can add "Closes #XXX" to the PR description to automatically close the issue when the PR is merged._

### Pre-Commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to run a set of checks on your code before you commit it. You have the option to either install pre-commit and all other needed tools locally or use our docker-based build harness. To use the build harness, run

```shell
make run-pre-commit-hooks
```
> NOTE: Sometimes file ownership of stuff in the `.cache` folder can get messed up. You can optionally add the `fix-cache-permissions` target to the above command to fix that. It is idempotent so it is safe to run it every time.
