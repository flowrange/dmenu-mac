# Domain Docs

This repository uses a single context.

## Before exploring the codebase

- Read root `GLOSSARY.md` when present.
- Read decisions in `docs/adr/` relevant to the area being changed.

If these files are absent, proceed silently. The `/domain-modeling` skill creates
them when terms or decisions are resolved; setup creates no empty glossary or ADR.

## Vocabulary and decisions

Use glossary terms in issue titles, proposals, hypotheses, code and tests. If a
needed concept is missing, reconsider the term or note a gap for domain modeling.
Explicitly identify a conflict with an existing ADR and explain why the decision
should be revisited rather than silently overriding it.

## Layout

- `GLOSSARY.md`: shared vocabulary at the repository root.
- `docs/adr/NNNN-<slug>.md`: architecture decisions for this project.
