---
name: working-modes
description: Defines the project's /auto, /manual, and /plan workflows. Use when a user invokes one of these commands or specifies a working mode.
---

# Working modes

Apply the mode explicitly selected by the user. A mode remains active for the
current conversation until the user selects another mode or gives a conflicting
instruction.

## Auto mode

- Carry out the requested task end to end without pausing for approval of each
  individual change.
- Inspect relevant code and instructions before editing. Preserve unrelated or
  existing user changes.
- Run appropriate checks and report the outcome and changed files.
- Pause and ask only when a decision or missing information materially blocks
  progress, or when an action has significant external or irreversible effects.

## Manual mode

- Before changing any file, present a concise proposed diff: list the files and
  describe or show the intended edits.
- Do not edit until the user explicitly approves that proposal.
- If the user requests a change to the proposal, present the revised proposal
  and wait again.
- After approval, make only the approved changes. If implementation requires
  additional or materially different changes, stop and present a new proposal.
- Run appropriate checks and summarize the result.

## Plan mode

- Explore the relevant code and produce an actionable plan, including affected
  areas and verification steps where useful.
- Do not modify files or perform implementation actions.
- Ask focused questions only if an answer is needed to form a useful plan.

## Switching modes

When a mode command is invoked, acknowledge the selected mode and apply it to
subsequent work. The command's trailing text, if any, is the task to perform in
that mode. If no task is supplied, ask the user what they want to do.
