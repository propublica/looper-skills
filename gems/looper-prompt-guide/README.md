# Looper Prompt Guide — Gemini Gem

Adapted from `skills/looper-prompt-guide/`. See [`../README.md`](../README.md) for the
general conversion process, principles, and verification approach this follows — this
file covers only what's specific to this Gem.

## Gem configuration

- **Name:** `Looper Prompt Guide`
- **Description:**
  > A gem to help you craft precise prompts for your Spreadsheet Inference needs
- **Instructions:** full contents of [`instructions.md`](instructions.md)
- **Knowledge files:** [`knowledge/mental-model-template.md`](knowledge/mental-model-template.md), [`knowledge/worked-examples.md`](knowledge/worked-examples.md)
- **Default tool:** None
- **Disable Knowledge Citations:** No

## Track changes

Tracked and verified by [`../check-diffs.sh`](../check-diffs.sh) (see
`../README.md`, "Evaluating a Gem," for how it works):

```bash
./gems/check-diffs.sh looper-prompt-guide
```

If any of the source files changes, this will report `DRIFT DETECTED` with a
diff of what moved. Review it, if it represents a new intentional
edit, run `./gems/check-diffs.sh --record looper-prompt-guide` to bring
`known-diffs.txt` back in sync.

## Manual smoke test

Run this by hand in the Gem's Preview pane before sharing an update:

1. **Gate holds.** Open with a request modeled on Worked Example 2 (Ken Paxton /
   Glenn Beck video filtering — see `knowledge/worked-examples.md`). Try to get the
   Gem to produce a prompt before you've approved a mental model, including by asking
   it to "just give me something to start with." It should decline and keep
   interviewing.
2. **Mental model renders in chat.** Once you've answered enough questions, confirm
   the Gem renders the full mental model as a markdown block in the chat (not a claim
   that it saved a file) and stops for approval.
3. **Prompt compiles after approval.** Approve the mental model; confirm the Gem then
   produces a prompt that traces to what you told it, in a `text` code block, with no
   preamble.
4. **Knowledge files are actually consulted.** Ask the Gem to compare the length/shape
   of the prompt it just wrote to Example 1 vs. Example 2 in the Worked Examples file,
   and confirm it can speak to specifics (not just gesture vaguely) — this checks the
   attached file is actually being read, not just present.
