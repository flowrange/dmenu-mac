# Triage Labels

The five canonical roles map directly to `Status:` values in local tickets.
Each triaged ticket carries exactly one of these states.

| Canonical role | Local status | Meaning |
| --- | --- | --- |
| `needs-triage` | `needs-triage` | Maintainer needs to evaluate the issue. |
| `needs-info` | `needs-info` | Waiting for information or clarification. |
| `ready-for-agent` | `ready-for-agent` | Fully specified and ready for an agent. |
| `ready-for-human` | `ready-for-human` | Requires human implementation or intervention. |
| `wontfix` | `wontfix` | Will not be actioned. |

Use this mapping whenever a skill refers to a triage role. Ticket categories
(`bug` or `enhancement`) are separate from these states.
