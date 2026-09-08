# SSI Skills

[![Latest release](https://img.shields.io/github/v/release/propublica/ssi-skills?label=latest%20release)](https://github.com/propublica/ssi-skills/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

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
* [Evals](./skills/ssi-prompt-guide/evals/) — test scenarios, see [Evaluating a skill](CONTRIBUTING.md#evaluating-a-skill)

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
* Turn "dirty" financial assets into "clean" CUSIP codes
* Track the impact of scientific reports
* Turn IRS Form 990 Schedule J text into structured payouts
* Background individuals from a tax benefit list

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to propose a skill, how releases are
cut, and how to evaluate a change to a skill. Participation in this project is
governed by the [Code of Conduct](CODE_OF_CONDUCT.md).
