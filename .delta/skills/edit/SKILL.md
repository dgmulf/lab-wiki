---
name: edit
description: Add or revise wiki pages around their stated key ideas and obtain a passing review. Use when changing page content.
---

# Edit wiki pages

1. For each affected page, check the bulleted key-ideas callout at the top against the user's intent. Add or amend it if needed before revising the body. If the intended claim is unclear, ask rather than guessing.
2. Revise the body to support those ideas. Keep the callout faithful to the user's intent; don't broaden it just to accommodate an unrelated passage.
3. Spawn a Reviewer subagent (`profile: reviewer`). In its prompt, invoke `/proofread` with the repository-relative paths of all affected pages as the sole arguments, for example `/proofread index.qmd rate-distortion-prior.qmd`.
4. Report each round's verdict and brief rationale. On `fail`, address the substantive findings and repeat step 3 with a fresh Reviewer so it reads the revised pages. Report final results only after the current pages receive `pass`.
