# litdiscover: Use cases for researchers

This guide presents seven use cases for the `litdiscover` package,
each framed as a research question that a researcher conducting a
systematic literature review might ask. The seven cases trace a
natural workflow — descriptive overview, statistical robustness,
temporal pattern, qualitative validation, framework synthesis,
network structure, and downstream econometric use — and collectively
exhaust the principal analytic contributions of the package. Each
case gives a framing paragraph, the Stata code, and a short note on
what the output means, with methodological caveats only where
substantive.

The guide assumes that the package has been installed
(`net install litdiscover, from("https://raw.githubusercontent.com/Davcik/litdiscover/main/")`)
and that the example dataset `litdiscover_example500.dta` is
available. For full reference documentation, type
`help litdiscover` inside Stata.


---

## A note about the example dataset

The use cases below load the example dataset using:

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
```

Replace `C:\YOUR_FOLDER\` with the actual path on your machine. If
you installed `litdiscover` via `net install`, the example dataset
sits in your `ado/plus/l/` directory; locate and copy it once with:

```stata
findfile litdiscover_example500.dta
copy "`r(fn)'" "C:\YOUR_FOLDER\litdiscover_example500.dta", replace
```

Every subsequent use case can then rely on the same path.


---

## Use case 1. What are the dominant themes in my corpus, and which terms distinguish each theme?

A first descriptive pass identifies the topics in the corpus and the
terms that most distinctively characterise each one.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) outdir(ex01_themes)
list topic rank term weight if rank <= 5, sepby(topic) noobs abbrev(20)
```

The output lists the five most characteristic terms for each of five
topics. Read the top terms and assign a substantive label: terms like
*resource*, *capability*, *valuable*, *rare* point to the
resource-based view; *sensing*, *seizing*, *reconfiguring* to dynamic
capabilities.

The default ranking by raw weight favours frequent terms. To rank by
FREX (FRequency-EXclusivity; Roberts, Stewart, and Tingley 2019),
which balances within-topic frequency against across-topic
exclusivity, add the `frex` toggle:

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) frex outdir(ex01_themes_frex)
gsort topic -frex
by topic: gen frex_rank = _n
list topic rank term weight frex frex_rank if topic == 1 & frex_rank <= 10, noobs abbrev(15)
```

Terms ranking high on weight but low on FREX are generic across
topics; terms ranking high on both are the theory-distinctive
vocabulary to feature when labelling topics in a paper.

*Note.* The number of topics is a researcher choice. The default of
5 is convenient for demonstration; for a real corpus, try several
values and inspect the diagnostics from Use case 2 before committing.


---

## Use case 2. Are my topics statistically robust?

Before reporting topics in a paper, verify that they are not
artefacts of a single LDA random initialisation. A topic that
disappears under a different random seed is not a stable finding.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) seeds(5) coherence outdir(ex02_robust)

use "ex02_robust/tables/litdiscover_topic_stability.dta", clear
tempfile stab
qui save `stab', replace

use "ex02_robust/tables/litdiscover_coherence.dta", clear
qui merge 1:1 topic using `stab', nogen

list topic umass mean_best_match min_best_match, noobs
```

Each topic receives two diagnostics. UMass coherence (Mimno et al.
2011) measures internal consistency of the top terms; closer to zero
is more coherent. Mean best-match Jaccard similarity (Greene,
O'Callaghan, and Cunningham 2014) measures how reliably the topic
re-emerges across seeds; closer to 1 is more stable. A topic with
both umass above roughly -2 and mean_best_match above 0.5 is a
robust finding suitable for reporting; one that fails either should
be reported with caution or excluded.

*Note.* The synthetic example dataset has deliberate theoretical
anchors and produces highly stable topics; real corpora typically
show more variation.


---

## Use case 3. Have any theoretical perspectives gained prominence over time?

To assess whether certain themes are becoming more or less prevalent
in the literature across publication years:

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) year(year) topics(5) figures outdir(ex03_year)

use "ex03_year/tables/litdiscover_topic_by_year.dta", clear
list year topic mean_share n_docs if topic == 1, noobs
```

The table gives the mean topic share and document count for each
(year, topic) cell, together with a line plot saved to
`ex03_year/figures/litdiscover_fig_topicyear.png`. A topic whose mean
share rises across years is a theme gaining prominence; one whose
share falls is being supplanted. Treat low-document-count cells with
caution.

*Note.* The pattern is descriptive, not causal. Topic-share shifts
over time reflect what authors choose to publish, what journals
accept, and what reviewers recommend, jointly.


---

## Use case 4. Which documents most strongly represent each topic?

This is the qualitative validation step: confirm that the topic
labels assigned in Use case 1 fit the documents that load most
heavily on each topic.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) outdir(ex04_validate)

use "ex04_validate/tables/litdiscover_doctopic.dta", clear

forvalues k = 1/5 {
    di as txt _newline "Top 5 documents for topic `k':"
    gsort -topic_`k'
    list study_id topic_`k' in 1/5, noobs
}
```

For each topic, the five top-share documents are listed by
`study_id`. Open the input dataset, retrieve those abstracts, and
read them. If the abstracts for topic 1 are visibly about RBV, the
label is validated; if not, revise it.

*Note.* This step is the standard qualitative validation in
management literature reviews (Paul et al. 2024). Skipping it is
the most common source of misclaim in topic-modelling papers.


---

## Use case 5. How does the literature cluster theories with empirical contexts and methods?

The TCCM framework (Paul et al. 2024) gives a four-way summary table
of how theories combine with contexts, methods, and a characteristic
axis. The same call also produces a two-way topic-by-field view
without further options.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) context(context) method(method) iv(iv) tccmclass(iv) tccmminfreq(2) outdir(ex05_tccm)

use "ex05_tccm/tables/litdiscover_tccm.dta", clear
gsort -n
list theory context method iv n in 1/15, noobs abbrev(15)

use "ex05_tccm/tables/litdiscover_topic_by_field.dta", clear
keep if field == "context"
list value topic mean_share n_docs if mean_share > 0.3, noobs sepby(value)
```

The TCCM table is the central deliverable of a TCCM review. The
`tccmclass(iv)` argument selects the independent variable as the
characteristic axis (alternatives are `dv`, `mod`, `med`, `decision`,
`journal`); the output column is named accordingly. High-frequency
rows indicate established research streams; absent or low-frequency
rows indicate gaps that future research might fill. The topic-by-
field view complements this by revealing whether a theory is
preferentially applied to particular contexts.

*Note.* TCCM tables grow quickly. Use `tccmminfreq()` to control the
table size: 1 keeps every observed combination, 2 keeps those in at
least two documents, 5 keeps only well-established patterns.


---

## Use case 6. What are the most central theories in the literature network?

A network-analytic view identifies which theories anchor the
literature (high co-occurrence with others) and which appear in
isolation.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) topics(5) netmeasures outdir(ex06_network)

use "ex06_network/tables/litdiscover_network_measures.dta", clear
keep if field == "theory"
gsort -strength
list value degree strength betweenness community, noobs abbrev(25)
```

For each theory, the output gives the number of direct co-occurrences
(degree), the weighted co-occurrence strength (strength), the
betweenness centrality (how often the theory sits on the shortest
path between two others), and the Louvain community assignment. High
strength signals a central, well-connected theory; high betweenness
with moderate strength signals a bridging theory; theories in the
same community tend to be combined, theories in different communities
are alternative paradigms.

*Note.* Louvain community indices are zero-based within each network
and are not comparable across fields. The algorithm uses seed
20250101 and resolution 1.0 internally so that results are
reproducible.


---

## Use case 7. Can I use the topic shares as variables in a regression?

LDA output can serve as features in a downstream econometric model —
for example, regressing an outcome on the prevalence of different
theoretical perspectives.

```stata
use "C:\YOUR_FOLDER\litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) noautoload outdir(ex07_regression)

use "ex07_regression/tables/_litdiscover_input_recovery.dta", clear
capture drop __*
capture confirm string variable study_id
if _rc tostring study_id, replace
merge 1:1 study_id using "ex07_regression/tables/litdiscover_doctopic.dta", nogen

regress topic_1 year
```

The merged dataset has one row per document with five topic-share
columns (`topic_1` through `topic_5`), the dominant topic and its
share, and every variable from the input dataset. Topic shares are
continuous variables in [0, 1] that sum to 1 within each document.
The `capture drop __*` line removes any internal Stata tempvar
columns left in the recovery file by the package; the
`capture confirm` block then coerces `study_id` to string if your
input dataset stores it as numeric, because the LDA engine always
writes `study_id` as string in `litdiscover_doctopic.dta`, and the
two sides of the merge must agree on type.

*Note.* Because shares sum to 1, including all K shares in a
regression produces perfect collinearity; drop one as the reference
category. Topic shares are also noisy estimates from a stochastic
LDA fit, so standard errors do not reflect the uncertainty in the
topic modelling step.


---

## References

Full bibliographic details are in `help litdiscover` under
References. Key sources:

- Blei, D. M., Ng, A. Y., and Jordan, M. I. 2003. Latent Dirichlet
  allocation. *Journal of Machine Learning Research* 3: 993–1022.
- Greene, D., O'Callaghan, D., and Cunningham, P. 2014. How many
  topics? Stability analysis for topic models. *ECML PKDD 2014*,
  LNCS 8724, 498–513.
- Mimno, D., Wallach, H. M., Talley, E., Leenders, M., and McCallum,
  A. 2011. Optimizing semantic coherence in topic models.
  *EMNLP 2011*, 262–272.
- Paul, J., Khatri, P., and Duggal, H. K. 2024. Frameworks for
  developing impactful systematic literature reviews and theory
  building: What, Why and How? *Journal of Decision Systems* 33(4):
  537–550.
- Roberts, M. E., Stewart, B. M., and Tingley, D. 2019. stm: An R
  package for structural topic models. *Journal of Statistical
  Software* 91(2): 1–40.


---

## Citation

When citing `litdiscover` in academic work, please use:

Davcik, N. S. 2026. *litdiscover: A Stata package for theory-aware
literature review, analysis, and discovery.* Available at:
https://github.com/Davcik/litdiscover
