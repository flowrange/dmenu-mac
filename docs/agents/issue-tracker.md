# Issue tracker: Local Markdown

Issues and specs live in `.scratch/`, ignored by Git. Use local files for issue
tracking; GitHub remains the code remote.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`.
- The spec is `.scratch/<feature-slug>/spec.md`.
- One implementation ticket per file: `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`.
- Triaged tickets have `Category: bug` or `Category: enhancement`, plus one `Status:` value from `triage-labels.md`, near the top.
- Append comments and conversation history under `## Comments`.
- Resolve a bare ticket number within its feature directory; ask for the feature when ambiguous.

## Publishing and fetching tickets

When a skill says "publish to the issue tracker", write the spec or individual
ticket at its conventional path above, creating directories as needed.
When it says "fetch the relevant ticket", read the referenced local file.

## Wayfinding operations

Used by `/wayfinder`. Its map and execution statuses follow this workflow:

- Map: `.scratch/<effort>/map.md`, containing Notes / Decisions-so-far / Fog.
- Child: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with `Type: research`, `prototype`, `grilling`, or `task`.
- Execution status: `Status: open`, `claimed`, or `resolved`; these are wayfinding lifecycle values, separate from the five triage states.
- Blocking: `Blocked by: NN, NN` near the top. A ticket is unblocked when every listed ticket is resolved.
- Frontier: scan for open, unblocked, unclaimed tickets; first by number wins.
- Claim: save `Status: claimed` before starting work.
- Resolve: append an `## Answer`, set `Status: resolved`, and add a gist and link to the map's Decisions-so-far.
