# Fundamental Investment Assistant — MVP Requirements

**Status:** Draft v0.2  
**Initial audience:** Personal use  
**Market:** Indian equities  
**Primary data source:** Upstox, subject to field and coverage validation

## 1. Product purpose

Help the user evaluate investment opportunities when the market, a sector or an individual stock falls.

The main experience is a daily advisory brief explaining:

- Which companies deserve further attention.
- Why their prices have become interesting.
- Whether their fundamentals remain healthy.
- How sector conditions affect the investment case.
- What risks or missing evidence prevent a stronger conclusion.

A stock screener is a secondary feature.

## 2. Primary use case

“Today the market is down, or a sector has declined over the past month. Show me companies with sound fundamentals and potentially attractive valuations. Explain whether the decline appears to offer an opportunity or reflects a weakening business.”

The app must distinguish three separate observations:

1. **Price decline:** The stock has become cheaper in price.
2. **Valuation:** Its price may or may not be attractive relative to earnings and peers.
3. **Business condition:** The company’s future earnings and financial health may have changed.

A price decline alone does not qualify a company as an opportunity.

## 3. Main experience: Opportunity Brief

The home page answers:

### What has fallen?

Show the latest available:

- Broad-market daily and one-month change.
- Sector daily and one-month change.
- Company daily and one-month change.

Clearly identify the benchmark, measurement dates and data freshness. If using a selected group of stocks as a sector proxy, label it as such.

### Which companies deserve attention?

Show a short list of up to five candidates from the covered universe.

Each candidate includes:

- Price decline and comparison with its sector.
- Fundamental strengths.
- Valuation compared with relevant peers.
- Sector pressure and supporting evidence.
- Main risks.
- A research conclusion with a clear explanation.

If nothing qualifies, say so. Do not fill the list with weak candidates.

## 4. Opportunity assessment

Evaluate each company through four separate checks.

| Check | Questions |
|---|---|
| Price movement | Has the company declined? Is it moving with its sector or falling more sharply? |
| Business quality | Is it profitable? Are returns on capital, cash generation and debt levels acceptable? |
| Valuation | Is valuation reasonable relative to comparable companies? Could unusually high earnings make P/E misleading? |
| Sector and company risk | Is there evidence of temporary pressure, lasting damage or an unresolved problem? |

Use configurable rules and show the underlying figures.

Keep quality, valuation and risk visible separately. Do not compress them into an unexplained “buy score.”

## 5. Research conclusions

Use these initial categories:

- **Worth researching:** Meets the configured quality and valuation checks; reviewed evidence has not identified a major deterioration.
- **Watch and wait:** Potentially interesting, but uncertainty or sector pressure needs monitoring.
- **Fundamental concerns:** Financial weakness or adverse developments undermine the apparent opportunity.
- **Insufficient evidence:** Data is missing, stale or the reason for the decline is unverified.

These categories prioritize research. They do not represent a probability of profit.

## 6. Sector-pressure assessment

For the MVP, maintain a small manual research note for each covered sector.

Each note records:

- What is putting the sector under pressure.
- Source link and publication date.
- Possible effect on sales, margins, debt or valuation.
- Assessment: potentially temporary, potentially structural, mixed or unknown.
- Conditions that would support recovery.
- Evidence that would invalidate the recovery case.
- Last review date.

The app may flag a sector’s falling prices automatically. It must not infer the cause or likely recovery from price movement alone.

Manual notes keep the first version achievable without building an automated news-research system.

## 7. Candidate explanation

Every opportunity card must answer:

1. Why did this company appear?
2. What supports the business-quality assessment?
3. What supports the valuation assessment?
4. What is known about the decline—and what remains unknown?
5. How could sector pressure affect future results?
6. What should the user check next?

### Illustrative example — fictional company

**ABC Industries — Watch and wait**

- Price has fallen 12% over one month; its sector benchmark fell 8%.
- Latest reported profitability and operating cash flow remain positive.
- P/E is below the selected peer benchmark.
- A reviewed sector note identifies weaker demand, which could reduce future earnings.
- Lower valuation may offer an opportunity, but current earnings may not reflect the slowdown.
- Next checks: upcoming results, margin changes and debt movement.

All figures and explanations in the actual app must come from available data or explicitly identified research notes.

## 8. Minimum data requirements

### Market data

- Latest price and timestamp.
- Previous closing price.
- Sufficient daily history for one-month returns.
- Relevant market and sector benchmark data.
- Corporate-action handling so splits and similar events do not appear as genuine price collapses.

### Fundamental data

- P/E and its documented earnings basis.
- ROE and/or ROCE.
- Revenue and profit history.
- Operating cash flow.
- Debt and equity, where consistently available.
- Peer or sector valuation benchmarks.
- Statement basis and reporting periods.

### Context

- Company sector and industry.
- Recent sector research note.
- Company-specific concerns, if reviewed.
- Sources and review timestamps.

Unavailable inputs remain unavailable; they must not silently count as a passed check.

## 9. MVP screens

1. **Opportunity Brief:** Market context and explained candidates.
2. **Company Analysis:** Financial evidence, valuation, sector context and risks.
3. **Watchlist:** Saved companies and personal notes.
4. **Explore:** Basic screener and company comparison.

## 10. Fastest implementation scope

Start with:

- 30–50 nonfinancial companies.
- Three sectors.
- Daily and one-month price movements.
- Manual data refresh with cached results.
- Rule-based candidate selection.
- Template-based explanations.
- Manually maintained sector notes.
- Private access on one computer.

Choose a research horizon explicitly—for example, 1–3 years. A daily decline is the discovery trigger, not a promise of a short-term rebound.

## 11. Out of scope

- Automated trading.
- Intraday recommendations.
- Target prices and return predictions.
- Personalized portfolio allocation.
- Automated claims about why prices moved.
- Fully automated news interpretation.
- Public advisory service, subscriptions and multiple users.

A public or personalized advisory offering requires a separate review of the applicable regulatory and data-licensing requirements before launch.

## 12. Acceptance criteria

The MVP is complete when:

- A market or sector decline can surface qualifying companies.
- Every candidate shows the rules and evidence behind its inclusion.
- Weak fundamentals can prevent a falling stock from qualifying.
- Sector and company risks appear alongside positive findings.
- Unknown causes are labeled unknown.
- Old financial results are not presented as proof that the business is healthy today.
- Price movements are checked for corporate-action distortions.
- Missing data and stale research are clearly visible.
- The user can inspect, save and compare candidates.
- The app can return “No qualifying opportunities.”

## 13. First development milestone

Validate five companies across the selected sectors:

1. Fetch prices and fundamentals from Upstox.
2. Confirm reporting periods, ratio definitions and historical coverage.
3. Add one sourced sector note per sector.
4. Produce an explained opportunity brief.
5. Review the output manually before expanding coverage.

**Success:** The user can understand why a falling company deserves attention, what evidence supports that view, and what could invalidate it.
