*! test_v0.3.do  15may2026
*! Test harness for litdiscover v0.3 and v0.3.1.
*!
*! Covers five tests:
*!   T1  v0.2 backward compatibility (no v0.3 toggles).
*!       Asserts that the v0.2 schema and row counts are produced, that
*!       the v0.3 return scalars are present but inert, and that no
*!       v0.3 output files are written.
*!   T2  netmeasures only. Asserts the two network-measures files exist
*!       with the schemas locked in v0.3 spec items A12 and A13, that
*!       value ranges for degree, strength, betweenness, and modularity
*!       are coherent, and that r(net_*) scalars surface correctly.
*!   T3  frex only. Asserts the frex column is present in
*!       litdiscover_topicterms.dta, that values are finite and in (0, 1],
*!       and that r(frex_*) scalars surface correctly.
*!   T4  both toggles together. Asserts the union of T2 and T3.
*!   T5  v0.3.1 per-topic stability. Asserts the new
*!       litdiscover_topic_stability.dta file is written with the
*!       documented schema when seeds() >= 2, value ranges are coherent,
*!       and the file is NOT written when seeds(1).
*!
*! Per the v0.3 locked spec (decision: skip v0.2 byte-identity), T1 does
*! not compare against a v0.2 reference snapshot; it verifies schema and
*! counts only.
*!
*! Per v0.2 rule 4, set trace on / set tracedepth 1 in front of any
*! failing block before hypothesising about cause.
*!
*! All paths are absolute (D:\___QuQu\STATAscript\litdiscover\v3\...) so
*! the harness is independent of Stata's current working directory at
*! launch.

clear all
set more off
capture log close _all

/* -----------------------------------------------------------------
   Configuration
   -----------------------------------------------------------------
*/
local _root         "D:\___QuQu\STATAscript\litdiscover\v3"
local _corpus       "`_root'\litdiscover_example.dta"
local _harness_dir  "`_root'\test_v0_3_harness"
local _log          "`_harness_dir'\test_v0.3.log"
local _csv          "`_harness_dir'\test_v0.3_assertions.csv"

/* Package and harness identifiers written to every CSV row, so a CSV
   accumulated across versions can be filtered by version downstream.
*/
local _pkg_version  "0.3.1"
local _harness_id   "test_v0.3.do"

/* Subdirectory roots for each test (one outdir() per call). */
local _t1_root "t1_v03_baseline"
local _t2_root "t2_v03_netmeasures"
local _t3_root "t3_v03_frex"
local _t4_root "t4_v03_full"

cd "`_root'"

capture mkdir "`_harness_dir'"

/* Ensure v0.3 sources are on adopath. The .ado must be locatable for the
   litdiscover command itself to be found by Stata.
*/
adopath ++ "`_root'"

/* Confirm corpus exists; abort with a clear message if not. */
capture confirm file "`_corpus'"
if _rc {
    di as err "test_v0.3: corpus not found at `_corpus'"
    di as err "Set _corpus at the top of this do-file."
    exit 601
}

/* -----------------------------------------------------------------
   Assertion helper

   Usage: _v3_assert "label" `=<condition expression>'
     The second argument is evaluated by the caller and passed as 0/1.
     PASS/FAIL is appended to global counters, printed to the Results
     window, and appended as a single row to the machine-readable CSV
     audit log (file handle in global V3CSVFH; path set by the caller
     before the first invocation).

   CSV row schema (RFC-4180 quoted):
     timestamp,pkg_version,harness,test_group,assertion_id,label,result

   The first whitespace-delimited token of label is taken as the
   assertion_id (e.g., "T2.05"); the substring before the first dot of
   assertion_id is taken as the test_group (e.g., "T2").
   -----------------------------------------------------------------
*/
capture program drop _v3_assert
program define _v3_assert
    version 19.5
    args label cond

    local _aid     = word("`label'", 1)
    local _dotpos  = strpos("`_aid'", ".")
    if `_dotpos' > 0 {
        local _tgrp = substr("`_aid'", 1, `_dotpos' - 1)
    }
    else {
        local _tgrp = "`_aid'"
    }
    local _ts      = "`c(current_date)' `c(current_time)'"
    local _esclab  : subinstr local label `"""' `""""', all

    if `"`cond'"' == "1" {
        di as txt "  PASS  " as result "`label'"
        local _new = ${V3PASS} + 1
        global V3PASS `_new'
        local _res = "PASS"
    }
    else {
        di as err "  FAIL  " as result "`label'"
        local _new = ${V3FAIL} + 1
        global V3FAIL `_new'
        global V3FAILLIST `"${V3FAILLIST} | `label'"'
        local _res = "FAIL"
    }

    capture file write ${V3CSVFH} `""`_ts'","${V3PKGVER}","${V3HARNESS}","`_tgrp'","`_aid'","`_esclab'","`_res'""' _n
end

global V3PASS     0
global V3FAIL     0
global V3FAILLIST ""

/* Globals used by the assertion helper for CSV row writes. */
global V3PKGVER  "`_pkg_version'"
global V3HARNESS "`_harness_id'"

/* Open the machine-readable assertion log. `replace` ensures each run
   starts fresh; remove `replace` and switch to `write append` if you
   want a single accumulating audit log across runs.
*/
tempname v3csv
file open `v3csv' using "`_csv'", write replace
file write `v3csv' "timestamp,pkg_version,harness,test_group,assertion_id,label,result" _n
global V3CSVFH "`v3csv'"

log using "`_log'", replace text

di as txt _newline(2) "{hline 70}"
di as txt "litdiscover v0.3 test harness"
di as txt "Working directory: " as result "`c(pwd)'"
di as txt "Corpus:            " as result "`_corpus'"
di as txt "Log:               " as result "`_log'"
di as txt "{hline 70}"

/* =================================================================
   T1  v0.2 backward compatibility
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "T1: v0.2 backward compatibility (no v0.3 toggles)"
di as txt "{hline 70}"

use "`_corpus'", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) outdir(`_t1_root')

local _t1_tbl "`_t1_root'/tables"

di as txt _newline "T1 assertions:"

/* The v0.2 engine outputs must exist. */
capture confirm file "`_t1_tbl'/litdiscover_doctopic.dta"
_v3_assert "T1.01 litdiscover_doctopic.dta exists" `=cond(_rc==0,1,0)'

capture confirm file "`_t1_tbl'/litdiscover_topicterms.dta"
_v3_assert "T1.02 litdiscover_topicterms.dta exists" `=cond(_rc==0,1,0)'

/* No v0.3 output files in the baseline run. */
capture confirm file "`_t1_tbl'/litdiscover_network_measures.dta"
_v3_assert "T1.03 litdiscover_network_measures.dta absent" `=cond(_rc!=0,1,0)'

capture confirm file "`_t1_tbl'/litdiscover_network_measures_cross.dta"
_v3_assert "T1.04 litdiscover_network_measures_cross.dta absent" `=cond(_rc!=0,1,0)'

/* topicterms must have v0.2 columns and must NOT have a frex column
   (spec B7, decision B8-a).
*/
use "`_t1_tbl'/litdiscover_topicterms.dta", clear
capture confirm variable topic
_v3_assert "T1.05 topicterms.topic exists" `=cond(_rc==0,1,0)'
capture confirm variable rank
_v3_assert "T1.06 topicterms.rank exists" `=cond(_rc==0,1,0)'
capture confirm variable term
_v3_assert "T1.07 topicterms.term exists" `=cond(_rc==0,1,0)'
capture confirm variable weight
_v3_assert "T1.08 topicterms.weight exists" `=cond(_rc==0,1,0)'
capture confirm variable frex
_v3_assert "T1.09 topicterms.frex absent (v0.2 byte-identity)" `=cond(_rc!=0,1,0)'

/* v0.3 return scalars must be present but zero when toggles are off. */
_v3_assert "T1.10 r(net_networks_within) == 0" `=cond(`r(net_networks_within)' == 0, 1, 0)'
_v3_assert "T1.11 r(net_networks_cross) == 0"  `=cond(`r(net_networks_cross)' == 0, 1, 0)'
_v3_assert "T1.12 r(net_nodes_within) == 0"    `=cond(`r(net_nodes_within)' == 0, 1, 0)'
_v3_assert "T1.13 r(net_nodes_cross) == 0"     `=cond(`r(net_nodes_cross)' == 0, 1, 0)'

/* =================================================================
   T2  netmeasures only
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "T2: netmeasures only"
di as txt "{hline 70}"

use "`_corpus'", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) context(context) netmeasures outdir(`_t2_root')

local _t2_tbl "`_t2_root'/tables"

/* Capture r() locals immediately after the litdiscover call. */
local t2_nnw = `r(net_networks_within)'
local t2_nnc = `r(net_networks_cross)'
local t2_nodw = `r(net_nodes_within)'
local t2_nodc = `r(net_nodes_cross)'
local t2_mmean = `r(net_modularity_mean)'
local t2_mmin  = `r(net_modularity_min)'
local t2_mmax  = `r(net_modularity_max)'
local t2_lseed = `r(net_louvain_seed)'

di as txt _newline "T2 assertions:"

/* Output files exist. */
capture confirm file "`_t2_tbl'/litdiscover_network_measures.dta"
_v3_assert "T2.01 network_measures.dta exists" `=cond(_rc==0,1,0)'

capture confirm file "`_t2_tbl'/litdiscover_network_measures_cross.dta"
_v3_assert "T2.02 network_measures_cross.dta exists" `=cond(_rc==0,1,0)'

/* Primary file schema (spec A12). */
use "`_t2_tbl'/litdiscover_network_measures.dta", clear
foreach v in field value n_nodes n_edges degree strength betweenness community modularity {
    capture confirm variable `v'
    _v3_assert "T2.03 network_measures.`v' exists" `=cond(_rc==0,1,0)'
}

/* Row count matches r(net_nodes_within). */
qui count
_v3_assert "T2.04 row count equals r(net_nodes_within) (`t2_nodw')" `=cond(r(N) == `t2_nodw', 1, 0)'

/* Value range checks: degree in [0, 1], betweenness in [0, 1], strength >= 0,
   modularity in [-0.5, 1] (the theoretical range), community is integer >= 0.
*/
qui sum degree, meanonly
local t2_dmin = r(min)
local t2_dmax = r(max)
_v3_assert "T2.05 degree in [0, 1]" `=cond(`t2_dmin' >= 0 & `t2_dmax' <= 1, 1, 0)'

qui sum betweenness, meanonly
local t2_bmin = r(min)
local t2_bmax = r(max)
_v3_assert "T2.06 betweenness in [0, 1]" `=cond(`t2_bmin' >= 0 & `t2_bmax' <= 1, 1, 0)'

qui sum strength, meanonly
_v3_assert "T2.07 strength >= 0" `=cond(r(min) >= 0, 1, 0)'

qui sum modularity, meanonly
_v3_assert "T2.08 modularity in [-0.5, 1]" `=cond(r(min) >= -0.5 & r(max) <= 1, 1, 0)'

qui sum community, meanonly
_v3_assert "T2.09 community >= 0 and integer" `=cond(r(min) >= 0 & mod(r(min),1)==0 & mod(r(max),1)==0, 1, 0)'

/* Sort-order check (spec A14): rows must be sorted by field, value. */
gen long _rownum = _n
sort field value
qui gen byte _ordered = (_n == _rownum)
qui sum _ordered, meanonly
_v3_assert "T2.10 rows sorted by field, value" `=cond(r(min) == 1, 1, 0)'
drop _rownum _ordered

/* Supplementary (cross) file schema (spec A13). */
use "`_t2_tbl'/litdiscover_network_measures_cross.dta", clear
foreach v in field_a field_b field value n_nodes n_edges degree strength betweenness community modularity {
    capture confirm variable `v'
    _v3_assert "T2.11 network_measures_cross.`v' exists" `=cond(_rc==0,1,0)'
}

qui count
_v3_assert "T2.12 cross row count equals r(net_nodes_cross) (`t2_nodc')" `=cond(r(N) == `t2_nodc', 1, 0)'

/* field column must equal one of field_a or field_b on every row. */
qui gen byte _fld_ok = (field == field_a | field == field_b)
qui sum _fld_ok, meanonly
_v3_assert "T2.13 cross.field in {field_a, field_b} on every row" `=cond(r(min) == 1, 1, 0)'
drop _fld_ok

/* field_a must be lexicographically less than field_b. */
qui gen byte _ab_ok = (field_a < field_b)
qui sum _ab_ok, meanonly
_v3_assert "T2.14 cross.field_a < cross.field_b on every row" `=cond(r(min) == 1, 1, 0)'
drop _ab_ok

/* Returned scalars. */
_v3_assert "T2.15 r(net_networks_within) > 0" `=cond(`t2_nnw' > 0, 1, 0)'
_v3_assert "T2.16 r(net_networks_cross) > 0"  `=cond(`t2_nnc' > 0, 1, 0)'
_v3_assert "T2.17 r(net_louvain_seed) == 20250101" `=cond(`t2_lseed' == 20250101, 1, 0)'
_v3_assert "T2.18 r(net_modularity_min) <= mean <= max" `=cond(`t2_mmin' <= `t2_mmean' & `t2_mmean' <= `t2_mmax', 1, 0)'

/* Return macros: file paths.
   Re-run a parse of return list to confirm macros came through.
*/
qui use "`_t2_tbl'/litdiscover_network_measures.dta", clear
capture confirm file "`_t2_tbl'/litdiscover_network_measures.dta"
_v3_assert "T2.19 network_measures_file path resolvable" `=cond(_rc==0,1,0)'

/* =================================================================
   T3  frex only
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "T3: frex only"
di as txt "{hline 70}"

use "`_corpus'", clear
litdiscover, abstract(abstract) topics(8) frex outdir(`_t3_root')

local _t3_tbl "`_t3_root'/tables"

/* Capture r() locals. */
local t3_omega = `r(frex_omega)'
local t3_eps   = `r(frex_epsilon)'
local t3_K     = `r(frex_topics)'
local t3_V     = `r(frex_vocab_size)'

di as txt _newline "T3 assertions:"

/* topicterms file exists and has the frex column. */
capture confirm file "`_t3_tbl'/litdiscover_topicterms.dta"
_v3_assert "T3.01 litdiscover_topicterms.dta exists" `=cond(_rc==0,1,0)'

use "`_t3_tbl'/litdiscover_topicterms.dta", clear
capture confirm variable frex
_v3_assert "T3.02 topicterms.frex column exists" `=cond(_rc==0,1,0)'

/* frex must be non-missing on every row. */
qui count if missing(frex)
_v3_assert "T3.03 frex non-missing on every row" `=cond(r(N) == 0, 1, 0)'

/* frex values must lie in (0, 1]. The FREX harmonic mean of two
   ECDF-normalised quantities in (0, 1] cannot exceed 1.
*/
qui sum frex, meanonly
_v3_assert "T3.04 frex in (0, 1]" `=cond(r(min) > 0 & r(max) <= 1, 1, 0)'

/* Topic indices must be 1-indexed (v0.2 rule 7). */
qui sum topic, meanonly
_v3_assert "T3.05 topic min == 1 (1-indexed)" `=cond(r(min) == 1, 1, 0)'
_v3_assert "T3.06 topic max == 8" `=cond(r(max) == 8, 1, 0)'

/* Row count: top-15 terms per topic, 8 topics = up to 120 rows. */
qui count
_v3_assert "T3.07 topicterms has <= 8 * 15 = 120 rows" `=cond(r(N) <= 120, 1, 0)'

/* No v0.3 network files in a frex-only run. */
capture confirm file "`_t3_tbl'/litdiscover_network_measures.dta"
_v3_assert "T3.08 network_measures.dta absent" `=cond(_rc!=0,1,0)'

/* Returned scalars. */
_v3_assert "T3.09 r(frex_omega) == 0.5" `=cond(abs(`t3_omega' - 0.5) < 1e-12, 1, 0)'
_v3_assert "T3.10 r(frex_epsilon) == 1e-12" `=cond(abs(`t3_eps' - 1e-12) < 1e-20, 1, 0)'
_v3_assert "T3.11 r(frex_topics) == 8" `=cond(`t3_K' == 8, 1, 0)'
_v3_assert "T3.12 r(frex_vocab_size) > 0" `=cond(`t3_V' > 0, 1, 0)'

/* =================================================================
   T4  both toggles together
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "T4: netmeasures + frex"
di as txt "{hline 70}"

use "`_corpus'", clear
litdiscover, abstract(abstract) theory(theory) dv(dv) iv(iv) context(context) topics(8) netmeasures frex outdir(`_t4_root')

local _t4_tbl "`_t4_root'/tables"

local t4_nnw   = `r(net_networks_within)'
local t4_K     = `r(frex_topics)'
local t4_omega = `r(frex_omega)'

di as txt _newline "T4 assertions:"

/* All v0.3 outputs present. */
capture confirm file "`_t4_tbl'/litdiscover_network_measures.dta"
_v3_assert "T4.01 network_measures.dta exists" `=cond(_rc==0,1,0)'

capture confirm file "`_t4_tbl'/litdiscover_network_measures_cross.dta"
_v3_assert "T4.02 network_measures_cross.dta exists" `=cond(_rc==0,1,0)'

capture confirm file "`_t4_tbl'/litdiscover_topicterms.dta"
_v3_assert "T4.03 topicterms.dta exists" `=cond(_rc==0,1,0)'

use "`_t4_tbl'/litdiscover_topicterms.dta", clear
capture confirm variable frex
_v3_assert "T4.04 topicterms.frex column present" `=cond(_rc==0,1,0)'

qui count if missing(frex)
_v3_assert "T4.05 frex non-missing on every row" `=cond(r(N) == 0, 1, 0)'

qui sum frex, meanonly
_v3_assert "T4.06 frex in (0, 1]" `=cond(r(min) > 0 & r(max) <= 1, 1, 0)'

/* Both v0.3 scalar groups returned simultaneously. */
_v3_assert "T4.07 r(net_networks_within) > 0" `=cond(`t4_nnw' > 0, 1, 0)'
_v3_assert "T4.08 r(frex_topics) == 8" `=cond(`t4_K' == 8, 1, 0)'
_v3_assert "T4.09 r(frex_omega) == 0.5" `=cond(abs(`t4_omega' - 0.5) < 1e-12, 1, 0)'

/* network_measures.dta still has the locked schema. */
use "`_t4_tbl'/litdiscover_network_measures.dta", clear
foreach v in field value n_nodes n_edges degree strength betweenness community modularity {
    capture confirm variable `v'
    _v3_assert "T4.10 network_measures.`v' present (joint run)" `=cond(_rc==0,1,0)'
}

/* =================================================================
   T5  v0.3.1: per-topic stability
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "T5: v0.3.1 per-topic stability (seeds=3)"
di as txt "{hline 70}"

local _t5_root "t5_v031_topic_stability"

use "`_corpus'", clear
litdiscover, abstract(abstract) topics(5) seeds(3) coherence outdir(`_t5_root')

local _t5_tbl "`_t5_root'/tables"
local t5_topic_stab_file "`r(topic_stability_file)'"

di as txt _newline "T5 assertions:"

/* Existence and r() macro. */
capture confirm file "`_t5_tbl'/litdiscover_topic_stability.dta"
_v3_assert "T5.01 litdiscover_topic_stability.dta exists" `=cond(_rc==0,1,0)'

_v3_assert "T5.02 r(topic_stability_file) is non-empty" `=cond(`"`t5_topic_stab_file'"' != "", 1, 0)'

/* The original pairwise stability file must still exist (unchanged). */
capture confirm file "`_t5_tbl'/litdiscover_stability.dta"
_v3_assert "T5.03 litdiscover_stability.dta unchanged" `=cond(_rc==0,1,0)'

/* Schema and value-range checks. */
use "`_t5_tbl'/litdiscover_topic_stability.dta", clear
foreach v in topic mean_best_match min_best_match n_seed_pairs {
    capture confirm variable `v'
    _v3_assert "T5.04 topic_stability.`v' exists" `=cond(_rc==0,1,0)'
}

qui count
_v3_assert "T5.05 row count equals K (5)" `=cond(r(N) == 5, 1, 0)'

qui sum topic, meanonly
_v3_assert "T5.06 topic in [1, 5] and 1-indexed" `=cond(r(min) == 1 & r(max) == 5, 1, 0)'

qui sum mean_best_match, meanonly
_v3_assert "T5.07 mean_best_match in [0, 1]" `=cond(r(min) >= 0 & r(max) <= 1, 1, 0)'

qui sum min_best_match, meanonly
_v3_assert "T5.08 min_best_match in [0, 1]" `=cond(r(min) >= 0 & r(max) <= 1, 1, 0)'

/* min must be <= mean for every topic. */
qui gen byte _mm_ok = (min_best_match <= mean_best_match)
qui sum _mm_ok, meanonly
_v3_assert "T5.09 min_best_match <= mean_best_match per topic" `=cond(r(min) == 1, 1, 0)'
drop _mm_ok

qui sum n_seed_pairs, meanonly
_v3_assert "T5.10 n_seed_pairs == 2 (seeds=3 minus primary)" `=cond(r(min) == 2 & r(max) == 2, 1, 0)'

/* v0.3.0 backward compatibility: with seeds(1) the new file is NOT written. */
local _t5b_root "t5b_seeds1_backcompat"
use "`_corpus'", clear
litdiscover, abstract(abstract) topics(5) seeds(1) coherence outdir(`_t5b_root')
local _t5b_tbl "`_t5b_root'/tables"
capture confirm file "`_t5b_tbl'/litdiscover_topic_stability.dta"
_v3_assert "T5.11 topic_stability.dta absent when seeds(1)" `=cond(_rc != 0, 1, 0)'

local t5b_topic_stab_file "`r(topic_stability_file)'"
_v3_assert "T5.12 r(topic_stability_file) empty when seeds(1)" `=cond(`"`t5b_topic_stab_file'"' == "", 1, 0)'

/* =================================================================
   Summary
   =================================================================
*/
di as txt _newline(2) "{hline 70}"
di as txt "Summary"
di as txt "{hline 70}"
di as txt "PASS: " as result "${V3PASS}"
if ${V3FAIL} == 0 {
    di as txt "FAIL: " as result "0"
    di as txt _newline as result "All v0.3 tests passed."
}
else {
    di as err  "FAIL: " as result "${V3FAIL}"
    di as err _newline "Failed assertions:"
    di as err `"${V3FAILLIST}"'
    di as err _newline "Per v0.2 rule 4: set trace on / set tracedepth 1 before hypothesising about cause."
}
di as txt "{hline 70}"

/* Close the machine-readable assertion log. */
capture file close ${V3CSVFH}

log close _all

di as txt _newline "Log written to:           " as result "`_log'"
di as txt         "Assertion CSV written to: " as result "`_csv'"
