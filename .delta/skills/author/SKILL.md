---
name: author
description: >-
  Add or revise wiki pages around user-approved key ideas and obtain a passing
  review. Use when changing page content.
---

# Author wiki pages

1. For each affected page, decide whether its bulleted key-ideas callout needs
   to be added, revised, or kept as written. If the intended claim is unclear,
   ask rather than guessing.
2. State your understanding of the user's intended change. Show the proposed
   key ideas for each page as a bullet list, noting when they are unchanged.
   Ask for explicit approval and wait before editing any wiki page. If the user
   requests adjustments, present the revised proposal for approval.
3. After approval, update each callout as agreed and revise the body to support
   those ideas. Don't broaden the callout to accommodate an unrelated passage.
4. Spawn a Reviewer subagent (`profile: reviewer`). In its prompt, invoke
   `/copyedit` with the repository-relative paths of all affected pages as the
   sole arguments, for example `/copyedit index.qmd rate-distortion-prior.qmd`.
5. Report each round's verdict and brief rationale. On `fail`, address the
   substantive findings and repeat step 4 with a fresh Reviewer so it reads the
   revised pages. Report final results only after the current pages receive
   `pass`.
