*! litdiscover_examples_model_log.do  14may2026
*! Wrapper that runs litdiscover_examples_model.do under an SMCL log and then
*! translates the SMCL into plain-text and PDF for inclusion in a draft
*! article.
*!
*! Produces three files in the harness directory:
*!   litdiscover_examples_model.smcl  - native Stata log (open in Stata's
*!                                viewer or include verbatim in
*!                                LaTeX with the `stata` listing
*!                                style).
*!   litdiscover_examples_model.txt   - plain-text translation, suitable for
*!                                article appendices and code snippets.
*!   litdiscover_examples_model.pdf   - PDF translation, useful for sharing
*!                                with co-authors or reviewers without
*!                                Stata.
*!
*! All three files contain authentic Stata-rendered output from this
*! machine's installation. The user should regenerate them after any
*! change to litdiscover.ado, litdiscover.py, the synthetic corpus, or
*! the underlying scikit-learn version, because LDA topic numbering and
*! per-topic term lists are sensitive to all of these.

clear all
set more off
capture log close _all

/* -----------------------------------------------------------------
   Configuration. Adjust paths to your installation if different.
   -----------------------------------------------------------------
*/
local _root    "D:\___QuQu\STATAscript\litdiscover\v3"
local _examp   "`_root'\litdiscover_examples_model.do"
local _outdir  "`_root'\examples_log"
local _smcl    "`_outdir'\litdiscover_examples_model.smcl"
local _txt     "`_outdir'\litdiscover_examples_model.txt"
local _pdf     "`_outdir'\litdiscover_examples_model.pdf"

capture mkdir "`_outdir'"
cd "`_root'"

/* Sanity-check the source examples file. */
capture confirm file "`_examp'"
if _rc {
    di as err "litdiscover_examples_model.do not found at `_examp'"
    exit 601
}

/* -----------------------------------------------------------------
   Run the examples under an SMCL log.

   The translator argument 'smcl' keeps the native colour and bold/italic
   SMCL tags. set linesize 100 keeps long output rows readable when the
   SMCL is later translated to plain text or PDF; widen if your output
   would otherwise wrap inside table-like blocks.
   -----------------------------------------------------------------
*/
set linesize 100

log using "`_smcl'", smcl replace name(litdiscover_examples_model_log)

display _newline _newline
display "============================================================="
display "litdiscover v0.3 examples log"
display "Generated: " "`c(current_date)' `c(current_time)'"
display "Stata version: " c(stata_version) "  flavor: " c(flavor)
display "Working directory: `c(pwd)'"
display "============================================================="
display _newline

do "`_examp'"

display _newline _newline
display "============================================================="
display "End of litdiscover v0.3 examples log"
display "============================================================="

log close litdiscover_examples_model_log

/* -----------------------------------------------------------------
   Post-process: translate SMCL to plain text and PDF.

   translate ... .txt produces a UTF-8 plain-text rendering with all
   SMCL formatting stripped. This is the format that typesets cleanly
   in a Stata Journal article using the `stata` LaTeX listing style.

   translate ... .pdf relies on Stata's built-in PDF backend. The
   `replace` option overwrites any prior version. The page numbers,
   margins, and font are taken from Stata's PDF defaults; override with
   options on the translate command if needed for the journal style.
   -----------------------------------------------------------------
*/
translate "`_smcl'" "`_txt'", replace linesize(100) translator(smcl2txt)
display as txt "Plain-text translation written to: " as result "`_txt'"

capture translate "`_smcl'" "`_pdf'", replace
if _rc == 0 {
    display as txt "PDF translation written to:        " as result "`_pdf'"
}
else {
    display as err "PDF translation failed (rc = " _rc ")"
    display as err "This is non-fatal. The SMCL and TXT files are unaffected."
    display as err "See {help translate} for translator availability on your system."
}

/* -----------------------------------------------------------------
   Summary
   -----------------------------------------------------------------
*/
display _newline as txt "Examples-log files in: " as result "`_outdir'"
display as txt "SMCL: " as result "`_smcl'"
display as txt "TXT:  " as result "`_txt'"
display as txt "PDF:  " as result "`_pdf'"
