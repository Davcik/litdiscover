# Changelog

All notable changes to the `litdiscover` Stata package are documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The references that motivated specific design choices are cited in
the help file (`help litdiscover`) under `References`.

## [1.0] - 2026-05-17

First public release.

### Added in 1.0

- Stable public API for the `litdiscover` command and its short-form
  alias `litdi`.
- Full documentation in `litdiscover.sthlp`, including Author,
  Citation, Licence, and References sections.
- GPL-3.0-or-later licensing, with `LICENSE` and `CITATION.cff`.
- A 500-observation synthetic example dataset
  (`litdiscover_example500.dta`).

## [0.3.1] - 2026-05-13

### Added in 0.3.1

- Per-topic LDA stability via Jaccard similarity across random seeds.
  When `seeds(K)` with K >= 2, the package writes
  `litdiscover_topic_stability.dta` (columns `topic`,
  `mean_best_match`, `min_best_match`, `n_seed_pairs`). Complements
  pairwise stability for combined coherence-plus-stability diagnostics
  (Greene, O'Callaghan, and Cunningham 2014).
- New `r(topic_stability_file)` macro.

## [0.3.0] - 2026-05-10

### Added in 0.3.0

- `netmeasures` toggle: degree centrality, weighted strength,
  betweenness centrality, Louvain communities, and modularity over
  the construct co-occurrence tables. Produces
  `litdiscover_network_measures.dta` and
  `litdiscover_network_measures_cross.dta` (one row per node).
  Louvain seed 20250101, resolution 1.0.
- `frex` toggle: adds a `frex` column to
  `litdiscover_topicterms.dta` (Roberts, Stewart, and Tingley 2019,
  section 3.4; omega = 0.5, empirical CDF per topic).
- Helper script `litdiscover_net.py` for network computations.
- New `r()` returns for network and FREX scalars and file paths.

## [0.2.6] - 2026-05-03

### Added in 0.2.6

- `figures` toggle for static visualisations (Stata-tier via
  `heatplot` and `palettes`; Python-tier via matplotlib, seaborn,
  wordcloud).
- `interactive` toggle for three HTML deliverables: pyLDAvis topic
  explorer (Sievert and Shirley 2014), pyvis force-directed
  co-occurrence network, plotly Sankey diagram.
- `outdir()` option for a subdirectory layout (tables, figures,
  interactive).
- pyLDAvis-ready compressed NumPy interchange file derived from the
  primary-seed model, so the visualisation matches the `.dta`
  outputs.
- Helper script `litdiscover_viz.py` for Python-side visualisations.

## [0.2.0] - 2026-04-19

### Added in 0.2.0

- Block A baseline: LDA engine in `litdiscover.py`, called from
  `litdiscover.ado`.
- UMass coherence (Mimno et al. 2011) via the `coherence` toggle.
- Multi-seed Jaccard stability across LDA fits via `seeds(K)`.
- Construct extraction for the TCCM (Paul et al. 2024) and ADO
  frameworks: theory, dependent variable, independent variable,
  moderator, mediator, decision, context, method, journal, year.

## [0.1] - 2026-03-15

Internal development. Not publicly released.
