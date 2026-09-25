// Stock Advisory - Mock Data Fixtures
// Sourced & Formatted according to APP_REQUIREMENTS.md and BACKEND_REQUIREMENTS.md
// Market: Indian Equities (IST / INR)

window.STOCK_ADVISORY_DATA = {
  meta: {
    tradingDate: "2026-09-24",
    tradingDateFormatted: "24-Sep-2026",
    sessionType: "Completed exchange session (T)",
    dataTimestamp: "2026-09-25T09:30:00+05:30",
    dataTimestampFormatted: "25-Sep-2026 09:30 AM IST",
    researchHorizon: "1–3 Years",
    coveredUniverseCount: 5,
    totalUniverseTarget: 35,
    universeLabel: "5 of 35 companies (Phase 1 verification slice)",
    provider: {
      name: "Upstox Analytics API",
      status: "connected",
      tokenValidUntil: "2027-08-14",
      lastLatencyMs: 142,
      rateLimitRemaining: "4,850 / 5,000 req/day"
    },
    ruleVersion: "v1.2 (Active since 20-Sep-2026)"
  },

  benchmarks: {
    broadMarket: {
      name: "NIFTY 50",
      symbol: "NIFTY_50",
      type: "Official Index",
      latestClose: 25120.40,
      dailyChangePercent: -1.35,
      monthlyChangePercent: -3.40,
      asOfDate: "24-Sep-2026"
    },
    sectors: [
      {
        id: "it",
        name: "Nifty IT Proxy",
        officialBenchmark: "Proxy Sector Basket (5 liquid stocks)",
        isProxy: true,
        proxyNote: "Locally constructed equal-weight basket of 5 covered liquid IT stocks used as proxy.",
        dailyChangePercent: -2.40,
        monthlyChangePercent: -7.10,
        coverageCount: 5
      },
      {
        id: "fmcg",
        name: "Nifty FMCG",
        officialBenchmark: "Nifty FMCG Official Index",
        isProxy: false,
        dailyChangePercent: -1.10,
        monthlyChangePercent: -2.80,
        coverageCount: 5
      },
      {
        id: "pharma",
        name: "Nifty Healthcare",
        officialBenchmark: "Nifty Healthcare Official Index",
        isProxy: false,
        dailyChangePercent: -0.75,
        monthlyChangePercent: -1.65,
        coverageCount: 5
      }
    ]
  },

  activeRules: [
    { id: "profit_positive", label: "Annual Net Profit > 0", rule: "Latest consolidated net profit must be strictly positive", threshold: "> ₹0 Cr", category: "quality" },
    { id: "cashflow_positive", label: "Operating Cash Flow > 0", rule: "Latest annual operating cash flow must be strictly positive", threshold: "> ₹0 Cr", category: "quality" },
    { id: "roce_min", label: "ROCE ≥ 15%", rule: "Return on Capital Employed must meet or exceed 15.0%", threshold: "≥ 15.0%", category: "quality" },
    { id: "debt_equity_max", label: "Total Debt / Equity ≤ 1.0", rule: "Verified total debt to shareholder equity with positive equity", threshold: "≤ 1.00x", category: "quality" },
    { id: "pe_below_sector", label: "P/E < Sector Benchmark", rule: "Positive company P/E strictly below verified Upstox sector benchmark", threshold: "< Sector Ratio", category: "valuation" },
    { id: "trigger_daily", label: "Daily Decline Trigger", rule: "Daily closing return on completed session ≤ -2.0%", threshold: "≤ -2.0%", category: "trigger" },
    { id: "trigger_monthly", label: "1-Month Decline Trigger", rule: "1-Month closing return on completed session ≤ -8.0%", threshold: "≤ -8.0%", category: "trigger" }
  ],

  sectorResearchNotes: [
    {
      sectorId: "it",
      sectorName: "Information Technology",
      title: "Global Enterprise Discretionary IT Spend Softening",
      sourceTitle: "Economic Times / Gartner Global IT Spending Q3 Update",
      sourceUrl: "https://economictimes.indiatimes.com/tech/ites/gartner-it-spending-forecast",
      publicationDate: "2026-09-14",
      reviewDate: "2026-09-20",
      nextReviewDate: "2026-10-20",
      pressureClassification: "Potentially temporary",
      severity: "Caution",
      summary: "US and European BFSI clients postponing non-critical transformation deals. Core application maintenance and AI pilot contracts remain resilient.",
      potentialImpact: "Operating margin pressure of 40-75 bps and muted 1-2 quarter revenue growth.",
      recoveryConditions: "Rebound in North American banking Q4 discretionary project approvals and rate-cut cycle budget releases.",
      invalidationCriteria: "Two consecutive quarters of TCV order-book drop > 8% or broad pricing cuts."
    },
    {
      sectorId: "fmcg",
      sectorName: "Fast Moving Consumer Goods & Paints",
      title: "Intensified Domestic Competition & Raw Material Volatility",
      sourceTitle: "Mint / Nielsen FMCG Volume & Distribution Tracker",
      sourceUrl: "https://livemint.com/industry/retail/nielsen-fmcg-rural-demand-tracker",
      publicationDate: "2026-09-05",
      reviewDate: "2026-09-18",
      nextReviewDate: "2026-10-18",
      pressureClassification: "Mixed (Temporary input costs, Structural new entrants)",
      severity: "Material concern",
      summary: "Aggressive capacity expansion and dealer incentives by new conglomerate entrants (Birla Opus in paints), compounded by crude-linked chemical input inflation.",
      potentialImpact: "Gross margin compression of 150-200 bps and higher promotional ad spending.",
      recoveryConditions: "Stabilization of market shares and raw material price softening.",
      invalidationCriteria: "Loss of premium tier retail channel dominance or gross margin fall below 38%."
    },
    {
      sectorId: "pharma",
      sectorName: "Pharmaceuticals & Healthcare",
      title: "Active Pharmaceutical Ingredient (API) Destocking Cycle Normalization",
      sourceTitle: "Business Standard / US FDA Inspection Overview",
      sourceUrl: "https://business-standard.com/industry/pharma-api-export-trends",
      publicationDate: "2026-09-18",
      reviewDate: "2026-09-22",
      nextReviewDate: "2026-10-22",
      pressureClassification: "Potentially temporary",
      severity: "Informational",
      summary: "Post-pandemic inventory destocking in generic APIs has concluded. Regulatory audit outcomes remain clean for Tier-1 facilities.",
      potentialImpact: "Moderate volume recovery in export contracts; capacity ramp-up for peptide intermediates.",
      recoveryConditions: "Sustained commercial shipments for patent-expiring molecules and GLP-1 contracts.",
      invalidationCriteria: "Issuance of warning letters or Form 483 with data integrity observations."
    }
  ],

  companies: [
    {
      isin: "INE467B01029",
      ticker: "TCS",
      name: "Tata Consultancy Services Ltd",
      sectorId: "it",
      sectorName: "Information Technology",
      industry: "IT Consulting & Software",
      exchange: "NSE",
      exchangeKey: "NSE_EQ|INE467B01029",
      currentPrice: 4180.50,
      priceDate: "2026-09-24",
      dailyChangePercent: -2.85,
      monthlyChangePercent: -8.45,
      sectorDailyChange: -2.40,
      sectorMonthlyChange: -7.10,
      corporateActionStatus: "Verified clean (No split/bonus distortion)",
      conclusion: "Worth researching",
      conclusionBadgeClass: "badge-worth-researching",
      declineTriggerMet: { daily: true, monthly: true },
      
      triggerSummary: "Stock fell -2.85% today (sector proxy -2.40%) and -8.45% over 1 month, crossing the -2.0% daily and -8.0% monthly discovery thresholds.",
      
      financials: [
        { period: "FY23", revenueCr: 225458, netProfitCr: 42147, ocfCr: 41961, capexCr: 3142, fcfCr: 38819, basis: "Consolidated" },
        { period: "FY24", revenueCr: 240893, netProfitCr: 45908, ocfCr: 44342, capexCr: 3310, fcfCr: 41032, basis: "Consolidated" },
        { period: "FY25", revenueCr: 255100, netProfitCr: 48450, ocfCr: 46800, capexCr: 3450, fcfCr: 43350, basis: "Consolidated" }
      ],

      checks: [
        {
          id: "net_profit",
          name: "Annual Net Profit",
          status: "pass",
          value: "₹48,450 Cr",
          rule: "Net profit > 0",
          evidence: "FY25 Consolidated Audited Statement. Profit after tax up 5.5% YoY.",
          period: "FY25 Annual"
        },
        {
          id: "operating_cashflow",
          name: "Operating Cash Flow",
          status: "pass",
          value: "₹46,800 Cr",
          rule: "Operating cash flow > 0",
          evidence: "Cash conversion ratio (OCF/PAT) stands at 96.6%, indicating high earnings quality.",
          period: "FY25 Annual"
        },
        {
          id: "roce",
          name: "Return on Capital Employed",
          status: "pass",
          value: "48.2%",
          rule: "ROCE ≥ 15.0%",
          evidence: "Capital employed ₹1,00,450 Cr. Driven by asset-light service delivery and zero long-term debt.",
          period: "FY25 Consolidated"
        },
        {
          id: "debt_equity",
          name: "Debt / Equity",
          status: "pass",
          value: "0.08x",
          rule: "Debt/Equity ≤ 1.00x",
          evidence: "Total debt ₹7,210 Cr (lease liabilities) against Net Worth ₹90,120 Cr. Net cash surplus company.",
          period: "FY25 Consolidated"
        },
        {
          id: "valuation_pe",
          name: "Valuation vs Benchmark",
          status: "pass",
          value: "28.4x P/E",
          rule: "P/E < Upstox Sector Benchmark (32.1x)",
          evidence: "Company P/E 28.4x trades at an 11.5% discount to the Upstox IT sector benchmark (32.1x). Provider definition: TTM consolidated EPS.",
          period: "TTM / As-of 24-Sep-2026"
        }
      ],

      sectorContext: {
        noteTitle: "Global Enterprise Discretionary IT Spend Softening",
        classification: "Potentially temporary",
        severity: "Caution",
        sourceUrl: "https://economictimes.indiatimes.com/tech/ites/gartner-it-spending-forecast",
        reviewedDate: "20-Sep-2026",
        headwind: "Client discretionary spend paused; deal ramp-ups slower than anticipated.",
        recoveryCondition: "Banking sector discretionary deal cycle pickup in North America."
      },

      companyRisks: [
        "Wage hikes in Q1/Q2 could weigh on operating margins if pricing power does not offset inflation.",
        "Foreign exchange fluctuations with USD/EUR volatility."
      ],

      nextChecks: [
        { task: "Verify Q2 FY27 Total Contract Value (TCV) new deal wins", targetDate: "15-Oct-2026", done: false },
        { task: "Check EBIT margin resilience against employee wage increments", targetDate: "15-Oct-2026", done: false },
        { task: "Confirm interim dividend payout announcement and free cash conversion", targetDate: "15-Oct-2026", done: false }
      ],

      watchlistData: {
        saved: true,
        thesis: "Tier-1 IT leader with fortress balance sheet, 48% ROCE, and >95% free cash flow conversion. Well positioned for multi-year enterprise AI transformation.",
        concerns: "Extended slowdown in North American BFSI deal velocity.",
        nextReviewDate: "2026-10-15"
      }
    },

    {
      isin: "INE009A01021",
      ticker: "INFY",
      name: "Infosys Limited",
      sectorId: "it",
      sectorName: "Information Technology",
      industry: "IT Consulting & Software",
      exchange: "NSE",
      exchangeKey: "NSE_EQ|INE009A01021",
      currentPrice: 1820.00,
      priceDate: "2026-09-24",
      dailyChangePercent: -2.30,
      monthlyChangePercent: -9.10,
      sectorDailyChange: -2.40,
      sectorMonthlyChange: -7.10,
      corporateActionStatus: "Verified clean",
      conclusion: "Watch and wait",
      conclusionBadgeClass: "badge-watch-wait",
      declineTriggerMet: { daily: true, monthly: true },
      
      triggerSummary: "Fell -2.30% daily and -9.10% over 1 month. Surpassed discovery decline triggers.",

      financials: [
        { period: "FY23", revenueCr: 146767, netProfitCr: 24095, ocfCr: 23150, capexCr: 2450, fcfCr: 20700, basis: "Consolidated" },
        { period: "FY24", revenueCr: 153670, netProfitCr: 26248, ocfCr: 24800, capexCr: 2580, fcfCr: 22220, basis: "Consolidated" },
        { period: "FY25", revenueCr: 162900, netProfitCr: 27800, ocfCr: 26100, capexCr: 2700, fcfCr: 23400, basis: "Consolidated" }
      ],

      checks: [
        { id: "net_profit", name: "Annual Net Profit", status: "pass", value: "₹27,800 Cr", rule: "Net profit > 0", evidence: "FY25 Consolidated Net Profit up 5.9%", period: "FY25 Annual" },
        { id: "operating_cashflow", name: "Operating Cash Flow", status: "pass", value: "₹26,100 Cr", rule: "Operating cash flow > 0", evidence: "High cash generation, 93.8% FCF conversion", period: "FY25 Annual" },
        { id: "roce", name: "Return on Capital Employed", status: "pass", value: "38.6%", rule: "ROCE ≥ 15.0%", evidence: "Net Worth ₹84,200 Cr, capital efficient", period: "FY25 Consolidated" },
        { id: "debt_equity", name: "Debt / Equity", status: "pass", value: "0.10x", rule: "Debt/Equity ≤ 1.00x", evidence: "Debt limited to operating lease commitments", period: "FY25 Consolidated" },
        { id: "valuation_pe", name: "Valuation vs Benchmark", status: "pass", value: "23.8x P/E", rule: "P/E < Upstox Sector Benchmark (32.1x)", evidence: "Trades at 25.8% discount to Upstox sector benchmark (32.1x)", period: "TTM / As-of 24-Sep-2026" }
      ],

      sectorContext: {
        noteTitle: "Global Enterprise Discretionary IT Spend Softening",
        classification: "Potentially temporary",
        severity: "Caution",
        sourceUrl: "https://economictimes.indiatimes.com/tech/ites/gartner-it-spending-forecast",
        reviewedDate: "20-Sep-2026",
        headwind: "Recent senior leadership churn and revised guidance create intermediate uncertainty.",
        recoveryCondition: "Stabilization of consulting division and large mega-deal execution."
      },

      companyRisks: [
        "Executive turnover in key North American vertical practices.",
        "Uncertainty around full-year constant currency revenue growth band."
      ],

      nextChecks: [
        { task: "Check Q2 revenue guidance band revision", targetDate: "18-Oct-2026", done: false },
        { task: "Monitor senior management retention and attrition trends", targetDate: "18-Oct-2026", done: false }
      ],

      watchlistData: {
        saved: false,
        thesis: "",
        concerns: "",
        nextReviewDate: ""
      }
    },

    {
      isin: "INE021A01026",
      ticker: "ASIANPAINT",
      name: "Asian Paints Limited",
      sectorId: "fmcg",
      sectorName: "Fast Moving Consumer Goods & Paints",
      industry: "Decorative Paints & Coatings",
      exchange: "NSE",
      exchangeKey: "NSE_EQ|INE021A01026",
      currentPrice: 2740.00,
      priceDate: "2026-09-24",
      dailyChangePercent: -3.80,
      monthlyChangePercent: -12.40,
      sectorDailyChange: -1.10,
      sectorMonthlyChange: -2.80,
      corporateActionStatus: "Verified clean",
      conclusion: "Fundamental concerns",
      conclusionBadgeClass: "badge-fundamental-concerns",
      declineTriggerMet: { daily: true, monthly: true },
      
      triggerSummary: "Fell sharply -3.80% today and -12.40% over 1 month, underperforming sector benchmark by -9.60%.",

      financials: [
        { period: "FY23", revenueCr: 34488, netProfitCr: 4106, ocfCr: 4190, capexCr: 1250, fcfCr: 2940, basis: "Consolidated" },
        { period: "FY24", revenueCr: 35494, netProfitCr: 5460, ocfCr: 4820, capexCr: 1840, fcfCr: 2980, basis: "Consolidated" },
        { period: "FY25", revenueCr: 35850, netProfitCr: 4850, ocfCr: 4200, capexCr: 2100, fcfCr: 2100, basis: "Consolidated" }
      ],

      checks: [
        { id: "net_profit", name: "Annual Net Profit", status: "pass", value: "₹4,850 Cr", rule: "Net profit > 0", evidence: "Positive net profit but down -11.2% YoY due to margin squeeze", period: "FY25 Annual" },
        { id: "operating_cashflow", name: "Operating Cash Flow", status: "pass", value: "₹4,200 Cr", rule: "Operating cash flow > 0", evidence: "OCF positive; working capital tied in distributor credit", period: "FY25 Annual" },
        { id: "roce", name: "Return on Capital Employed", status: "pass", value: "27.4%", rule: "ROCE ≥ 15.0%", evidence: "ROCE remains healthy above 15% threshold", period: "FY25 Consolidated" },
        { id: "debt_equity", name: "Debt / Equity", status: "pass", value: "0.18x", rule: "Debt/Equity ≤ 1.00x", evidence: "Low debt; robust balance sheet", period: "FY25 Consolidated" },
        { id: "valuation_pe", name: "Valuation vs Benchmark", status: "fail", value: "46.5x P/E", rule: "P/E < Upstox Sector Benchmark (41.2x)", evidence: "FAILS valuation check: Trades at 46.5x P/E, which is higher than Upstox benchmark 41.2x. Does not qualify as undervalued.", period: "TTM / As-of 24-Sep-2026" }
      ],

      sectorContext: {
        noteTitle: "Intensified Domestic Competition & Raw Material Volatility",
        classification: "Mixed (Temporary input costs, Structural new entrants)",
        severity: "Material concern",
        sourceUrl: "https://livemint.com/industry/retail/nielsen-fmcg-rural-demand-tracker",
        reviewedDate: "18-Sep-2026",
        headwind: "Birla Opus capacity rollout causing dealer rebate wars; crude oil derivative prices elevated.",
        recoveryCondition: "Stabilization of market share without protracted margin sacrifice."
      },

      companyRisks: [
        "Structural competitive disruption in dealer distribution network.",
        "Premium P/E multiple vulnerable to multiple re-rating if volume growth stalls."
      ],

      nextChecks: [
        { task: "Track volume vs value growth divergence in Q2 decorative segment", targetDate: "24-Oct-2026", done: false },
        { task: "Monitor dealer inventory levels and trade discount percentages", targetDate: "24-Oct-2026", done: false }
      ],

      watchlistData: {
        saved: false,
        thesis: "",
        concerns: "",
        nextReviewDate: ""
      }
    },

    {
      isin: "INE361B01024",
      ticker: "DIVISLAB",
      name: "Divi's Laboratories Limited",
      sectorId: "pharma",
      sectorName: "Pharmaceuticals & Healthcare",
      industry: "Active Pharmaceutical Ingredients (API)",
      exchange: "NSE",
      exchangeKey: "NSE_EQ|INE361B01024",
      currentPrice: 4890.00,
      priceDate: "2026-09-24",
      dailyChangePercent: -2.60,
      monthlyChangePercent: -8.15,
      sectorDailyChange: -0.75,
      sectorMonthlyChange: -1.65,
      corporateActionStatus: "Verified clean",
      conclusion: "Worth researching",
      conclusionBadgeClass: "badge-worth-researching",
      declineTriggerMet: { daily: true, monthly: true },
      
      triggerSummary: "Fell -2.60% daily and -8.15% monthly, qualifying under both price decline discovery triggers.",

      financials: [
        { period: "FY23", revenueCr: 7767, netProfitCr: 1823, ocfCr: 1680, capexCr: 890, fcfCr: 790, basis: "Consolidated" },
        { period: "FY24", revenueCr: 7849, netProfitCr: 1600, ocfCr: 1540, capexCr: 940, fcfCr: 600, basis: "Consolidated" },
        { period: "FY25", revenueCr: 8920, netProfitCr: 1980, ocfCr: 1850, capexCr: 980, fcfCr: 870, basis: "Consolidated" }
      ],

      checks: [
        { id: "net_profit", name: "Annual Net Profit", status: "pass", value: "₹1,980 Cr", rule: "Net profit > 0", evidence: "Net profit up 23.7% YoY as custom synthesis capacity utilization normalized", period: "FY25 Annual" },
        { id: "operating_cashflow", name: "Operating Cash Flow", status: "pass", value: "₹1,850 Cr", rule: "Operating cash flow > 0", evidence: "OCF conversion > 90%; strong working capital management", period: "FY25 Annual" },
        { id: "roce", name: "Return on Capital Employed", status: "pass", value: "18.2%", rule: "ROCE ≥ 15.0%", evidence: "ROCE 18.2% comfortably exceeds minimum 15.0% threshold", period: "FY25 Consolidated" },
        { id: "debt_equity", name: "Debt / Equity", status: "pass", value: "0.01x", rule: "Debt/Equity ≤ 1.00x", evidence: "Virtually zero debt (₹65 Cr) vs ₹13,400 Cr equity. High safety buffer.", period: "FY25 Consolidated" },
        { id: "valuation_pe", name: "Valuation vs Benchmark", status: "pass", value: "51.2x P/E", rule: "P/E < Upstox Sector Benchmark (56.8x)", evidence: "Company P/E 51.2x is below Upstox pharma sector benchmark of 56.8x. Provider definition verified.", period: "TTM / As-of 24-Sep-2026" }
      ],

      sectorContext: {
        noteTitle: "API Destocking Cycle Normalization",
        classification: "Potentially temporary",
        severity: "Informational",
        sourceUrl: "https://business-standard.com/industry/pharma-api-export-trends",
        reviewedDate: "22-Sep-2026",
        headwind: "API market price swings; long lead cycles for commercializing new chemical entities.",
        recoveryCondition: "Commercial scale-up of multi-year custom synthesis contracts."
      },

      companyRisks: [
        "High customer concentration in top 5 global innovator pharmaceutical clients.",
        "Raw material dependency on imported solvent intermediates."
      ],

      nextChecks: [
        { task: "Verify US FDA inspection audit status for Unit-2 Vizag facility", targetDate: "28-Oct-2026", done: true },
        { task: "Confirm commencement of commercial supply for GLP-1 peptide intermediates", targetDate: "28-Oct-2026", done: false }
      ],

      watchlistData: {
        saved: true,
        thesis: "Global API giant with pure-play compliance record, zero debt, and expanding into complex peptide chemistry.",
        concerns: "Customer concentration risk with European innovators.",
        nextReviewDate: "2026-10-28"
      }
    },

    {
      isin: "INE280A01028",
      ticker: "TITAN",
      name: "Titan Company Limited",
      sectorId: "consumer_discretionary",
      sectorName: "Consumer Discretionary",
      industry: "Jewellery, Watches & Eyewear",
      exchange: "NSE",
      exchangeKey: "NSE_EQ|INE280A01028",
      currentPrice: 3150.00,
      priceDate: "2026-09-24",
      dailyChangePercent: -14.20,
      monthlyChangePercent: -18.50,
      sectorDailyChange: -0.90,
      sectorMonthlyChange: -2.10,
      corporateActionStatus: "Unverified Corporate Action Distortion (1:1 Bonus Split pending adjustment)",
      conclusion: "Insufficient evidence",
      conclusionBadgeClass: "badge-insufficient-evidence",
      declineTriggerMet: { daily: false, monthly: false },
      
      triggerSummary: "Apparent -14.20% daily price collapse is an artifact of an unadjusted 1:1 corporate action. Disqualified under rule 6.5.",

      financials: [
        { period: "FY23", revenueCr: 38569, netProfitCr: 3274, ocfCr: 2140, capexCr: 650, fcfCr: 1490, basis: "Consolidated" },
        { period: "FY24", revenueCr: 47501, netProfitCr: 3496, ocfCr: 2480, capexCr: 810, fcfCr: 1670, basis: "Consolidated" },
        { period: "FY25", revenueCr: 51200, netProfitCr: 3750, ocfCr: 2800, capexCr: 950, fcfCr: 1850, basis: "Consolidated" }
      ],

      checks: [
        { id: "net_profit", name: "Annual Net Profit", status: "pass", value: "₹3,750 Cr", rule: "Net profit > 0", evidence: "Consolidated profit positive", period: "FY25 Annual" },
        { id: "operating_cashflow", name: "Operating Cash Flow", status: "pass", value: "₹2,800 Cr", rule: "Operating cash flow > 0", evidence: "OCF positive", period: "FY25 Annual" },
        { id: "roce", name: "Return on Capital Employed", status: "pass", value: "24.1%", rule: "ROCE ≥ 15.0%", evidence: "ROCE meets criteria", period: "FY25 Consolidated" },
        { id: "debt_equity", name: "Debt / Equity", status: "pass", value: "0.62x", rule: "Debt/Equity ≤ 1.00x", evidence: "Gold on lease debt within thresholds", period: "FY25 Consolidated" },
        { id: "valuation_pe", name: "Valuation vs Benchmark", status: "unavailable", value: "Unavailable", rule: "P/E < Sector Benchmark", evidence: "Provider ratio unavailable pending bonus share restatement. Cannot verify earnings basis.", period: "Unavailable" }
      ],

      sectorContext: {
        noteTitle: "Gold Import Duty Cut & Consumer Demand Realignment",
        classification: "Potentially temporary",
        severity: "Informational",
        sourceUrl: "https://thehindubusinessline.com/markets/gold-customs-duty-impact-titan",
        reviewedDate: "15-Sep-2026",
        headwind: "Short-term customs inventory loss from duty reduction; long-term volume tailwind.",
        recoveryCondition: "Festive Q3 jewellery retail sales pickup."
      },

      companyRisks: [
        "Gold price volatility and customs inventory adjustment.",
        "Unverified corporate action price adjustment distorting technical returns."
      ],

      nextChecks: [
        { task: "Wait for provider corporate action price adjustment factor confirmation", targetDate: "27-Sep-2026", done: false },
        { task: "Re-calculate authentic dividend/bonus-adjusted price return", targetDate: "27-Sep-2026", done: false }
      ],

      watchlistData: {
        saved: false,
        thesis: "",
        concerns: "",
        nextReviewDate: ""
      }
    }
  ]
};
