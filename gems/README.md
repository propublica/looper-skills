# SSI Gems

For organizations with limited Engineering/IT support, [Gemini Gems](https://gemini.google.com/gems)
represent an easier path to custom AI Skills than the Skills format the rest of
this repo uses. Gems are a bit idiosyncratic as far as AI tooling is concerned, so they require their own export process covered in this document.

Each Gem's individual README covers Gem-specific configuration and a manual smoketest.

## Quick start: deploying a Gem to Gemini

1. Go to [gemini.google.com/gems](https://gemini.google.com/gems) → **New Gem**, or
   open the existing one to update it.
2. Set the name and description from that Gem's own README.
3. Paste the full contents of that Gem's `instructions.md` into the Instructions box.
4. Under Knowledge, upload every file in that Gem's `knowledge/` directory.
5. Save.
6. Run the manual smoke test documented in that Gem's README, in Preview, before
   sharing.

## Developing on a Gem

Gems should first be created as Skills, a more durable, more widely interoperable format. Once a Skill is created, you can follow the instructions below to export it as a Gem.

### Adding a new Gem for a skill

1. `mkdir -p gems/<skill-name>/knowledge`
2. Copy `skills/<skill-name>/SKILL.md`'s body (frontmatter stripped) into
   `gems/<skill-name>/instructions.md`, applying the edits described in "What forces
   an edit, and what doesn't" below wherever they're needed.
3. Copy every file under `skills/<skill-name>/assets/` and
   `skills/<skill-name>/references/` into `gems/<skill-name>/knowledge/`, applying the
   same edits where needed — most files need none.
4. Write `gems/<skill-name>/README.md` — use
   [`ssi-prompt-guide/README.md`](ssi-prompt-guide/README.md) as a template: Gem
   configuration, a "Track changes" pointer to `check-diffs.sh`, and a manual smoke
   test.
5. Write `gems/<skill-name>/diff-pairs.txt`, pairing every file from steps 2–3 to its
   skill source (format documented at the top of
   [`check-diffs.sh`](check-diffs.sh)), then run
   `./gems/check-diffs.sh --record <skill-name>` to record the baseline. **Required:**
   `check-diffs.sh` treats every directory under `gems/` as a gem, and a gem with no
   `diff-pairs.txt` fails the whole check — including in CI — rather than being
   skipped, so do this step before opening a PR.
6. Follow ["Quick start: deploying a Gem to Gemini"](#quick-start-deploying-a-gem-to-gemini) above to create it in Gemini.
7. Add a row for it under "Gems in this repo" below.

### Evaluating a Gem

Gems have no automated testing harness. Verification is two checks: `check-diffs.sh`
against the source skill, run in CI on every push/PR touching `skills/` or `gems/`
(see [`.github/workflows/check-gem-diffs.yml`](../.github/workflows/check-gem-diffs.yml)),
and a manual smoke test in Preview, run by a maintainer (see that Gem's README).
Every directory under `gems/` is required to have a `diff-pairs.txt` — one without it
fails the check outright instead of being skipped, so a new gem can't slip past CI
unchecked.

**After any change to a skill or Gem file:**

1. Run `./gems/check-diffs.sh <gem-name>`.
2. On `DRIFT DETECTED`: review the diff, document it in that Gem's README if
   intentional, then re-run with `--record`.
3. Run the manual smoke test in Preview before sharing.

This only catches undocumented *text* drift, not behavior — that's what the smoke
test is for.

### Principle: copy, don't rewrite

Gems have no automated testing harness, so a rewritten
instructions text (for now) can't be cheaply checked against the source skill for fidelity. Copying
the `SKILL.md` body avoids that problem: keep the source text verbatim, make only the
edits a platform difference actually forces, and write every one of those edits down. Anyone can then run [`check-diffs.sh`](check-diffs.sh) (see
"Evaluating a Gem" above) and see the entire set of changes at a glance, instead of having to re-derive whether a rewrite preserved the original's intent.

#### What forces an edit, and what doesn't

Only change a sentence in the copied instructions when it's actually false on this
platform — not because it looks unfamiliar. In practice, two things reliably force an
edit:

- **A path reference to a `references/` or `assets/` file.** Gems have no filesystem
  the model navigates — only an Instructions box and attached knowledge files. Replace
  the path with "the attached `<Name>` file."
- **An instruction to write or save a file to disk.** Gemini chat can't do this.
  Replace it with an instruction to render the content directly in the chat as a
  copyable block.

The skill's YAML frontmatter is also always dropped from the copied body — its two
fields move to the Gem's Name and Description fields instead (see "Gem configuration"
in that Gem's README) — but this isn't a special case: it's just another edit,
recorded as an ordinary hunk in `known-diffs.txt` the same as everything else. Nothing
gets a free pass from being diffed.

Everything else usually survives untouched, including things that might look
agent-specific at first glance — custom tags like `<HARD-GATE>`, a mermaid diagram, a
checklist. These are still just text to a Gem; they don't need translation.

## Gems in this repo

- [`ssi-prompt-guide/`](ssi-prompt-guide/README.md) — adapted from
  `skills/ssi-prompt-guide/`.
