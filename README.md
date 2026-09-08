# SSI Skills

AI skills for **spreadsheet inference** — running one prompt/AI trigger, once per row, across a pile of documents, records, links or files.

If you have 900 PDFs and a question about each of them, that's a spreadsheet inference job. This repo holds tooling to help you do it well, whatever AI assistant you use.

## Quick start

Everything under `skills/` is an [Agent Skill](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — a `SKILL.md` file plus supporting assets, an emerging open format that more than one AI assistant can load. How you install one depends on your harness, not on which skill it is.

**A harness that loads skills from a folder** (e.g. Claude Code) — copy the skill directory into wherever that harness looks for skills:

```bash
cp -r skills/<skill-name> ~/.claude/skills/
```

**A harness that installs packaged `.skill` files** (e.g. the Claude desktop app or claude.ai) — download `<skill-name>.skill` from the [latest release](../../releases/latest) and install it there (in Claude's case, open the file and click **Save skill**). No terminal, no git.

**Gemini Web App** — Gemini doesn't support Skills, so we maintain a hand-ported [Gem](https://gemini.google.com/gems) instead. Follow [`gems/README.md`](gems/README.md) to deploy it.

Don't see your harness above? If it can read a `SKILL.md` file or install a `.skill` package, one of the two methods above should work; if it can't do either, the Gemini path is a template for hand-porting to something else.

## What's here

### SSI Prompt Guide

Turns a reporting question into a prompt you can run over every row in your dataset, plus a written **mental model** recording the definition you're applying, the edge cases, and the decisions behind it.

* [Skill](./skills/ssi-prompt-guide/)
* [Gem](./gems/ssi-prompt-guide/)

## Also check out: [SSI Toolkit](github.com/propublica/gas-ssi-toolkit)

[**SSI Toolkit**](https://github.com/propublica/gas-ssi-toolkit) is a Google Sheets add-on built for spreadsheet inference. While you can use SSI prompts with any AI assistant, it's the companion tool we recommend, and it's what these skills were developed to support.

## Why spreadsheets?

The most common failure scenario for AI tooling is when the AI/model/agent/harness/etc is asked to do too much to fast -- a byproduct of the frictionless experience they promise.

Spreadsheets and their tabular structure require users to think about inputs, action and output. It reintroduces a level of friction useful to wield AI effecitvely, especially for investigative journalism.

This methodology was developed at ProPublica through work with reporters on stories including [Deleting DEI](https://www.propublica.org/article/deleting-dei-language-nonprofits-irs-forms) and [DOJ Declinations](https://www.propublica.org/article/trump-doj-immigration-bondi-declinations-criminal-investigations).

Spreadsheet Inference has been used to:

* Search a court docket for medical issues at ICE detention centers
* Filter medical examiner records
* Find Ken Paxton interviews on YouTube
* Identify subtle changes in non-profit mission statement language related to DEI
* Turn "dirty" finanical assets into "clean" CUSIP codes
* Track the impact of scientific reports
* Turn IRS Form 990 Schedule J text into structured payouts
* Background individuals from a tax benefit list

## Releasing

Releases are cut from tags. Tag a commit on `main` and push it:

```bash
git tag v1.1.0 && git push origin v1.1.0
```

The [release workflow](.github/workflows/release.yml) builds a `.skill` file for every
skill under `skills/` and attaches them to a GitHub release. The "latest release" links
throughout this repo therefore always point at a package built from tagged source.

`.skill` files aren't committed — `.gitignore` excludes them — which keeps zip churn out
of git history and makes it impossible for a stale download to sit next to updated
source.

To build locally without releasing:

```bash
./build.sh                    # every skill, into dist/
./build.sh ssi-prompt-guide   # just one
```

`build.sh` refuses to package a skill whose directory name and `name:` frontmatter
disagree, or whose name isn't lowercase kebab-case. Both would otherwise produce a
skill that silently fails to load, with no useful error for the person installing it.

The Gem is maintained by hand, not built: its instructions and knowledge files are
copied from the skill source with a short, documented set of edits, then pasted
directly into Gemini's Gem creation UI. There's no automated evaluation for Gems yet,
so changes are checked by diffing against the skill source and a manual smoke test in
Preview. See [`gems/ssi-prompt-guide/README.md`](gems/ssi-prompt-guide/README.md).
