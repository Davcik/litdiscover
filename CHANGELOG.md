# Changelog

All notable changes to the `litdiscover` Stata package are documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The references that motivated specific design choices are cited in
the help file (`help litdiscover`) under `References`.

## [1.0] - 2026-05-15

First public release.

### Added in 1.0

- Stable public API for the `litdiscover` command and its short-form
  alias `litdi`.
- Full documentation in `litdiscover.sthlp`, including Author,
  Citation, Licence, and References sections.
- GPL-3.0-or-later licensing, with `LICENSE` and `CITATION.cff` files
  in the repository root.
- A 500-observation synthetic example dataset
  (`litdiscover_example500.dta`) covering five theoretical perspectives
  (resource-based view, dynamic capabilities, signalling theory,
  institutional theory, stakeholder theory) and ten marketing and
  management journals.
- A seven-example companion script (`litdiscover_examples_model.do`)
  demonstrating the principal capabilities of the package, with
  Stata Journal-style research-question framing and post-run
  interpretation for each example.
- An SMCL log wrapper (`litdiscover_examples_model_log.do`) that runs
  the examples script under a log and translates the result to plain
  text and PDF for inclusion in articles.
- A test harness (`test_v0.3.do`) covering 92 assertions across
  backward compatibility, network-analytic measures, FREX, per-topic
  stability, and joint-toggle invocation, with a machine-readable
  assertion log (CSV) for regression tracking across versions.

## [0.3.1] - 2026-05-13

### Added in 0.3.1

- Per-topic LDA stability measurement. When `seeds(K)` with K >= 2,
  the package now writes `litdiscover_topic_stability.dta` with
  columns `topic`, `mean_best_match`, `min_best_match`,
  `n_seed_pairs`. For each topic in the primary seed, these capture
  the mean and minimum best-match Jaccard similarity to the matched
  topics in each of the other K-1 seeds (via the Hungarian assignment
  already used for the pairwise stability table). Closes a gap for
  combined coherence-plus-stability diagnostics in line with
  Greene, O'Callaghan, and Cunningham (2014).
- New `r(topic_stability_file)` macro pointing to the new file.

### Unchanged in 0.3.1

- `litdiscover_stability.dta` (pairwise) schema and contents.
- All v0.3.0 toggles and outputs.

## [0.3.0] - 2026-05-10

### Added in 0.3.0

- `netmeasures` toggle. Computes degree centrality, weighted strength,
  betweenness centrality, Louvain community assignment, and
  modularity over the `cooc_within` and `cooc_cross` construct
  co-occurrence tables. Produces two new files
  (`litdiscover_network_measures.dta` and
  `litdiscover_network_measures_cross.dta`) with one row per node.
  Louvain communities use seed 20250101 and resolution 1.0.
- `frex` toggle. Adds a `frex` column to
  `litdiscover_topicterms.dta` containing the FREX
  (FRequency-EXclusivity) score per Roberts, Stewart, and Tingley
  (2019, section 3.4), with omega = 0.5 (the stm default) and an
  empirical CDF computed per topic over the full vocabulary.
- New helper script `litdiscover_net.py` for the network-analytic
  computations.
- New `r()` returns: `r(net_networks_within)`,
  `r(net_networks_cross)`, `r(net_nodes_within)`,
  `r(net_nodes_cross)`, `r(net_modularity_mean)`,
  `r(net_modularity_min)`, `r(net_modularity_max)`,
  `r(net_louvain_seed)`, `r(network_measures_file)`,
  `r(network_measures_cross_file)`, `r(frex_omega)`,
  `r(frex_epsilon)`, `r(frex_topics)`, `r(frex_vocab_size)`.

### Unchanged in 0.3.0

- v0.2 was strictly additive; every v0.2 test continued to pass
  byte-for-byte when neither new toggle was supplied.

## [0.2.6] - 2026-05-03

### Added in 0.2.6

- `figures` toggle for static visualisations. Stata-tier figures use
  `heatplot` and `palettes` (both SSC; Jann 2018, 2023). Python-tier
  figures use matplotlib, seaborn, and wordcloud.
- `interactive` toggle for three HTML deliverables:
  - pyLDAvis topic explorer (Sievert and Shirley 2014).
  - pyvis force-directed construct co-occurrence network.
  - plotly Sankey diagram mapping theories to topics.
- `outdir()` option for a subdirectory layout (tables, figures,
  interactive) that simplifies article supplementary materials.
- pyLDAvis-ready compressed NumPy interchange file containing the
  five arrays required by `pyLDAvis.prepare`, derived from the
  primary-seed model so the visualisation is mathematically
  guaranteed to match the `.dta` outputs.
- Helper script `litdiscover_viz.py` for Python-side visualisations.

### Architectural constraints introduced in 0.2.6

- Python integration via Stata `python script`, not shell.
- Construct extraction performed in Stata (not delegated to Python).
- `study_id` carried as a string throughout.
- Single outer `preserve` with tempfile-based state; no nested
  `preserve` blocks.
- No `///` line continuations anywhere in the package source.

## [0.2.0] - 2026-04-19

### Added in 0.2.0

- Block A baseline: LDA engine in `litdiscover.py`, called from
  `litdiscover.ado`.
- UMass coherence diagnostic (Mimno et al. 2011) via the
  `coherence` toggle.
- Multi-seed Jaccard stability across LDA fits via `seeds(K)`.
- Construct extraction for the TCCM (Paul and Criado 2020) and ADO
  frameworks: theory, dependent variable, independent variable,
  moderator, mediator, decision, context, method, journal, year.

## [0.1] - earlier development

Internal development. Not publicly released.
