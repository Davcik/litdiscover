# litdiscover

A Stata package for theory-aware literature review and discovery.

`litdiscover` combines an inductive component — latent Dirichlet
allocation (LDA) topic modelling of abstract text — with a deductive
overlay of researcher-coded construct fields (theory, dependent
variable, independent variable, moderator, mediator, decision,
context, method, journal, year). It produces topic-by-field
cross-tabulations, TCCM and ADO framework outputs, network-analytic
measures over construct co-occurrences, FREX exclusivity scores,
per-topic stability diagnostics, UMass coherence, and a suite of
static figures and interactive HTML deliverables suitable for
systematic literature reviews in management, marketing, and adjacent
fields.

The short-form alias `litdi` is provided as a convenience.

---

## Installation

`litdiscover` is currently distributed via GitHub. SSC distribution
is planned for a future v1.x release.

To install the development version from this repository, run inside
Stata:

```stata
net install litdiscover, from("https://raw.githubusercontent.com/Davcik/litdiscover/main/")
```

You will additionally need:

- **Python 3.10 or later** configured for use with Stata (see
  `help python`). The package uses `pandas`, `numpy`, `scikit-learn`,
  `scipy`, and `networkx` by default; for the `figures` and
  `interactive` options, also `matplotlib`, `seaborn`, `wordcloud`,
  `pyLDAvis`, `pyvis`, and `plotly`.
- **SSC packages** `heatplot`, `palettes`, and `colrspace`
  (only when the `figures` option is used):

```stata
ssc install heatplot
ssc install palettes
ssc install colrspace
```

---

## Quick start

A minimal call requires only a corpus dataset with an `abstract`
variable:

```stata
use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5)
```

This fits a 5-topic LDA model on the abstract text and writes the
document-topic and topic-term tables to the `./output/tables/`
directory.

For a comprehensive demonstration of the package's capabilities —
seven worked examples in Stata Journal style covering coherence and
stability diagnostics, year-stratified topic prevalence, TCCM and
ADO frameworks, FREX exclusivity scoring, network-analytic measures
on construct co-occurrences, and the full publication-ready pipeline
with static figures and interactive HTML — see:

- The documentation: `help litdiscover` inside Stata

For a researcher-oriented walkthrough of twelve common use cases —
labelling topics, year stratification, network analysis, regression on
topic shares, and more — see [USECASES.md](USECASES.md).

---

## Documentation

Run `help litdiscover` inside Stata after installation. The help
file documents every option, every output file, every returned
scalar and macro, and provides the full reference list.

Selected references (see `help litdiscover` under `References` for
the complete list):

- Blei, D. M., Ng, A. Y., and Jordan, M. I. 2003. Latent Dirichlet
  allocation. *Journal of Machine Learning Research* 3: 993-1022.
- Greene, D., O'Callaghan, D., and Cunningham, P. 2014. How many
  topics? Stability analysis for topic models. *ECML PKDD 2014*,
  LNCS 8724, 498-513.
- Mimno, D., Wallach, H. M., Talley, E., Leenders, M., and
  McCallum, A. 2011. Optimizing semantic coherence in topic models.
  *EMNLP 2011*, 262-272.
- Roberts, M. E., Stewart, B. M., and Tingley, D. 2019. stm: An R
  package for structural topic models. *Journal of Statistical
  Software* 91(2): 1-40.

---

## Example dataset

The repository includes `litdiscover_example500.dta`, a 500-document
synthetic corpus covering five theoretical perspectives
(resource-based view, dynamic capabilities, signalling theory,
institutional theory, stakeholder theory) and ten marketing and
management journals (*Journal of Marketing*, *JMR*, *JCR*, *JAMS*,
*IJRM*, *AMJ*, *AMR*, *SMJ*, *Journal of Management*, *Organization
Science*) over the 2008-2025 window. The dataset is synthetic but
constructed to mirror the statistical structure of a real systematic
literature review corpus, including approximately 6 percent empty
abstracts, 7 percent missing values in non-required fields,
2 percent missing years, and 9-18 percent multi-valued construct
cells.

The dataset is intended for documentation, examples, and testing.
For research use, replace it with your own coded corpus.

---

## Version history

See [CHANGELOG.md](CHANGELOG.md) for the full version history.

---

## Citation

When citing `litdiscover` in academic work, please use:

> Davcik, N. S. 2026. *litdiscover: A Stata package for theory-aware
> literature review and discovery.* Available at:
> [https://github.com/Davcik/litdiscover](https://github.com/Davcik/litdiscover)

A [CITATION.cff](CITATION.cff) file is provided in the repository
root for GitHub's "Cite this repository" feature and for ingestion
by reference managers such as Zotero, Mendeley, and JabRef.

---

## Licence

`litdiscover` is released under the
[GNU General Public License version 3 or later](https://www.gnu.org/licenses/gpl-3.0.html)
(GPL-3.0-or-later). You may redistribute and modify it under the
terms of that licence; modified versions and larger works that
incorporate `litdiscover` must also be released under GPL-3 or
later. See [LICENSE](LICENSE) for the full text.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

---

## Author

**Nebojsa S. Davcik**
EM Normandie Business School, Oxford, UK
ORCID: [0000-0003-1041-8788](https://orcid.org/0000-0003-1041-8788)
Email: davcik {@} live.com

---

## Contributing

Issue reports, feature requests, and pull requests are welcome via
the [GitHub issue tracker](https://github.com/Davcik/litdiscover/issues).
For substantive proposals (new options, new output schemas, changes
to the package's API), please open an issue for discussion before
submitting a pull request, so the design can be agreed before
implementation.
