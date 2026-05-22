# litdiscover

A Stata package for theory-aware literature review, analysis, and
discovery.

`litdiscover` combines latent Dirichlet allocation (LDA) topic
modelling of abstract text with a deductive overlay of researcher-coded
construct fields (theory, dependent variable, independent variable,
moderator, mediator, decision, context, method, journal, year). It
produces topic-by-field cross-tabulations, TCCM and ADO framework
outputs, network-analytic measures over construct co-occurrences,
FREX exclusivity scores, per-topic stability diagnostics, UMass
coherence, and a suite of static figures and interactive HTML
deliverables. The package is designed for systematic literature
reviews across management, marketing, organisation studies,
information systems, education, health policy, and the broader
social and behavioural sciences.

The short-form alias `litdi` is provided as a convenience.

---

## Installation

`litdiscover` is currently distributed via GitHub and SSC distribution

Inside Stata:

```stata
ssc install litdiscover
```

To install from this repository, run inside Stata:

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

## Documentation

For full reference documentation (every option, every output file,
every returned scalar and macro, and the complete reference list),
run `help litdiscover` inside Stata after installation.

For a research-question-organised guide with seven worked examples,
see [`USECASES.md`](USECASES.md).

For the version history, see [`CHANGELOG.md`](CHANGELOG.md).

---

## Example dataset

The repository includes `litdiscover_example500.dta`, a 500-document
synthetic corpus covering five theoretical perspectives and ten
journals over 2008–2025, constructed to mirror the statistical
structure of a real systematic literature review corpus. It is
intended for documentation, examples, and testing; for research use,
replace it with your own coded corpus.

---

## Citation

When citing `litdiscover` in academic work, please use:

> Davcik, N. S. 2026. *LITDISCOVER: Stata module for theory-aware
> literature review, analysis, and discovery.* Statistical Software Components S459718,
> Boston College Department of Economics, Available at:
> [https://ideas.repec.org/c/boc/bocode/s459718.html](https://ideas.repec.org/c/boc/bocode/s459718.html)

A [CITATION.cff](CITATION.cff) file is provided in the repository
root for GitHub's "Cite this repository" feature and for ingestion by
reference managers such as Zotero, Mendeley, and JabRef.

---

## Licence

`litdiscover` is released under the
[GNU General Public License version 3 or later](https://www.gnu.org/licenses/gpl-3.0.html)
(GPL-3.0-or-later). You may redistribute and modify it under the
terms of that licence; modified versions and larger works that
incorporate `litdiscover` must also be released under GPL-3 or later.
See [LICENSE](LICENSE) for the full text.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

---

## Author

**Nebojsa S. Davcik**
EM Normandie Business School, Oxford, UK
ORCID: [0000-0003-1041-8788](https://orcid.org/0000-0003-1041-8788)
Email: davcik@live.com

---

## Contributing

Issue reports and feature requests are welcome via
the [GitHub issue tracker](https://github.com/Davcik/litdiscover/issues).
For substantive proposals (new options, new output schemas, changes
to the package's API), please open an issue for discussion before
submitting a pull request.
