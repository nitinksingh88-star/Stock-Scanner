// Stock Advisory - Swiss Editorial Interactive Controller
// Adheres strictly to APP_REQUIREMENTS.md and BACKEND_REQUIREMENTS.md

(function() {
  const data = window.STOCK_ADVISORY_DATA;
  if (!data) {
    console.error("Stock advisory mock data not found!");
    return;
  }

  // App State
  let currentScreen = "brief";
  let activeWindow = "day"; // "day" or "month"
  let selectedCompanyIsin = "INE467B01029"; // TCS default
  let comparisonIsins = ["INE467B01029", "INE009A01021", "INE021A01026"]; // TCS, INFY, ASIANPAINT
  let simulatedSystemState = "normal";

  // Initialize
  window.addEventListener("DOMContentLoaded", () => {
    renderMastheadMeta();
    renderOpportunityBrief();
    renderCompanyPills();
    renderCompanyDeepView(selectedCompanyIsin);
    renderWatchlistScreen();
    renderScreenerTable();
    renderComparisonMatrix();
    renderSectorNotes();
  });

  // Navigation Controller
  window.navigateToScreen = function(screenId) {
    currentScreen = screenId;
    document.querySelectorAll(".editorial-nav .nav-tab").forEach(tab => {
      tab.classList.toggle("active", tab.dataset.screen === screenId);
    });
    document.querySelectorAll(".screen-section").forEach(sec => {
      sec.classList.toggle("active", sec.id === `screen-${screenId}`);
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Window Toggle (Daily vs 1-Month)
  window.switchDeclineWindow = function(win) {
    activeWindow = win;
    document.getElementById("btnWindowDay").classList.toggle("active", win === "day");
    document.getElementById("btnWindowMonth").classList.toggle("active", win === "month");
    
    // Update benchmark movements
    const bm = data.benchmarks;
    const isDay = win === "day";
    
    document.getElementById("bmNiftyChange").textContent = (isDay ? bm.broadMarket.dailyChangePercent : bm.broadMarket.monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmItChange").textContent = (isDay ? bm.sectors[0].dailyChangePercent : bm.sectors[0].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmFmcgChange").textContent = (isDay ? bm.sectors[1].dailyChangePercent : bm.sectors[1].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmPharmaChange").textContent = (isDay ? bm.sectors[2].dailyChangePercent : bm.sectors[2].monthlyChangePercent).toFixed(2) + "%";

    renderOpportunityBrief();
    showToast(`Switched discovery trigger to ${isDay ? "Daily (≤ -2%)" : "1-Month (≤ -8%)"}`);
  };

  // Masthead Meta
  function renderMastheadMeta() {
    const meta = data.meta;
    document.getElementById("mastheadTradingDate").textContent = `TRADING SESSION: ${meta.tradingDateFormatted.toUpperCase()} (T)`;
  }

  // APP-01: Render Opportunity Brief
  function renderOpportunityBrief() {
    const worthListEl = document.getElementById("worthResearchingList");
    const watchListEl = document.getElementById("watchWaitList");
    
    worthListEl.innerHTML = "";
    watchListEl.innerHTML = "";

    const worthCandidates = data.companies.filter(c => c.conclusion === "Worth researching");
    const watchCandidates = data.companies.filter(c => c.conclusion === "Watch and wait");

    document.getElementById("worthResearchingCount").textContent = worthCandidates.length;
    document.getElementById("watchWaitCount").textContent = watchCandidates.length;

    worthCandidates.forEach(comp => {
      worthListEl.appendChild(createCandidateCard(comp));
    });

    watchCandidates.forEach(comp => {
      watchListEl.appendChild(createCandidateCard(comp));
    });
  }

  // Create Swiss Candidate Card
  function createCandidateCard(comp) {
    const card = document.createElement("div");
    card.className = "candidate-card-editorial";

    const changeVal = activeWindow === "day" ? comp.dailyChangePercent : comp.monthlyChangePercent;
    const sectorChangeVal = activeWindow === "day" ? comp.sectorDailyChange : comp.sectorMonthlyChange;
    const peCheck = comp.checks.find(c => c.id === "valuation_pe");
    const roceCheck = comp.checks.find(c => c.id === "roce");
    const deCheck = comp.checks.find(c => c.id === "debt_equity");

    card.innerHTML = `
      <div class="candidate-card-top">
        <div>
          <div class="comp-identity">
            <span class="comp-name">${comp.name}</span>
            <span class="comp-ticker">${comp.ticker}</span>
            <span class="comp-sector">${comp.sectorName}</span>
          </div>
          <div class="mt-1">
            <span class="badge ${comp.conclusionBadgeClass}">
              <span class="badge-dot"></span> ${comp.conclusion.toUpperCase()}
            </span>
            <span class="text-xs text-stone-500 ml-2">ISIN: ${comp.isin}</span>
          </div>
        </div>
        <div class="comp-pricing">
          <div class="comp-price-val num-tabular">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
          <div class="comp-decline-val num-tabular">${changeVal > 0 ? '+' : ''}${changeVal.toFixed(2)}% (${activeWindow === 'day' ? 'Day' : '1-Mo'})</div>
          <div class="text-xs text-stone-400">Sector: ${sectorChangeVal.toFixed(2)}%</div>
        </div>
      </div>

      <div class="candidate-card-grid">
        <!-- Col 1: Discovery & Quality -->
        <div>
          <span class="kicker">QUALITY &amp; VALUATION RULES</span>
          <div class="metric-pill-row">
            <div class="metric-box-micro">
              <span class="mb-label">P/E vs SECTOR</span>
              <span class="mb-val ${peCheck.status === 'pass' ? 'mb-pass' : 'mb-fail'}">${peCheck.value}</span>
            </div>
            <div class="metric-box-micro">
              <span class="mb-label">ROCE</span>
              <span class="mb-val mb-pass">${roceCheck.value}</span>
            </div>
            <div class="metric-box-micro">
              <span class="mb-label">DEBT / EQ</span>
              <span class="mb-val mb-pass">${deCheck.value}</span>
            </div>
          </div>
          <p class="narrative-block mt-3">
            <strong>Why it appeared:</strong> ${comp.triggerSummary}
          </p>
        </div>

        <!-- Col 2: Reviewed Sector Context & Risks -->
        <div>
          <span class="kicker">REVIEWED SECTOR CONTEXT</span>
          <div class="narrative-block">
            <strong>${comp.sectorContext.noteTitle}</strong>
            <div class="editorial-quote-box">
              "${comp.sectorContext.headwind}"
            </div>
            <div class="mt-2 text-xs text-stone-500">
              Severity: <strong>${comp.sectorContext.severity}</strong> &bull; Impact: ${comp.sectorContext.classification}
            </div>
          </div>
        </div>

        <!-- Col 3: Practical Next Checks -->
        <div>
          <span class="kicker">ACTIONABLE NEXT CHECKS</span>
          <div class="next-checks-box">
            ${comp.nextChecks.slice(0, 2).map(nc => `
              <div class="checklist-item">
                <span>&bull;</span>
                <span>${nc.task} <strong class="text-xs text-stone-500">(${nc.targetDate})</strong></span>
              </div>
            `).join('')}
          </div>
        </div>
      </div>

      <div class="candidate-card-actions">
        <div class="flex gap-4">
          <button class="btn-editorial-text" onclick="window.inspectCompany('${comp.isin}')">Read Full Company Dossier (APP-02) &rarr;</button>
          <button class="btn-editorial-text" onclick="window.openEvidenceDrawer('${comp.isin}')">View Evidence &amp; Formula Trace</button>
        </div>
        <div>
          <button class="btn-editorial-outline" onclick="window.toggleWatchlistCandidate('${comp.isin}')">
            ${comp.watchlistData && comp.watchlistData.saved ? '✓ Saved in Watchlist' : '+ Add to Watchlist'}
          </button>
        </div>
      </div>
    `;

    return card;
  }

  // APP-02: Company Pills
  function renderCompanyPills() {
    const container = document.getElementById("companyAnalysisPills");
    container.innerHTML = "";
    data.companies.forEach(comp => {
      const btn = document.createElement("button");
      btn.className = `comp-pill-btn ${comp.isin === selectedCompanyIsin ? 'active' : ''}`;
      btn.textContent = `${comp.ticker} (${comp.conclusion})`;
      btn.onclick = () => {
        selectedCompanyIsin = comp.isin;
        renderCompanyPills();
        renderCompanyDeepView(comp.isin);
      };
      container.appendChild(btn);
    });
  }

  // Deep View Renderer
  function renderCompanyDeepView(isin) {
    const comp = data.companies.find(c => c.isin === isin) || data.companies[0];
    const container = document.getElementById("companyDeepViewContainer");

    container.innerHTML = `
      <div class="paper-block">
        <!-- Deep Header -->
        <div class="deep-header-banner">
          <div>
            <div class="flex items-center gap-3">
              <h2 class="deep-title">${comp.name}</h2>
              <span class="badge ${comp.conclusionBadgeClass}">
                <span class="badge-dot"></span> ${comp.conclusion}
              </span>
            </div>
            <div class="deep-subline">
              Ticker: <strong class="font-mono">${comp.ticker}</strong> &bull; 
              Exchange: ${comp.exchange} &bull; 
              ISIN: <span class="deep-isin-tag">${comp.isin}</span> &bull; 
              Sector: <strong>${comp.sectorName}</strong>
            </div>
          </div>
          <div class="text-right">
            <div class="font-mono text-3xl font-bold">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs text-stone-500 mt-1">Price As-of: ${comp.priceDate} (Latest Completed Session T)</div>
            <div class="text-xs ${comp.corporateActionStatus.includes('distortion') ? 'text-red-600 font-bold' : 'text-emerald-700'}">
              ${comp.corporateActionStatus}
            </div>
          </div>
        </div>

        <!-- 1. Why Did This Company Appear (APP-02 Criteria 1) -->
        <div class="callout-why-appeared">
          <span class="callout-title">1. DISCOVERY TRIGGER AUDIT</span>
          <p>${comp.triggerSummary}</p>
          <div class="text-xs text-stone-500 mt-1">
            Company Day Return: <strong>${comp.dailyChangePercent.toFixed(2)}%</strong> vs Sector: <strong>${comp.sectorDailyChange.toFixed(2)}%</strong> over identical date boundaries.
          </div>
        </div>

        <!-- 2. 3-Year Audited Financial Statements (APP-02 Criteria 3) -->
        <div class="mt-6">
          <span class="kicker">3-YEAR ANNUAL HISTORICAL FINANCIALS (₹ IN CRORE)</span>
          <h3 class="editorial-h3 mb-2">Statement Evidence: Revenue, Profit &amp; Cash Flow</h3>
          <div class="table-responsive-wrapper">
            <table class="editorial-table">
              <thead>
                <tr>
                  <th>Financial Period</th>
                  <th>Statement Basis</th>
                  <th class="text-right">Revenue (₹ Cr)</th>
                  <th class="text-right">Net Profit (PAT)</th>
                  <th class="text-right">Operating Cash Flow</th>
                  <th class="text-right">Capital Expenditure</th>
                  <th class="text-right">Derived Free Cash Flow</th>
                </tr>
              </thead>
              <tbody>
                ${comp.financials.map(fin => `
                  <tr>
                    <td><strong>${fin.period} Annual</strong></td>
                    <td><span class="badge badge-insufficient-evidence">${fin.basis}</span></td>
                    <td class="text-right num-tabular font-mono">₹${fin.revenueCr.toLocaleString('en-IN')}</td>
                    <td class="text-right num-tabular font-mono">₹${fin.netProfitCr.toLocaleString('en-IN')}</td>
                    <td class="text-right num-tabular font-mono">₹${fin.ocfCr.toLocaleString('en-IN')}</td>
                    <td class="text-right num-tabular font-mono">₹${fin.capexCr.toLocaleString('en-IN')}</td>
                    <td class="text-right num-tabular font-mono font-bold text-emerald-800">₹${fin.fcfCr.toLocaleString('en-IN')}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
          <div class="text-xs text-stone-400 mt-2">
            * Note: Free Cash Flow strictly derived as (Operating Cash Flow − Verified Capital Expenditure). Financial statement dates remain distinct from current price dates.
          </div>
        </div>

        <!-- 3. Quality & Valuation Rules Engine (APP-02 Criteria 4) -->
        <div class="mt-8">
          <span class="kicker">DETERMINISTIC EVALUATION RULES</span>
          <h3 class="editorial-h3 mb-2">Quality &amp; Valuation Rules Engine Check</h3>
          <div class="table-responsive-wrapper">
            <table class="editorial-table">
              <thead>
                <tr>
                  <th>Rule Name</th>
                  <th>Configured Threshold</th>
                  <th>Actual Evaluated Value</th>
                  <th>Pass / Fail Status</th>
                  <th>Statement Period</th>
                  <th>Audit Evidence &amp; Basis</th>
                </tr>
              </thead>
              <tbody>
                ${comp.checks.map(chk => `
                  <tr>
                    <td><strong>${chk.name}</strong></td>
                    <td class="font-mono text-xs">${chk.rule}</td>
                    <td class="font-mono font-bold">${chk.value}</td>
                    <td>
                      <span class="badge ${chk.status === 'pass' ? 'badge-worth-researching' : (chk.status === 'fail' ? 'badge-fundamental-concerns' : 'badge-insufficient-evidence')}">
                        <span class="badge-dot"></span> ${chk.status.toUpperCase()}
                      </span>
                    </td>
                    <td class="text-xs text-stone-500">${chk.period}</td>
                    <td class="text-xs">${chk.evidence}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- 4. Sector Context & Headwinds (APP-02 Criteria 5) -->
        <div class="candidate-card-grid mt-8 border-t pt-6">
          <div>
            <span class="kicker">SECTOR HEADWIND &amp; RECOVERY</span>
            <h4 class="font-serif text-lg font-bold">${comp.sectorContext.noteTitle}</h4>
            <p class="narrative-block mt-2">${comp.sectorContext.headwind}</p>
            <div class="mt-3 text-xs text-stone-600">
              <div><strong>Recovery Condition:</strong> ${comp.sectorContext.recoveryCondition}</div>
              <div class="mt-1">
                Source: <a href="${comp.sectorContext.sourceUrl}" target="_blank" class="text-blue-700 underline">Economic Times Report</a> &bull; Reviewed: ${comp.sectorContext.reviewedDate}
              </div>
            </div>
          </div>

          <div>
            <span class="kicker">COMPANY-SPECIFIC CONCERNS</span>
            <h4 class="font-serif text-lg font-bold">Material Risk Factors</h4>
            <ul class="list-disc pl-4 text-xs space-y-2 mt-2 text-stone-700">
              ${comp.companyRisks.map(r => `<li>${r}</li>`).join('')}
            </ul>
          </div>

          <div>
            <span class="kicker">PRACTICAL NEXT-REVIEW CHECKLIST</span>
            <h4 class="font-serif text-lg font-bold">Investigation Roadmap</h4>
            <div class="next-checks-box mt-2">
              ${comp.nextChecks.map(nc => `
                <div class="checklist-item">
                  <input type="checkbox" ${nc.done ? 'checked' : ''} onchange="window.toggleChecklist('${comp.isin}', '${nc.task}')">
                  <span class="${nc.done ? 'line-through text-stone-400' : ''}">${nc.task}</span>
                </div>
              `).join('')}
            </div>
            <button class="btn-editorial-primary w-full mt-4" onclick="window.openThesisModal('${comp.isin}')">
              ${comp.watchlistData && comp.watchlistData.saved ? 'Edit Investment Thesis &amp; Notes' : 'Save to Watchlist with Thesis'}
            </button>
          </div>
        </div>

      </div>
    `;
  }

  // Quick Switch to deep analysis
  window.inspectCompany = function(isin) {
    selectedCompanyIsin = isin;
    renderCompanyPills();
    renderCompanyDeepView(isin);
    window.navigateToScreen('analysis');
  };

  // Evidence Drawer Controller
  window.openEvidenceDrawer = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    document.getElementById("drawerTitle").textContent = `${comp.name} (${comp.ticker}) — Rule Audit Evidence`;
    const body = document.getElementById("drawerBody");

    body.innerHTML = `
      <div class="mb-4 text-xs text-stone-500">
        Snapshot ID: <strong>SNP-20260924-001</strong> &bull; Rule Version: <strong>${data.meta.ruleVersion}</strong> &bull; Generated: ${data.meta.dataTimestampFormatted}
      </div>

      <div class="mb-4 p-3 bg-stone-100 border text-xs">
        <strong>Decline Trigger Verification:</strong> ${comp.triggerSummary}
        <br>Corporate Action Status: <strong>${comp.corporateActionStatus}</strong>
      </div>

      <h4 class="kicker mb-2">INDIVIDUAL CHECK FORMULAS &amp; DATA TRACE:</h4>
      ${comp.checks.map(chk => `
        <div class="check-audit-card">
          <div class="cac-header">
            <strong>${chk.name}</strong>
            <span class="badge ${chk.status === 'pass' ? 'badge-worth-researching' : (chk.status === 'fail' ? 'badge-fundamental-concerns' : 'badge-insufficient-evidence')}">
              ${chk.status.toUpperCase()}
            </span>
          </div>
          <div class="cac-rule">Formula / Threshold: <code>${chk.rule}</code></div>
          <div class="cac-rule">Evaluated Figure: <strong>${chk.value}</strong> (${chk.period})</div>
          <div class="cac-evidence">${chk.evidence}</div>
        </div>
      `).join('')}

      <div class="mt-6 border-t pt-4">
        <h4 class="kicker">LIMITATIONS &amp; METHODOLOGY DISCLOSURE:</h4>
        <p class="text-xs text-stone-600 leading-relaxed">
          Valuation comparison relies on "Upstox sector benchmark" as reported by the provider. It is not an industry median. Current annual statements (FY25) confirm historical capital efficiency but do not predict future earnings. Price movements represent adjusted completed session closes.
        </p>
      </div>
    `;

    document.getElementById("evidenceDrawerBackdrop").classList.add("active");
  };

  window.closeEvidenceDrawer = function(e) {
    if (e && e.target !== e.currentTarget && !e.target.classList.contains("btn-close")) return;
    document.getElementById("evidenceDrawerBackdrop").classList.remove("active");
  };

  // APP-03: Watchlist Screen
  function renderWatchlistScreen() {
    const listEl = document.getElementById("watchlistItemsList");
    const saved = data.companies.filter(c => c.watchlistData && c.watchlistData.saved);
    
    document.getElementById("watchlistCount").textContent = saved.length;

    if (saved.length === 0) {
      listEl.innerHTML = `<div class="p-8 text-center text-stone-500">No companies saved to watchlist yet. Click "+ Add to Watchlist" on any candidate card.</div>`;
      return;
    }

    listEl.innerHTML = saved.map(comp => `
      <div class="candidate-card-editorial">
        <div class="candidate-card-top">
          <div>
            <div class="comp-identity">
              <span class="comp-name">${comp.name}</span>
              <span class="comp-ticker">${comp.ticker}</span>
              <span class="badge ${comp.conclusionBadgeClass}"><span class="badge-dot"></span> ${comp.conclusion}</span>
            </div>
            <div class="text-xs text-stone-500 mt-1">Data Date: ${comp.priceDate} &bull; Next Review Target: <strong class="text-stone-800">${comp.watchlistData.nextReviewDate || 'Unspecified'}</strong></div>
          </div>
          <div class="flex gap-2">
            <button class="btn-editorial-sm" onclick="window.inspectCompany('${comp.isin}')">Inspect &rarr;</button>
            <button class="btn-editorial-sm" onclick="window.toggleWatchlistCandidate('${comp.isin}')">Remove</button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4 text-xs">
          <div class="p-3 bg-stone-50 border">
            <span class="kicker">MY INVESTMENT THESIS</span>
            <p class="text-stone-800 mt-1 font-serif text-sm">${comp.watchlistData.thesis || 'No thesis entered yet.'}</p>
          </div>
          <div class="p-3 bg-stone-50 border">
            <span class="kicker">SPECIFIC RISKS TO MONITOR</span>
            <p class="text-stone-800 mt-1">${comp.watchlistData.concerns || 'No specific risks logged.'}</p>
          </div>
        </div>
      </div>
    `).join('');
  }

  window.toggleWatchlistCandidate = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    if (!comp.watchlistData) {
      comp.watchlistData = { saved: true, thesis: "Evaluating decline opportunity.", concerns: "Sector demand lag.", nextReviewDate: "2026-10-15" };
    } else {
      comp.watchlistData.saved = !comp.watchlistData.saved;
    }

    renderOpportunityBrief();
    renderWatchlistScreen();
    showToast(`${comp.ticker} ${comp.watchlistData.saved ? 'added to' : 'removed from'} watchlist (Persisted to local SQLite)`);
  };

  // APP-04: Screener Table & Comparison Matrix
  function renderScreenerTable() {
    const tbody = document.getElementById("screenerTableBody");
    const query = (document.getElementById("screenerSearchInput")?.value || "").toLowerCase();
    const sector = document.getElementById("screenerSectorSelect")?.value || "all";
    const conclusion = document.getElementById("screenerConclusionSelect")?.value || "all";
    const sortBy = document.getElementById("screenerSortSelect")?.value || "decline_day";

    let filtered = data.companies.filter(c => {
      const matchQuery = c.name.toLowerCase().includes(query) || c.ticker.toLowerCase().includes(query);
      const matchSector = sector === "all" || c.sectorId === sector;
      const matchConclusion = conclusion === "all" || c.conclusion === conclusion;
      return matchQuery && matchSector && matchConclusion;
    });

    // Explicit sorting with "Unavailable values sort last"
    filtered.sort((a, b) => {
      if (sortBy === "decline_day") return a.dailyChangePercent - b.dailyChangePercent;
      if (sortBy === "decline_month") return a.monthlyChangePercent - b.monthlyChangePercent;
      if (sortBy === "pe_ratio") {
        const peA = parseFloat(a.checks.find(x => x.id === "valuation_pe")?.value) || 99999;
        const peB = parseFloat(b.checks.find(x => x.id === "valuation_pe")?.value) || 99999;
        return peA - peB;
      }
      if (sortBy === "roce") {
        const rA = parseFloat(a.checks.find(x => x.id === "roce")?.value) || -99999;
        const rB = parseFloat(b.checks.find(x => x.id === "roce")?.value) || -99999;
        return rB - rA;
      }
      return 0;
    });

    tbody.innerHTML = filtered.map(c => {
      const pe = c.checks.find(x => x.id === "valuation_pe")?.value || 'Unavailable';
      const roce = c.checks.find(x => x.id === "roce")?.value || 'Unavailable';
      const de = c.checks.find(x => x.id === "debt_equity")?.value || 'Unavailable';
      const inComp = comparisonIsins.includes(c.isin);

      return `
        <tr>
          <td>
            <a href="javascript:void(0)" onclick="window.inspectCompany('${c.isin}')" class="font-bold font-mono text-stone-900">${c.ticker}</a>
            <div class="text-xs text-stone-500">${c.name}</div>
          </td>
          <td><span class="text-xs">${c.sectorName}</span></td>
          <td class="text-right font-mono font-bold">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</td>
          <td class="text-right font-mono text-red-600 font-bold">${c.dailyChangePercent.toFixed(2)}%</td>
          <td class="text-right font-mono text-red-700">${c.monthlyChangePercent.toFixed(2)}%</td>
          <td class="text-right font-mono ${pe === 'Unavailable' ? 'text-stone-400 italic' : ''}">${pe}</td>
          <td class="text-right font-mono">${roce}</td>
          <td class="text-right font-mono">${de}</td>
          <td><span class="badge ${c.conclusionBadgeClass} text-xs"><span class="badge-dot"></span> ${c.conclusion}</span></td>
          <td class="text-center">
            <input type="checkbox" ${inComp ? 'checked' : ''} onchange="window.toggleComparisonCandidate('${c.isin}')">
          </td>
        </tr>
      `;
    }).join('');
  }

  window.filterScreener = renderScreenerTable;

  window.toggleComparisonCandidate = function(isin) {
    if (comparisonIsins.includes(isin)) {
      comparisonIsins = comparisonIsins.filter(x => x !== isin);
    } else {
      if (comparisonIsins.length >= 3) {
        showToast("Maximum 3 companies allowed for side-by-side comparison.");
        renderScreenerTable();
        return;
      }
      comparisonIsins.push(isin);
    }
    renderScreenerTable();
    renderComparisonMatrix();
  };

  window.resetComparison = function() {
    comparisonIsins = [];
    renderScreenerTable();
    renderComparisonMatrix();
  };

  function renderComparisonMatrix() {
    const container = document.getElementById("comparisonMatrixContainer");
    const alertBanner = document.getElementById("comparisonAlertBanner");

    const comps = data.companies.filter(c => comparisonIsins.includes(c.isin));
    if (comps.length === 0) {
      container.innerHTML = `<div class="p-6 text-center text-stone-400 text-sm">Select up to 3 companies in the table above to generate side-by-side comparison matrix.</div>`;
      alertBanner.style.display = "none";
      return;
    }

    // Check for cross-sector warning
    const sectors = new Set(comps.map(c => c.sectorId));
    if (sectors.size > 1) {
      alertBanner.style.display = "block";
    } else {
      alertBanner.style.display = "none";
    }

    container.innerHTML = `
      <table class="editorial-table">
        <thead>
          <tr>
            <th style="width: 220px;">Evaluation Check / Metric</th>
            ${comps.map(c => `
              <th>
                <div class="font-bold text-sm">${c.ticker}</div>
                <div class="text-xs text-stone-500">${c.sectorName}</div>
              </th>
            `).join('')}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Research Conclusion</strong></td>
            ${comps.map(c => `<td><span class="badge ${c.conclusionBadgeClass}"><span class="badge-dot"></span> ${c.conclusion}</span></td>`).join('')}
          </tr>
          <tr>
            <td><strong>Latest Price (₹)</strong></td>
            ${comps.map(c => `<td class="font-mono font-bold">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Daily Return (%)</strong></td>
            ${comps.map(c => `<td class="font-mono text-red-600 font-bold">${c.dailyChangePercent.toFixed(2)}%</td>`).join('')}
          </tr>
          <tr>
            <td><strong>1-Month Return (%)</strong></td>
            ${comps.map(c => `<td class="font-mono text-red-700">${c.monthlyChangePercent.toFixed(2)}%</td>`).join('')}
          </tr>
          <tr>
            <td><strong>P/E Multiple</strong></td>
            ${comps.map(c => `<td class="font-mono">${c.checks.find(x => x.id === "valuation_pe")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>ROCE (Return on Capital)</strong></td>
            ${comps.map(c => `<td class="font-mono font-bold">${c.checks.find(x => x.id === "roce")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Debt / Equity</strong></td>
            ${comps.map(c => `<td class="font-mono">${c.checks.find(x => x.id === "debt_equity")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Latest Net Profit (FY25)</strong></td>
            ${comps.map(c => `<td class="font-mono">₹${c.financials[c.financials.length-1].netProfitCr.toLocaleString('en-IN')} Cr</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Operating Cash Flow (FY25)</strong></td>
            ${comps.map(c => `<td class="font-mono">₹${c.financials[c.financials.length-1].ocfCr.toLocaleString('en-IN')} Cr</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Corporate Action Status</strong></td>
            ${comps.map(c => `<td class="text-xs ${c.corporateActionStatus.includes('distortion') ? 'text-red-600 font-bold' : 'text-stone-600'}">${c.corporateActionStatus}</td>`).join('')}
          </tr>
        </tbody>
      </table>
    `;
  }

  // APP-05: Sector Research Notes
  function renderSectorNotes() {
    const container = document.getElementById("sectorNotesListContainer");
    container.innerHTML = data.sectorResearchNotes.map(n => `
      <div class="check-audit-card mb-3">
        <div class="flex justify-between items-start mb-2">
          <div>
            <span class="kicker">${n.sectorName}</span>
            <h4 class="font-serif font-bold text-base">${n.title}</h4>
          </div>
          <span class="badge ${n.severity === 'Material concern' ? 'badge-fundamental-concerns' : (n.severity === 'Caution' ? 'badge-watch-wait' : 'badge-worth-researching')}">
            ${n.severity.toUpperCase()}
          </span>
        </div>
        <p class="text-xs text-stone-700 leading-relaxed">${n.summary}</p>
        <div class="mt-2 text-xs text-stone-500 grid grid-cols-2 gap-2">
          <div><strong>Pressure:</strong> ${n.pressureClassification}</div>
          <div><strong>Reviewed:</strong> ${n.reviewDate} (Next: ${n.nextReviewDate})</div>
        </div>
        <div class="mt-2 text-xs">
          Source: <a href="${n.sourceUrl}" target="_blank" class="text-blue-700 underline">${n.sourceTitle}</a>
        </div>
      </div>
    `).join('');
  }

  // Save Settings & Recalculate
  window.saveRuleSettings = function() {
    data.meta.ruleVersion = "v1.3 (Recalculated 25-Sep-2026)";
    document.getElementById("activeRuleVersionTag").textContent = "v1.3";
    showToast("Rule thresholds saved! Assessment recalculated and rule version bumped to v1.3.");
  };

  // State Simulation Controller (APP Requirements 4 - Required States)
  window.switchEditorialState = function(state) {
    simulatedSystemState = state;
    const alertBox = document.getElementById("systemAlertBox");
    const worthListEl = document.getElementById("worthResearchingList");
    const watchListEl = document.getElementById("watchWaitList");

    alertBox.style.display = "none";
    alertBox.className = "system-alert-box";

    if (state === "normal") {
      renderOpportunityBrief();
      showToast("Restored Normal State: Live active brief with 5 verified candidates.");
      return;
    }

    if (state === "no-data") {
      alertBox.className = "system-alert-box alert-info";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 1: No Data Yet (Initial Setup):</strong> Welcome to Stock Advisory. The local database has been initialized. Connect your Upstox Analytics Token and run your first completed trading session refresh.
        <button class="btn-editorial-primary ml-3" onclick="window.switchEditorialState('refreshing')">Run First Refresh</button>
      `;
      worthListEl.innerHTML = `<div class="p-8 text-center text-stone-400">No snapshot calculated yet. Run initial refresh above.</div>`;
      watchListEl.innerHTML = ``;
    } 
    else if (state === "refreshing") {
      alertBox.className = "system-alert-box alert-info";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 2: Refresh Running in Background:</strong> Job ID: <code>JOB-20260925-081</code>. Ingesting Upstox price bars and fundamental filings... (3 of 5 companies processed). Previous snapshot remains visible and interactive.
      `;
      renderOpportunityBrief();
    }
    else if (state === "token-rejected") {
      alertBox.className = "system-alert-box alert-error";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 3: Token Rejected / Expired:</strong> Upstox Analytics Token returned HTTP 401 Unauthorized. Your local credential in <code>server.config</code> requires replacement. <strong>Cached data from 24-Sep-2026 is preserved and remains safely usable.</strong>
      `;
      renderOpportunityBrief();
    }
    else if (state === "partial-failure") {
      alertBox.className = "system-alert-box alert-warning";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 4: Partial Provider Failure:</strong> Upstox reported timeout on balance sheet data for TITAN (Consumer Discretionary). Remaining 4 companies updated cleanly. Coverage: 80% (4/5 companies current).
      `;
      renderOpportunityBrief();
    }
    else if (state === "research-expired") {
      alertBox.className = "system-alert-box alert-warning";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 5: Research Expired (&gt;30 Days):</strong> Sourced sector note for FMCG &amp; Paints is older than 30 days. Evidence completeness downgraded; affected candidates moved out of 'Worth researching' until refreshed.
      `;
      renderOpportunityBrief();
    }
    else if (state === "no-opportunities") {
      alertBox.className = "system-alert-box alert-info";
      alertBox.style.display = "block";
      alertBox.innerHTML = `
        <strong>State 6: No Qualifying Opportunities:</strong> No company in the covered universe passed all quality, valuation, and risk criteria for the selected discovery window.
      `;
      worthListEl.innerHTML = `
        <div class="paper-block text-center py-10">
          <h3 class="editorial-h3">No Qualifying Opportunities Found</h3>
          <p class="text-sm text-stone-500 max-w-lg mx-auto mt-2">
            A decline alone does not produce an opportunity. 3 companies failed valuation, 1 had unverified corporate action distortion, and 1 has material sector headwind.
          </p>
          <button class="btn-editorial-primary mt-4" onclick="window.navigateToScreen('explore')">Inspect Excluded Companies in Screener &rarr;</button>
        </div>
      `;
      watchListEl.innerHTML = ``;
    }
  };

  // Toast Notification Helper
  function showToast(msg) {
    const container = document.getElementById("toastContainer");
    const toast = document.createElement("div");
    toast.className = "toast";
    toast.innerHTML = `<span>✓</span> <span>${msg}</span>`;
    container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = "0";
      setTimeout(() => toast.remove(), 300);
    }, 3200);
  }

})();
