# Worked examples

Four prompts, each correct for its job, spanning the three tiers and the full length
range. Read these when you need a model for how a prompt should be structured — not to
copy, but to see what "traces back to the mental model" looks like in practice.

**Provenance matters here, so it's labelled.** Examples 1 and 2 are real: actual
newsroom projects, actual prompts that ran. Examples 3 and 4 are constructed — they came
out of test conversations with simulated reporters, so the datasets are invented. The
techniques in them are sound and worth stealing; the reporting projects never happened.
Don't cite 3 and 4 as evidence that something worked in the field.

| # | Tier | Teaches | Real? |
|---|---|---|---|
| 1 | Read it off | Spatial anchors, verbatim extraction, nulls, arithmetic in the sheet | Yes |
| 2 | Judgment call | Writing the near-miss into the definition; the reason field | Yes |
| 3 | Judgment call | Enumerated categoricals; splitting a near-miss into its own column; out-of-scope values | Constructed |
| 4 | Go find out | Reachability vs. existence; gating one field on another; dead ends as data | Constructed |

---

## Example 1 — Read it off: medical examiner records

**Tier:** Read it off. Eleven fields, but each one is "read what's written there."

**The situation.** A reporter had ~1,000 medical examiner investigator reports as Drive
links in a column, and needed to filter down to decedents who were minors. She'd tried
a chatbot with a document-upload limit and no ability to work systematically, which
got her nowhere.

**Why the prompt is long.** The length is doing real work: the document's geometry is
idiosyncratic knowledge. Every field is anchored by *where it sits on the page* and
*what label precedes it*, because that's how you actually find a field on a scanned
form. This is knowledge you can only get with the document open in front of you.

**The move worth stealing.** The reporting goal is "find the under-18 decedents," and
the prompt never asks the model whether someone is under 18. It extracts `age` and
`birthDate` verbatim and lets the spreadsheet do the arithmetic. That's the gap check
in action — the inference is narrowed to what only a model can do (read a scanned
form), and the deterministic part stays deterministic and auditable.

Note also: verbatim extraction, no normalization, explicit `null` rather than omitting
keys, and an explicit ban on preamble and code fences.

```txt
You are an expert document-processing AI specializing in structured visual data extraction. Your task is to analyze the attached image/PDF of an Investigator Report and extract specific fields into a single, well-formed JSON object.

### Extraction Rules:
1. **Verbatim Text Extraction:** Extract text exactly as it is written in the document. Do not change uppercase/lowercase styling, do not truncate strings, and do not reformat dates or times (e.g., leave "Year(s)" or "h" if present).
2. **Null Values:** If a field is entirely blank, missing, or contains "N/A", return `null` for that key. Do not omit the key from the JSON.
3. **No Conversions:** Do not attempt to compute values or clean up typos found within the document data itself.
4. **JSON Output Only:** Return ONLY a valid JSON object. Do not include conversational filler, markdown explanations, or code block wrappers outside of the requested JSON structure.

### Spatial Anchor Points & Field Mapping:
Locate and map the following fields based on their visual positioning and text denominators:

* **caseNumber**
  - *Location:* Located in the top header section, underneath and to the left of the main title "INVESTIGATOR REPORT".
  - *Denominator:* "Case #: "

* **firstName**
  - *Location:* Located in the first row of the grid table titled "DECEDENT INFORMATION".
  - *Denominator:* "First: "

* **age**
  - *Location:* Located in the second row of the grid table titled "DECEDENT INFORMATION", to the right of "Sex:".
  - *Denominator:* "Age: "

* **birthDate**
  - *Location:* Located in the third row of the grid table titled "DECEDENT INFORMATION".
  - *Denominator:* "Birth Date: "

[...remaining fields follow the same pattern...]

### Expected JSON Output Schema:
{
  "caseNumber": string or null,
  "firstName": string or null,
  "age": string or null,
  "birthDate": string or null
}
```

---

## Example 2 — Judgment call: filtering YouTube videos

**Tier:** Judgment call. One field, and the entire job is the definition.

**The situation.** A reporter wanted transcripts of interviews between Ken Paxton and
Glenn Beck, to check whether certain entities came up. Before that, she needed to know
which videos on Beck's channel actually *contain* such an interview.

**Why the prompt is short.** Nothing about the input needs describing — it's a video.
The only thing that needed extracting from the reporter was where the line falls, and
once you have that, stating it takes one sentence.

**The move worth stealing.** Look at how the boundary is drawn:

> True if this video shows Glenn Beck and Texas Attorney General Ken Paxton having a
> conversation with each other (e.g. an interview, phone call, or direct exchange).
> False if Paxton is only mentioned, shown in a clip, or discussed without an actual
> conversation between the two.

That second sentence is the near-miss, written down. It's not "false otherwise" — it
names the specific ways a careless reader would get this wrong. This is what you're
fishing for when you ask a reporter to show you one that looks right but isn't.

The `reasoning` companion field is what makes a spot check possible: the reporter can
sort by `is_paxton_interview` and skim the reasons rather than re-watching videos.

```txt
Return a single JSON object with exactly the following fields -- no other fields, and no text before or after the JSON object.

- `is_paxton_interview` -- a boolean (true/false). True if this video shows Glenn Beck and Texas Attorney General Ken Paxton having a conversation with each other (e.g. an interview, phone call, or direct exchange). False if Paxton is only mentioned, shown in a clip, or discussed without an actual conversation between the two.
- `reasoning` -- a string. A brief explanation for the classification, citing what is actually shown or said in the video.
```

---

---

## Example 3 — Judgment call: K9 deployments in complaint files *(constructed)*

**Tier:** Judgment call. One real question, seven output fields.

**The situation.** ~1,200 police misconduct complaint files. The reporter said she
wanted the ones that "involve a K9 unit," but what she actually wanted was incidents
where a dog was *deployed against a person*. About 15% of files list the officer's
assignment as "K-9 Unit" in the header even when no dog appears in the incident, and
~240 files are disposition letters or fax covers with no narrative at all.

**The move worth stealing: the near-miss became its own column.** Example 2 handles its
near-miss with a sentence of instruction. This one handles it structurally:

```txt
- `k9_mentioned` — exactly `Yes` or `No`. Yes if any reference to a police dog appears
  anywhere in the document, including in the header, a unit assignment, or an officer's
  job title, and including a dog referred to only by name. This field is about the word
  being present, not about the dog being used.
- `k9_used_on_person` — exactly one of: `Yes`, `No`, `Unclear`, `N/A`.
```

Splitting "the word is here" from "the thing happened" means the trap can't silently
swallow a row: a header-only file comes back `k9_mentioned: Yes` / `k9_used_on_person:
No`, and the reporter can sort on the disagreement to audit exactly the cases most
likely to be wrong. An instruction can be forgotten in one row out of 1,200. A column
cannot.

**Also worth stealing:**

- **Every categorical enumerates its values**, including the ordinal one describing what
  the dog did (`Bite` / `Physical contact, no bite` / `Directed at a person, no contact`
  / `Not used` / `Unclear` / `N/A`). That column filters. An unenumerated version comes
  back as forty spellings of "bit him."
- **`N/A` is defined, not implied** — "use `N/A` only for a disposition letter or a file
  with no incident narrative." Without it the model invents an answer for the 240 rows
  that contain nothing to answer from, and nobody finds out.
- **The reason field is told what to explain**: "if the answer is `No` because the only
  K9 reference is a header or job title, say so." A reason field pointed at the known
  failure mode is a review queue; a generic one is filler.
- **No quote, no positive finding** — the same rule as Example 4, and the cheapest
  guard against a confident invented answer.
- **The formula-prefix guard**: "No field value may begin with `=`, `+`, or `-`." Quotes
  from documents sometimes do, and a spreadsheet will treat them as formulas.

---

## Example 4 — Go find out: state medical board discipline *(constructed)*

**Tier:** Go find out. The answer isn't in the row — it has to be retrieved.

**The situation.** ~600 physicians, and the question is which have been disciplined by a
state medical board. Nothing in the spreadsheet answers it; the model has to search.

**The move worth stealing: "I couldn't reach it" is not "it isn't there."** This is the
defining problem of the tier, and the prompt solves it by making reachability its own
field and then gating the answer on it:

```txt
- You may answer qualifying_discipline: "No" ONLY if record_reached is "Board record" or
  "Board publication". If you only reached news or third-party sites, or reached
  nothing, the answer is "Unclear". Failing to find something is not the same as
  confirming its absence, and this column must never report the first as the second.
- You may answer qualifying_discipline: "Yes" ONLY if you can supply a verbatim quote in
  conduct_quote, copied exactly from a source you retrieved, describing what the
  physician did. No quote, no "Yes" — it becomes "Unclear".

When torn, answer "Unclear". Never resolve doubt toward "No".
```

That's a permission structure between fields, not a preference. A blank search on a
board whose records aren't online would otherwise render as a clean physician — the
single most dangerous output this job can produce, because it's indistinguishable from
a real negative and it reads as exculpatory.

**Also worth stealing:**

- **Rank the sources, and say what doesn't count.** "The board's own licence-verification
  record; the board's own publications… then anything else. Do not substitute a
  physician-rating site, a law firm page or a news article for the board record and then
  report it as if you had reached the board." Go-find-out prompts fail by accepting a
  plausible-looking source; naming the disqualified ones is what prevents it.
- **Judge the conduct, not the label.** "The label on the action is not the answer.
  Search for the order, the consent agreement, the bulletin entry — whatever describes
  the conduct." The reporter wanted patient-harm cases; boards file those under
  headings that don't distinguish them from paperwork lapses.
- **Don't filter in the prompt.** "Search for all years. Do not filter by date and do not
  calculate how long ago something was. Report the year; the date cut happens
  elsewhere." Same principle as Example 1's age arithmetic — the model retrieves, the
  spreadsheet decides.
- **Say the identification is uncertain rather than guessing.** "If you cannot tell which
  licensee is this physician, say so — do not pick the most likely one," with a separate
  `physician_identified` field to record it.

---

## What they have in common

All four state exactly what fields come back and forbid anything else in the output.
All four give the model somewhere honest to put an answer it can't confidently produce —
`null`, `Unclear`, `N/A`, `Nothing` — rather than forcing a call. None asks the model to
do arithmetic, compare across rows, apply a date cut, or make a decision the reporter
could make better in the spreadsheet afterward.

And the three that involve any judgment all require a verbatim quote from the source to
support a positive finding. That one rule does more work than any other single line: it
makes every hit checkable in seconds, and it gives a model that would otherwise
confabulate an answer nowhere to put it.
