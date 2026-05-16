*! litdiscover_examples_model.do  14may2026
*! Worked examples for litdiscover v0.3 using the litdiscover_example500
*! synthetic dataset. Companion to the package documentation and the
*! basis for the example section of an eventual Stata Journal article.
*!
*! Style follows the Stata Journal convention: each example states a
*! research question, presents the litdiscover call, displays the relevant
*! output, and briefly interprets the result. The examples progress from
*! minimal to comprehensive use of the package.
*!
*! Dataset: 500 fictional management/marketing abstracts covering five
*! theoretical perspectives (resource-based view, dynamic capabilities,
*! signalling theory, institutional theory, stakeholder theory) published
*! in five marketing journals (J. Marketing, JMR, JCR, JAMS, IJRM) and
*! five management journals (AMJ, AMR, SMJ, J. Management, Org. Science)
*! between 2008 and 2025. The dataset is synthetic but constructed to
*! mirror the statistical structure of a real systematic literature
*! review corpus, including ~6% empty abstracts, ~7% missing values in
*! non-required fields, ~2% missing years, and 9-18% multi-valued
*! construct cells.
*!
*! Prerequisites:
*!   - Stata 19.5 or later.
*!   - Python 3 configured for Stata use (see help python).
*!   - litdiscover.ado, litdiscover.py, litdiscover_net.py on adopath.
*!   - Python packages: pandas, numpy, scikit-learn, scipy, networkx.
*!   - For Examples 6 and 7: matplotlib, seaborn, wordcloud, pyldavis,
*!     pyvis, plotly; SSC packages heatplot, palettes, colrspace.
*!
*! Reference for the FREX exclusivity score (Example 5):
*!   Roberts, M. E., Stewart, B. M., and Tingley, D. 2019. stm: An R
*!   package for structural topic models. Journal of Statistical Software
*!   91(2), 1-40. https://doi.org/10.18637/jss.v091.i02

clear all
set more off

/* -----------------------------------------------------------------
   Set the working directory to the location of the dataset.
   -----------------------------------------------------------------
*/
cd "D:\___QuQu\STATAscript\litdiscover\v3"
adopath ++ "D:\___QuQu\STATAscript\litdiscover\v3"

/* -----------------------------------------------------------------
   Helper sub-program: list files written by an example.

   Called at the end of each example block with the example's outdir
   path. Lists the contents of the tables, figures, and interactive
   subdirectories. If a subdirectory does not exist or is empty,
   Windows dir reports "File Not Found" and execution continues.

   Usage: _ex_listing "ex02_diagnostics"
   -----------------------------------------------------------------
*/
capture program drop _ex_listing
program define _ex_listing
    version 19.5
    args dir
    di as txt _newline "Files written to `dir':"
    foreach sub in tables figures interactive {
        di as txt "  [`sub']"
        shell dir /b "`dir'\`sub'" 2>nul
    }
end

/* =================================================================
   Example 1: Minimal call (LDA engine only)
   =================================================================
   Research question: what topical themes emerge from the abstract text
   alone, before any deductive construct overlay? This is the most basic
   application of the package, useful when the researcher has only the
   abstract field and no pre-coded construct annotations.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) outdir(ex01_minimal)
return list

/* Examine the inferred topics. */
use "ex01_minimal/tables/litdiscover_topicterms.dta", clear
list topic rank term weight if rank <= 5, sepby(topic) noobs abbrev(20)

/* Interpretation. The five top-term sets typically correspond to the
   five theoretical perspectives because the synthetic abstracts contain
   theory-specific vocabulary anchors (e.g., "valuable rare inimitable"
   for RBV, "sensing seizing reconfiguring" for dynamic capabilities,
   "asymmetric information costly signal" for signalling). The
   litdiscover_doctopic.dta file maps each document to its dominant topic
   and the topic-share vector, which can then be merged with other
   document metadata for downstream analysis.
*/

_ex_listing "ex01_minimal"

/* =================================================================
   Example 2: Combined per-topic coherence and stability diagnostics
   =================================================================
   Research question: are the topics inferred by LDA both internally
   coherent (semantically meaningful word groupings) and stable across
   random initialisations (robust to the LDA random seed)? A topic that
   scores well on both dimensions is a substantively credible finding;
   a topic that scores poorly on either dimension is a methodological
   warning. Inspecting the two diagnostics jointly, per topic, is the
   recommended practice in the topic-modelling validation literature
   (Mimno et al. 2011 for UMass coherence; Greene, O'Callaghan, and
   Cunningham 2014 for stability via top-term Jaccard similarity).

   This example uses seeds(5), which produces 10 pairwise comparisons
   and yields a stable per-topic estimate of the mean best-match Jaccard
   (the v0.3.1 per-topic stability table). Combined with UMass, the two
   metrics characterise each topic in a coherence-by-stability plane.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) topics(5) seeds(5) coherence outdir(ex02_diagnostics)
return list

/* Merge the two per-topic diagnostic tables on topic. */
use "ex02_diagnostics/tables/litdiscover_coherence.dta", clear
tempfile coh_tmp
qui save `coh_tmp', replace

use "ex02_diagnostics/tables/litdiscover_topic_stability.dta", clear
qui merge 1:1 topic using `coh_tmp', nogen

/* Add a four-tier quality rating combining the two dimensions.
   Cutoffs:
     UMass: more coherent if umass >= -2 (Mimno et al. 2011 report
            values in the 0 to -14 range; -2 separates well-formed from
            mixed topics on most corpora).
     Stability: stable if mean_best_match >= 0.5 (Greene et al. 2014
                treat 0.5 as a permissive threshold; 0.7 as strict).
*/
gen str14 quality = ""
replace quality = "high quality"        if umass >= -2 & mean_best_match >= 0.5
replace quality = "coherent unstable"   if umass >= -2 & mean_best_match <  0.5
replace quality = "stable incoherent"   if umass <  -2 & mean_best_match >= 0.5
replace quality = "low quality"         if umass <  -2 & mean_best_match <  0.5

order topic umass mean_best_match min_best_match n_seed_pairs quality
list topic umass mean_best_match min_best_match quality, noobs abbrev(22)

/* Visualise the two-dimensional diagnostic plane. Topic numbers are
   used as marker labels so the reader can identify problem topics.
*/
twoway (scatter mean_best_match umass, mlabel(topic) mlabposition(12) mlabsize(medium) msize(medium)), title("Topic quality: stability vs coherence") subtitle("seeds(5), 5 topics") xtitle("UMass coherence (less negative = more coherent)") ytitle("Mean best-match Jaccard (higher = more stable)") yline(0.5, lpattern(dash)) xline(-2, lpattern(dash)) note("Top-right quadrant: high-quality topics. Other quadrants flag issues.") legend(off)

/* Save the scatter to disk so it persists past the Stata session. */
capture mkdir "ex02_diagnostics/figures"
graph save   "ex02_diagnostics/figures/topic_quality.gph", replace
graph export "ex02_diagnostics/figures/topic_quality.png", width(2250) replace

/* Examine theory-level construct frequency. */
use "ex02_diagnostics/tables/litdiscover_construct_freq.dta", clear
keep if field == "theory"
gsort -n_docs
list value n_docs, noobs abbrev(40)

/* Interpretation. UMass coherence values near zero or slightly negative
   indicate strongly internally consistent topics; values more negative
   than -5 suggest noisy topics. Per-topic mean best-match Jaccard
   values near 1 indicate that the same top-term set emerges across
   random seeds; values below 0.4 indicate seed-sensitive topics. A
   topic in the high-coherence, high-stability quadrant of the scatter
   plot is robust and publication-ready; a topic in the low-coherence
   or low-stability quadrant warrants either increasing the topics()
   count, lowering minfreq(), or accepting the topic as a corpus-
   specific artefact. The construct-frequency table separately recovers
   the multinomial theory distribution built into the synthetic dataset.
*/

_ex_listing "ex02_diagnostics"

/* =================================================================
   Example 3: Year-stratified topic prevalence
   =================================================================
   Research question: how have the relative shares of the five theoretical
   perspectives evolved over the 2008-2025 review window? This is the
   canonical longitudinal literature review use case.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) year(year) topics(5) figures outdir(ex03_yearly)
return list

/* Examine the year-by-topic prevalence panel. */
use "ex03_yearly/tables/litdiscover_topic_by_year.dta", clear
list, noobs sepby(year) abbrev(15)

/* Interpretation. The litdiscover_topic_by_year.dta file gives the mean
   topic share per (year, topic) cell along with the document count. The
   year clustering toward 2018-2024 (built into the synthetic data via
   a Beta(2, 0.8) draw) is visible as concentrated activity in those
   years. The figures() toggle additionally writes a year-stratified
   topic prevalence line plot (litdiscover_topic_by_year.png and .gph)
   to the figures subdirectory, plus per-construct frequency bar charts.
   In a real corpus, the line plot is the headline longitudinal visual.
*/

_ex_listing "ex03_yearly"

/* =================================================================
   Example 4: Full construct extraction with TCCM and ADO frameworks
   =================================================================
   Research question: how do theoretical perspectives, empirical contexts,
   and methodological choices co-occur, and which decision/independent/
   dependent variables dominate the literature? This is the comprehensive
   deductive analysis aligned with the TCCM (Paul and Criado 2020) and
   ADO (antecedents/decisions/outcomes) frameworks.

   Display note. With a corpus of 500 documents and full construct
   coverage, the unfiltered TCCM file may contain hundreds of cells,
   most with frequency one or two. Listing them cell-by-cell floods the
   log without analytical benefit. We therefore retain the package
   default (tccmminfreq(1), every observed cell written to disk) but
   render the contents as compact marginal tabulations (theory by
   context and theory by method, collapsed across the other fields)
   plus a top-N listing of the best-populated four-way cells. The full
   unfiltered .dta remains available for any downstream analysis.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) mod(mod) med(med) decision(decision) context(context) method(method) journal(journal) year(year) topics(5) coherence figures outdir(ex04_tccm_ado)
return list

/* Inspect the unfiltered TCCM file. */
use "ex04_tccm_ado/tables/litdiscover_tccm.dta", clear
qui count
local _tccm_rows = r(N)
display as txt _newline "TCCM cells in litdiscover_tccm.dta: " as result `_tccm_rows'

if `_tccm_rows' == 0 {
    display as txt "No TCCM cells were written for this corpus and option set."
}
else {
    qui sum n
    display as txt "Cell frequency: min = " as result r(min) as txt "  max = " as result r(max) as txt "  mean = " as result %5.2f r(mean)

    /* Compact marginal tabulations.
       Theory by context (counts collapsed across method and dv).
    */
    preserve
    collapse (sum) n, by(theory context)
    drop if missing(n) | n == 0
    display as txt _newline "Theory by context (frequency-weighted):"
    qui count
    if r(N) > 0 {
        tabulate theory context [fw=n]
    }
    else {
        display as txt "(no cells)"
    }
    restore

    /* Theory by method (counts collapsed across context and dv). */
    preserve
    collapse (sum) n, by(theory method)
    drop if missing(n) | n == 0
    display as txt _newline "Theory by method (frequency-weighted):"
    qui count
    if r(N) > 0 {
        tabulate theory method [fw=n]
    }
    else {
        display as txt "(no cells)"
    }
    restore

    /* Top 10 best-populated four-way cells. */
    display as txt _newline "Top 10 TCCM cells by frequency:"
    gsort -n
    local _show = min(10, `_tccm_rows')
    list theory context method dv n in 1/`_show', noobs abbrev(35)
}

/* The ADO classification at the document level. */
use "ex04_tccm_ado/tables/litdiscover_ado.dta", clear
contract ado_class, freq(n)
list, noobs

/* Interpretation. The TCCM table cross-tabulates theory by context by
   method by characteristic (here, dv by default). The package default
   of tccmminfreq(1) writes every observed cell to disk; raise the
   threshold to filter the tail of singleton cells if desired (e.g.,
   tccmminfreq(3) for a smaller, denser file). The compact two-way
   tabulations above show the dominant theory-context and theory-method
   pairings; the top-10 listing surfaces the most frequent four-way
   cells. The ADO classification assigns each document to
   antecedents-only, decisions-only, outcomes-only, or one of the
   combination classes, depending on which of iv/decision/dv fields
   were populated. Returned scalars r(ado_a), r(ado_d), r(ado_o) give
   the row counts per class. The figures() toggle additionally writes
   the TCCM heatmap and the ADO bar chart to the figures subdirectory;
   these are the headline visuals for the deductive analysis section
   of a systematic review article.
*/

_ex_listing "ex04_tccm_ado"

/* =================================================================
   Example 5: FREX exclusivity (Block B, v0.3)
   =================================================================
   Research question: which terms are most distinctive of each topic,
   balancing within-topic frequency against across-topic exclusivity?
   The standard top-N-by-weight ranking can be dominated by terms that
   appear frequently in many topics (e.g., generic method or context
   words). The FREX score of Roberts, Stewart, and Tingley (2019)
   corrects for this by combining the empirical CDF of frequency with
   the empirical CDF of exclusivity in a harmonic mean.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) topics(5) frex outdir(ex05_frex)
return list

/* Top 5 terms per topic ranked by weight, with their FREX scores alongside. */
use "ex05_frex/tables/litdiscover_topicterms.dta", clear
list topic rank term weight frex if rank <= 5, sepby(topic) noobs abbrev(20)

/* Rerank each topic's terms by FREX and display the top 5 by FREX. */
gen long _orig = _n
bysort topic (frex): gen long frex_rank = _N - _n + 1
list topic frex_rank term weight frex if frex_rank <= 5, sepby(topic) noobs abbrev(20)

/* Interpretation. Comparing the by-weight ranking with the by-FREX ranking
   reveals which top terms are theory-distinctive versus broadly shared.
   In synthetic data with deliberate theory vocabulary anchors, the FREX
   reranking tends to elevate the anchor terms (e.g., "VRIN", "isomorphism")
   and demote shared method or context words. For the v0.3 default of
   omega = 0.5 (matching the stm package), FREX places equal weight on
   frequency and exclusivity. Returned scalars: r(frex_omega) = 0.5,
   r(frex_epsilon) = 1e-12, r(frex_topics), r(frex_vocab_size).
*/

_ex_listing "ex05_frex"

/* =================================================================
   Example 6: Network-analytic measures (Block C, v0.3)
   =================================================================
   Research question: which construct values are central in the corpus,
   and which form community clusters? With multiple construct fields,
   the package can produce within-field and cross-field co-occurrence
   networks. The v0.3 netmeasures option computes degree centrality,
   weighted strength, betweenness centrality, Louvain community
   assignment, and modularity for each network.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) context(context) method(method) topics(5) netmeasures figures outdir(ex06_network)
return list

/* Within-field network measures. List the top 10 nodes by betweenness
   in each field. High betweenness identifies bridging constructs that
   connect otherwise disjoint community clusters.
*/
use "ex06_network/tables/litdiscover_network_measures.dta", clear
bysort field (betweenness): gen long btw_rank = _N - _n + 1
list field value strength betweenness community modularity if btw_rank <= 5, sepby(field) noobs abbrev(35)

/* Cross-field bipartite network for context-by-method, identifying which
   contexts and methods co-occur most centrally.
*/
use "ex06_network/tables/litdiscover_network_measures_cross.dta", clear
keep if field_a == "context" & field_b == "method"
gsort -strength
list field value strength community modularity in 1/15, noobs abbrev(35)

/* Interpretation. The within-field network for theory connects
   perspectives that co-appear in multi-valued cells, revealing which
   theoretical combinations are commonly invoked (RBV with dynamic
   capabilities, signalling with institutional, etc.). The cross-field
   bipartite network for context-by-method identifies which methods are
   applied in which empirical contexts, with high-strength nodes acting
   as methodological anchors. The Louvain communities partition each
   network into clusters; modularity quantifies how clearly separated
   those clusters are (values near 0.5 or higher indicate strong cluster
   structure). The figures() toggle additionally writes per-field
   construct-frequency bar charts and the Stata-tier heatmaps of
   construct co-occurrences to the figures subdirectory.
*/

_ex_listing "ex06_network"

/* =================================================================
   Example 7: Comprehensive pipeline with figures and interactive HTML
   =================================================================
   Research question: produce a complete bibliometric and topical review
   deliverable with static figures (300 DPI PNG) for the manuscript and
   interactive HTML files (pyLDAvis, pyvis network, plotly Sankey) for
   the online supplementary materials.
   -----------------------------------------------------------------
*/

use "litdiscover_example500.dta", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) mod(mod) med(med) decision(decision) context(context) method(method) journal(journal) year(year) topics(5) seeds(5) coherence netmeasures frex figures interactive outdir(ex07_full)
return list

/* Inventory of figures and interactive deliverables produced. */
display "Figures produced (count = " r(figures_n) "):"
display r(figures_list)
display ""
display "Interactive HTMLs produced (count = " r(interactive_n) "):"
display r(interactive_list)

/* Interpretation. The figures directory contains construct-frequency bar
   charts per field, a year-stratified topic line plot, the ADO and TCCM
   heatmaps, per-topic small multiples of top terms, and one wordcloud per
   topic. The interactive directory contains the pyLDAvis topic explorer
   (a 2D embedding of topics with adjustable lambda), the pyvis force-
   directed construct co-occurrence network, and the plotly Sankey diagram
   mapping theories to topics via the document-level dominant assignments.
   The seeds(5) option additionally produces a pairwise Jaccard stability
   table that documents how robust the top-term sets are across random
   seeds, an important quality check for any LDA-based review.
*/

_ex_listing "ex07_full"

/* =================================================================
   Conclusion
   =================================================================
   These seven examples cover the principal capabilities of litdiscover
   v0.3. The minimal call (Example 1) is appropriate for exploratory
   analysis; Example 2 adds a single construct overlay; Example 3 adds
   longitudinal stratification; Example 4 produces a complete deductive
   analysis aligned with TCCM and ADO; Examples 5 and 6 invoke the v0.3
   additions for FREX exclusivity and network-analytic measures; and
   Example 7 produces a publication-ready deliverable with figures and
   interactive supplementary materials.

   For systematic literature reviews in management and marketing, the
   recommended workflow is:
     (a) Begin with Example 1 to confirm that meaningful topics emerge.
     (b) Iterate on topics() and minfreq() to balance topic granularity
         against UMass coherence (Example 2).
     (c) Add construct fields incrementally (Examples 3 and 4) as the
         coding scheme stabilises.
     (d) Use Examples 5 and 6 to identify distinctive vocabulary and
         bridging constructs.
     (e) Generate the manuscript-ready deliverable (Example 7) only after
         the analytic choices are settled.

   End of file.
*/
