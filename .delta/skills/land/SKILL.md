---
name: land
description: >-
  Land the requested lab-wiki changes on origin/main and local/main. Invoke only
  when the user explicitly requests a merge, not for review, preparation,
  passing checks, or skill installation.
disable-model-invocation: true
metadata:
  delta-action: land
---

# Land lab-wiki changes

An explicit `/land` invocation is a merge request. Proceed without asking for
the same permission again. Pause if the scope is unclear or a prerequisite
cannot be satisfied.

## Check destinations and push

1. Confirm `origin` pushes to the intended GitHub repository and `local`
   pushes to the intended source repository. Fetch `origin/main` and record its
   tip.
2. Push the exact verified commit first to `origin` and then to `local`, using
   `git push origin <candidate-sha>:refs/heads/main` and
   `git push local <candidate-sha>:refs/heads/main`. Use no force or bypass
   flags unless explicitly requested. Use non-interactive
   authentication; if it is unavailable, report the blocker.

   Delta's `local` remote supports pushing to a checked-out branch: it updates
   a clean checkout in place and rejects pushes that would overwrite
   uncommitted edits. A checked-out `main` or an unset
   `receive.denyCurrentBranch` is not a blocker by itself. Use the normal push
   and report any actual rejection without switching branches or changing Git
   configuration.

3. Read back the exact `refs/heads/main` from each push destination and confirm
   both reached the candidate commit. If a ref advanced again after a push,
   verify the candidate is in that ref's history and report the newer tip
   rather than claiming both tips match. If only one push succeeded, name the
   destination that changed and explain why the other did not; do not try to
   roll back the successful push. If neither destination was updated, report
   that the change was not merged and explain the blocker.
