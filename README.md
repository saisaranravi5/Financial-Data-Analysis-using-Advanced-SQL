# Financial-Data-Analysis-using-Advanced-SQL

> 25+ queries. 5 modules. One screening engine that actually scales.

## Overview
Financial screening in Excel breaks at scale — slow to update, hard to audit, easy to corrupt. This project replaces that workflow with a structured SQL engine (built in MySQL) that screens 170 U.S. public companies across profitability, growth, valuation, ownership, and sector benchmarking — consistently and reproducibly.

**Tech stack:** MySQL · Power Query · Excel

## The Question
Can SQL do what a financial analyst does in Excel — faster and without the manual errors?

Screening hundreds of companies for investment health, valuation, and growth potential in Excel is slow, inconsistent, and breaks the moment the data changes. This project builds a locally run SQL screening engine to do that job at scale.

## Business Problem
Investors and analysts who need to screen U.S. public companies typically rely on Excel filters and manual lookups. That works for 10 companies — it does not work for 200. The goal was to build something modular and reusable, where changing one parameter updates the entire screening without touching formulas manually.

## Data & Cleaning
- Started with raw data on **226** U.S. listed companies.
- Cleaned in Power Query: a `dataStatus` column flagged each record as *Complete* or *Missing* based on 17 critical financial fields. Records flagged *Missing* were excluded, leaving a working dataset of **171 companies**.
- **Key decision:** missing values were not replaced with zeros or averages — in finance, zero is not neutral (a missing `totalRevenue` of zero falsely implies no revenue). Removing those rows was the more honest choice.
- All monetary figures were scaled to millions to prevent integer overflow in MySQL and improve query readability.

## The Engine: 5 Modules, 25 Queries

### Module 1 — Profitability & Operational Efficiency
Classifies companies into High/Moderate/Low profitability tiers, benchmarks EBITDA margins by industry, ranks top-3 ROE companies per industry using window functions, and flags "triple margin champions" (gross, operating, and EBITDA margins all above 25%).
- **Findings:** 56 of 171 companies qualified as High Profitability; 61 met the triple-margin threshold.

### Module 2 — Growth Analytics
Classifies companies by PEG ratio (Undervalued Growth / Fairly Valued / Overvalued), finds top revenue-growth company per industry, and benchmarks each company against its industry average using a CTE.
- **Findings:** 32 of 171 companies had a PEG ratio below 1 — growth underpriced relative to earnings.

### Module 3 — Valuation Metrics
Builds a composite valuation score (average of forward PE and price-to-book) to rank companies.
- **Findings:** Pfizer had the lowest score (potentially undervalued); Tesla and Netflix sat at the expensive end; Verizon and GM traded below their industry's average forward PE.

### Module 4 — Ownership & Governance
Ranks companies by shares outstanding (dilution risk), calculates average insider holding % by industry, flags low-insider/high-public-float companies as vulnerable to outside pressure, and estimates dollar value of insider holdings.

### Module 5 — Sector-Wide Benchmarking
Ranks industries by average revenue growth, finds top operating-margin company per sector, and flags each industry as overvalued/undervalued relative to the market average forward PE.

## Limitations
This is a point-in-time snapshot — it doesn't account for earnings revisions, macro conditions, or business model changes. The Module 3 valuation score is a simplified composite and shouldn't be used as standalone investment advice. Records with missing data were excluded, so smaller/newer companies may be underrepresented.

