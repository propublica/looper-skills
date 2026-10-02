# Mental model: <project>

*Source of truth for the prompt beside it. Wrong output means a wrong line in here.*

**Tier:** Read it off | Judgment call | Go find out
**Date:** <date>

> How to fill this in: one fact per line. Tables over paragraphs. No narration, no
> names, no account of the conversation. Delete any row you have nothing to put in —
> an empty heading is worse than a missing one. Shorter than the prompt.

---

## Goal

**Row-level question:** For each ____, ____?

**Stage:** triage | dataset that reaches a reader

**What a column supports saying:** <the claim it licenses — and the stronger claim it
does *not*, if there's a gap>

## Input

**Per row:** <what one row holds>
**Runs on:** <tool>
**Reaches the model:** <the file itself | extracted text | a link only>

| Input class | Share | Handling |
|---|---|---|
| | | |

**Out of scope:** <which rows> → returns `<value>`

**Vocabulary:** <words/labels the documents actually use, verbatim>

**Quirks:** <non-obvious facts about this data>

## The call

**Procedure:** <how a person answers this by hand, numbered if multi-step>

**Definition:** <stated so two people apply it identically>

**Near-miss:** <the case a careless reader gets wrong> → <which side it falls on, why>

| Case | Ruling |
|---|---|
| | |

## Error budget

**Tolerance:** <how wrong is acceptable>
**Expensive direction:** false negatives | false positives
**Tie-break:** <what the prompt does when torn>
**Verification:** <how it gets checked>

## Rejected alternatives

| Option | Why not |
|---|---|
| | |

**Moved to the spreadsheet:** <task> → columns `<X>`, `<Y>`; formula `<paste-ready>`
<Confirm the inputs exist in the required form.>

## Output

| Field | Shape | Permitted values | When unknown |
|---|---|---|---|

**Why these shapes:** <what gets filtered, sorted, or pivoted>

---

## Changelog

| Date | Change | Reason |
|---|---|---|
| | | |
