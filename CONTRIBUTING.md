# Contributing

If you're a coding agent, see [`AGENTS.md`](AGENTS.md) for the same workflows in
agent-oriented form.

## Proposing a new skill

Open an issue or PR describing the reporting task the skill would handle and how it's
distinct from `looper-prompt-guide`. A new skill lives in its own directory under
`skills/<skill-name>/` with a `SKILL.md`, an `evals/evals.json` (see
[Evaluating a skill](#evaluating-a-skill) below), and — if it's meant to reach Gemini
users too — a hand-ported Gem under `gems/<skill-name>/` following the pattern in
[`gems/README.md`](gems/README.md).

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
./build.sh looper-prompt-guide   # just one
```

`build.sh` refuses to package a skill whose directory name and `name:` frontmatter
disagree, or whose name isn't lowercase kebab-case. Both would otherwise produce a
skill that silently fails to load, with no useful error for the person installing it.

The Gem is maintained by hand, not built: its instructions and knowledge files are
copied from the skill source with a short, documented set of edits, then pasted
directly into Gemini's Gem creation UI. There's no automated evaluation for Gems yet,
so changes are checked by diffing against the skill source and a manual smoke test in
Preview. See [`gems/README.md`](gems/README.md).

## Evaluating a skill

This repo doesn't ship its own eval harness.

To check whether a change makes a skill better or worse, workshop it with a
skill-creator skill — e.g. Anthropic's
[skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator)
or obra's [superpowers writing-skills](https://github.com/obra/superpowers/tree/main/skills/writing-skills)
— following the Agent Skills spec's own guide to the process:
[agentskills.io/skill-creation/evaluating-skills](https://agentskills.io/skill-creation/evaluating-skills).

Each skill in this repo carries its own `evals/evals.json` — the test scenarios
(`prompt`, `expected_output`, optional `files` and `assertions`) in the format that
guide describes. That file is what's committed; run results aren't — record a real
benchmark run in the commit message for the `SKILL.md` change it validates, not in a
separate file.
