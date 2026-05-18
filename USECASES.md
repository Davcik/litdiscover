# litdiscover: Use cases for researchers

This guide presents elevn use cases for the `litdiscover` package, each
framed as a research question that a researcher
might ask. Every use case provides copy-paste-ready Stata commands, a
short note on what the output means, and where appropriate a methodological
caveat.

The guide assumes that a researcher has already installed the package
(`net install litdiscover, from("https://raw.githubusercontent.com/Davcik/litdiscover/main/")`)
and have the example dataset `litdiscover_example500.dta` in your
working directory.

For full reference documentation, type `help litdiscover` inside Stata. For the bibliographic
citation, see `CITATION.cff`.


---

## A note about the example dataset

The use cases below load the synthetic example dataset
`litdiscover_example500.dta` using the classical Stata pattern:

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
```

Replace `C:\YOUR_FOLDER\` with the actual path on your machine. For
example, if you keep your project files in `D:\research\litreview\`,
the command becomes:

```stata
use "D:\research\litreview\litdiscover_example500.dta", clear
```

**Where is the example dataset on my machine?** If you installed
`litdiscover` via `net install` from GitHub, the example dataset was
placed in your Stata `ado/plus/l/` directory rather than in your
current working directory. To locate it, run:

```stata
findfile litdiscover_example500.dta
display "`r(fn)'"
```

The `display` output gives the absolute path; copy it into your `use`
command.

**Tip.** If you plan to run several use cases in sequence, copy the
file once to a convenient working directory and then reference it by
the path you choose for the rest of the session. For example:

```stata
findfile litdiscover_example500.dta
copy "`r(fn)'" "C:\YOUR_FOLDER\litdiscover_example500.dta", replace
```

After the `copy`, every subsequent use case can rely on the same
`use "C:\YOUR_FOLDER\..."` line.


---

## Use case 1. What are the dominant themes in my corpus?

**Setup.** You have a corpus of abstracts and want a first descriptive
overview of the themes present in the literature.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5)
list topic rank term weight if rank <= 5, sepby(topic) noobs abbrev(20)
```

**What this produces.** Five topics, each described by its five most
characteristic terms. Topic terms are the words that LDA identifies as
most distinctive of each topic. By default, the topic-terms table is
loaded into memory at the end of the run, so the `list` command works
immediately without a separate `use` step.

**Interpretation.** Read the top terms for each topic and assign a
substantive label. Topic 1 with terms like "resource", "capability",
"valuable", "rare" plausibly corresponds to the resource-based view;
Topic 2 with "sensing", "seizing", "reconfiguring" corresponds to
dynamic capabilities. The output is a description of what the corpus
contains, not a hypothesis test.

**Note.** The number of topics is a researcher choice. The default of 5
is convenient for demonstration; for a real corpus, try several values
and inspect the coherence and stability diagnostics described in
Use case 3 before committing.

---

## Use case 2. How can I label the topics for my paper?

**Setup.** You have run `litdiscover` and inspected the top terms.
You now want to attach substantive labels so that downstream tables
and graphs use the names you assigned, not the topic numbers.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5)
list topic rank term if rank <= 8, sepby(topic) noobs abbrev(25)

* After reading the top terms, decide on labels and apply them.
label define topiclbl 1 "Resource-based view" 2 "Dynamic capabilities" 3 "Signalling theory" 4 "Institutional theory" 5 "Stakeholder theory"
label values topic topiclbl

* Save the labels to a do-file so they survive switching datasets.
label save topiclbl using "topic_labels.do", replace
```

**What this produces.** A value-label mapping from topic IDs (1–5) to
substantive theoretical names. Any subsequent `list`, `tabulate`, or
`graph` command in this dataset will show the labels in place of the
numeric topic IDs. The do-file lets you reapply the same labels later
or in a different dataset.

**Interpretation.** Labelling is a researcher judgement, not a
statistical output. The standard practice is to read the top 8–10 terms
per topic and, separately, sample 5–10 documents where each topic
dominates (see Use case 5) to verify that the label fits the
documents and not just the words.

**Note.** Labels should be reported in the methods section of your
paper alongside the top terms, so that readers can judge whether the
label fits the topic.

---

## Use case 3. Are my topics statistically robust?

**Setup.** Before reporting topics in a paper, you want to verify that
they are not artefacts of a single LDA random initialisation. A topic
that disappears under a different random seed is not a stable finding.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) seeds(5) coherence outdir(ex03_robust)

* Inspect per-topic stability and coherence in one table.
use "ex03_robust/tables/litdiscover_topic_stability.dta", clear
tempfile stab
qui save `stab', replace

use "ex03_robust/tables/litdiscover_coherence.dta", clear
qui merge 1:1 topic using `stab', nogen

list topic umass mean_best_match min_best_match, noobs
```

**What this produces.** A table giving each topic two diagnostics: UMass
coherence (a measure of how internally consistent the topic's top terms
are; closer to zero is more coherent, Mimno et al. 2011) and mean
best-match Jaccard similarity (how reliably the topic emerges across
seeds; closer to 1 is more stable, Greene, O'Callaghan, and
Cunningham 2014).

**Interpretation.** A topic with both high coherence (umass closer to
zero, e.g. above −2) and high stability (mean_best_match above 0.5) is
a robust finding suitable for reporting. A topic that scores poorly on
either diagnostic should be reported with caution or excluded from the
substantive analysis. Use both diagnostics together; either one alone
is insufficient.

**Note.** The synthetic example dataset is constructed with deliberate
theoretical anchors and produces highly stable topics. Real corpora
typically show more variation; expect some topics to be robust and
others to be borderline.

---

## Use case 4. Have any theoretical perspectives gained prominence over time?

**Setup.** You want to know whether certain theories or themes are
becoming more or less prevalent in the literature across publication
years.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) year(year) topics(5) figures outdir(ex04_year)

use "ex04_year/tables/litdiscover_topic_by_year.dta", clear
list year topic mean_share n_docs if topic == 1, noobs
```

**What this produces.** A table giving the mean topic share and document
count for each (year, topic) cell, plus a publication-ready line plot
saved to `ex04_year/figures/litdiscover_fig_topicyear.png`. The `figures`
option triggers the automatic generation of the line plot.

**Interpretation.** A topic whose mean share rises across years is a
theme gaining prominence in the literature. A topic whose share falls
is being supplanted. Treat low-document-count cells with caution: a
high mean share in a year with only 3 documents is not statistically
reliable.

**Note.** This pattern is descriptive, not causal. The topic share
distribution shifts over time because authors choose what to publish;
journals choose what to accept; reviewers choose what to recommend.
The pattern you observe is the joint product of all three forces.

---

## Use case 5. Which documents most strongly represent each topic?

**Setup.** You want to verify that the topic labels you chose in
Use case 2 actually fits the documents, and which topics dominate. This is the
qualitative validation step.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5)

use "ex01_minimal/tables/litdiscover_doctopic.dta", clear

* For each topic, find the 5 documents with the highest share of that topic.
forvalues k = 1/5 {
    di as txt _newline "Top 5 documents for topic `k':"
    gsort -topic_`k'
    list study_id topic_`k' in 1/5, noobs
}
```

**What this produces.** For each of the five topics, the five documents
with the highest share of that topic. The `study_id` lets you cross-
reference back to your original dataset to read the abstracts directly.

**Interpretation.** Open your input dataset, find the abstracts for
these top-share documents, and read them. If your label for topic 1 is
"Resource-based view" and the five top abstracts are visibly about
RBV, the label is validated. If three of them are about something else,
revise the label.

**Note.** This step takes time but is the standard qualitative
validation in management and marketing literature reviews (Paul et al.
2024). Skipping it is the most common source of misclaim in
topic-modelling papers.

---

## Use case 6. Which topics dominate which empirical contexts or methods?

**Setup.** You want to understand whether some theories are
preferentially applied to particular industries, countries, or methods.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) context(context) method(method) topics(5) outdir(ex06_context)

use "ex06_context/tables/litdiscover_topic_by_field.dta", clear
keep if field == "context"
list value topic mean_share n_docs if mean_share > 0.3, noobs sepby(value)
```

**What this produces.** Rows from the topic-by-field table showing
which empirical contexts have above-30%-share allocations to which
topics. The threshold of 0.3 is arbitrary; raise it to focus on the
strongest associations, lower it to see weaker patterns.

**Interpretation.** A context like "manufacturing firms" with a 0.45
share on topic 1 (resource-based view) suggests that RBV is
particularly applied to manufacturing in this corpus. Compare with
other contexts to see whether each theory has its dominant context, or
whether some theories pass more freely across contexts.

**Note.** "Context" in this command is the construct field you supply.
You can also supply `method()` to see method-topic associations, or
`journal()` to see which journals concentrate on which topics.

---

## Use case 7. How does the literature cluster theories with empirical methods?

**Setup.** You want a TCCM-style summary table — the standard
management literature review framework (Paul et al. 2024) — showing
which theories are commonly combined with which contexts and methods.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) context(context) method(method) iv(iv) tccmclass(iv) tccmminfreq(2) outdir(ex07_tccm)

use "ex07_tccm/tables/litdiscover_tccm.dta", clear
gsort -n
list theory context method tccm_class_field n in 1/15, noobs abbrev(15)
```

**What this produces.** The top 15 four-way combinations of theory,
context, method, and characteristic field, ranked by frequency. The
`tccmclass(iv)` argument tells the package to use the independent
variable as the characteristic axis (alternatives are dv, mod, med,
decision, or journal).

**Interpretation.** This table is the central deliverable of a TCCM
literature review. Each row reports a configuration that has appeared
in at least `tccmminfreq` documents. High-frequency rows indicate
established research streams; absent or low-frequency rows indicate
gaps that future research might fill.

**Note.** TCCM tables can grow very large with many distinct values
per field. Adjust `tccmminfreq()` to control the table size: 1 keeps
every observed combination; 2 keeps only those appearing in at least
two documents; 5 keeps only well-established patterns.

---

## Use case 8. What are the most central theories in the literature network?

**Setup.** You want a network-analytic view of which theories co-occur
most often with others. The reasoning is that highly central theories anchor the literature, and 
peripheral theories appear in isolation.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) topics(5) netmeasures outdir(ex08_network)

use "ex08_network/tables/litdiscover_network_measures.dta", clear
keep if field == "theory"
gsort -strength
list value degree strength betweenness community, noobs abbrev(25)
```

**What this produces.** For each theoretical perspective, the number
of direct co-occurrences (degree), the weighted co-occurrence strength
(strength), the betweenness centrality (how often the theory sits on
the shortest path between two others), and the Louvain community
assignment.

**Interpretation.** High strength means the theory frequently co-appears
with many others; this is a central, well-connected theory. High
betweenness with moderate strength signals a bridging theory that
connects otherwise separate parts of the literature. Theories in the
same Louvain community tend to be combined together; theories in
different communities are alternative paradigms.

**Note.** Louvain community indices are zero-based within each network
and are not comparable across fields. Modularity is reported as a
network-level scalar broadcast to every row of its network.

---

## Use case 9. Which terms are distinctive of each topic versus generic?

**Setup.** The default top-terms list ranks terms by raw weight, which
favours frequent terms. You want a ranking that balances frequency
with exclusivity, i.e., terms that are both frequent within a topic and
rare in other topics.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(8) frex outdir(ex09_frex)

use "ex09_frex/tables/litdiscover_topicterms.dta", clear

* Compare the by-weight ranking with the by-FREX ranking for topic 1.
list topic rank term weight frex if topic == 1 & rank <= 10, noobs
gsort topic -frex
by topic: gen frex_rank = _n
list topic rank term weight frex frex_rank if topic == 1 & frex_rank <= 10, noobs abbrev(15)
```

**What this produces.** Each topic's top terms ranked two ways: by raw
weight (the default) and by FREX (FRequency-EXclusivity score, Roberts,
Stewart, and Tingley 2019). Compare the two rankings to see which
terms are distinctive versus generic.

**Interpretation.** Terms that rank high on weight but low on FREX are
generic because they appear in many topics and are dominated by frequency alone.
Terms that rank high on both are the theory-distinctive vocabulary you
want to feature when labelling topics or describing them in a paper.
For a corpus with deliberately theory-specific anchors, FREX usually
elevates the anchor terms.

**Note.** The default FREX omega is 0.5 (equal weight on frequency and
exclusivity). The empirical cumulative distribution function is computed per topic over the full
vocabulary.

---

## Use case 10. Can I use the topic shares as variables in a regression?

**Setup.** You want to use the LDA output as features in a downstream
econometric model — for example, regressing an outcome on the
prevalence of different theoretical perspectives.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) noautoload outdir(ex10_regression)

* doctopic has one row per document; merge it with your input dataset by study_id.
use "ex10_regression/tables/litdiscover_doctopic.dta", clear
merge 1:1 study_id using "ex10_regression/tables/_litdiscover_input_recovery.dta", nogen

* Example: Do topic 1 shares vary by publication year?
regress topic_1 year
```

**What this produces.** A document-level dataset where each row has
five topic-share columns (`topic_1` through `topic_5`), the dominant
topic, its share, and every variable from your input dataset.

**Interpretation.** Topic shares are continuous variables in [0, 1] that
sum to 1 within each document. They can be used as features, but with
caveats. Because they sum to 1, including all K shares in the same
regression causes perfect collinearity; drop one as the reference
category. Topic shares are also noisy estimates from a stochastic LDA
fit, so standard errors do not reflect the uncertainty in the topic
modelling step.

**Note.** This is a legitimate downstream use of LDA. Regressing
within-topic-table quantities (like the `weight` column of
`litdiscover_topicterms.dta` on the `rank` column) is not — the two
are deterministically related, since rank is a function of weight.

---

## Use case 11. How do I return to my input dataset after a run?

**Setup.** Because the package autoloads the topic-terms table by
default, your original input dataset is no longer in memory. You want
it back.

```stata
* Option A: re-load the original file directly.
use "litdiscover_example500.dta", clear

* Option B: use the recovery copy that litdiscover saved automatically.
use "ex01_minimal/tables/_litdiscover_input_recovery.dta", clear

* Option C: suppress autoloading at the next run.
use "C:\YOUR_FOLDER\C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) noautoload
* Your input dataset stays in memory; no recovery needed.
```

**What this produces.** Three equivalent ways to keep working with
your input data. Option A is the simplest if your input file is at a
known path. Option B uses the recovery file that the package writes to the
tables directory; the absolute path is reported at the end-of-run
summary and in `r(input_recovery_file)`. Option C suppresses the
autoload for the next run.

**Interpretation.** The autoload behaviour is designed for casual and
interactive exploration where the first thing the researcher wants is
to inspect the topics. If you are running `litdiscover` inside a
larger workflow that needs the input dataset to stay in memory, use
`noautoload`.

**Note.** The recovery file is named `_litdiscover_input_recovery.dta`
and lives in the same `tables/` directory as the output files. It is
written once per run and overwritten on the next run.

---

## References

The methodological foundations cited in this guide are documented in
full in `help litdiscover` under the References section. Key
references are:

- Blei, D. M., Ng, A. Y., and Jordan, M. I. 2003. Latent Dirichlet
  allocation. *Journal of Machine Learning Research* 3: 993–1022.
- Greene, D., O'Callaghan, D., and Cunningham, P. 2014. How many
  topics? Stability analysis for topic models. *ECML PKDD 2014*,
  LNCS 8724, 498–513.
- Mimno, D., Wallach, H. M., Talley, E., Leenders, M., and
  McCallum, A. 2011. Optimizing semantic coherence in topic models.
  *EMNLP 2011*, 262–272.
- Paul, J., Khatri, P., and Duggal, H. K. 2024. Frameworks for
  developing impactful systematic literature reviews and theory
  building: What, Why and How? *Journal of Decision Systems*
  33(4): 537-550.
- Roberts, M. E., Stewart, B. M., and Tingley, D. 2019. stm: An R
  package for structural topic models. *Journal of Statistical
  Software* 91(2): 1–40.

---

## Citation

When citing `litdiscover` in academic work, please use:

Davcik, N. S. 2026. *litdiscover: A Stata package for theory-aware
literature review and discovery.* Available at:
https://github.com/Davcik/litdiscover
