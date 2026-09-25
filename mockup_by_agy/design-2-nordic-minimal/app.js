// Stock Advisory - Nordic Minimalist SaaS Controller
(function() {
  const data = window.STOCK_ADVISORY_DATA;
  if (!data) return;

  let currentScreen = "brief";
  let activeWindow = "day";
  let selectedIsin = "INE467B01029"; // TCS
  let compIsins = ["INE467B01029", "INE009A01021", "INE021A01026"];

  window.addEventListener("DOMContentLoaded", () => {
    renderBrief();
    renderCompanyTabs();
    renderDeepCompany(selectedIsin);
    renderWatchlist();
    renderNordicScreener();
    renderNordicComparison();
    renderSectorNotes();
  });

  // Navigation
  window.navigateToScreen = function(screenId) {
    currentScreen = screenId;
    document.querySelectorAll(".nordic-tab").forEach(tab => {
      tab.classList.toggle("active", tab.dataset.screen === screenId);
    });
    document.querySelectorAll(".nordic-screen").forEach(sec => {
      sec.classList.toggle("active", sec.id === `screen-${screenId}`);
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Window Toggle
  window.switchDeclineWindow = function(win) {
    activeWindow = win;
    document.getElementById("btnDayWindow").classList.toggle("active", win === "day");
    document.getElementById("btnMonthWindow").classList.toggle("active", win === "month");
    
    const isDay = win === "day";
    const bm = data.benchmarks;
    document.getElementById("bmNifty").textContent = (isDay ? bm.broadMarket.dailyChangePercent : bm.broadMarket.monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmIt").textContent = (isDay ? bm.sectors[0].dailyChangePercent : bm.sectors[0].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmFmcg").textContent = (isDay ? bm.sectors[1].dailyChangePercent : bm.sectors[1].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmPharma").textContent = (isDay ? bm.sectors[2].dailyChangePercent : bm.sectors[2].monthlyChangePercent).toFixed(2) + "%";

    renderBrief();
    showToast(`Window switched to ${isDay ? "Daily (≤ -2%)" : "1-Month (≤ -8%)"}`);
  };

  // Render Brief
  function renderBrief() {
    const worthEl = document.getElementById("worthContainer");
    const watchEl = document.getElementById("watchContainer");
    worthEl.innerHTML = "";
    watchEl.innerHTML = "";

    const worth = data.companies.filter(c => c.conclusion === "Worth researching");
    const watch = data.companies.filter(c => c.conclusion === "Watch and wait");

    document.getElementById("worthCountBadge").textContent = `${worth.length} Qualified`;
    document.getElementById("watchCountBadge").textContent = `${watch.length} Monitoring`;

    worth.forEach(c => worthEl.appendChild(createNordicCard(c)));
    watch.forEach(c => watchEl.appendChild(createNordicCard(c)));
  }

  function createNordicCard(comp) {
    const card = document.createElement("div");
    card.className = "nordic-candidate-card";

    const change = activeWindow === "day" ? comp.dailyChangePercent : comp.monthlyChangePercent;
    const sectorChange = activeWindow === "day" ? comp.sectorDailyChange : comp.sectorMonthlyChange;
    const pe = comp.checks.find(x => x.id === "valuation_pe");
    const roce = comp.checks.find(x => x.id === "roce");
    const de = comp.checks.find(x => x.id === "debt_equity");

    card.innerHTML = `
      <div class="ncc-header">
        <div>
          <div class="flex-center gap-2">
            <span class="ncc-title">${comp.name}</span>
            <span class="ncc-ticker">${comp.ticker}</span>
            <span class="badge ${comp.conclusionBadgeClass}"><span class="badge-dot"></span> ${comp.conclusion}</span>
          </div>
          <div class="ncc-sector mt-1">${comp.sectorName} &bull; ISIN: ${comp.isin}</div>
        </div>
        <div class="text-right">
          <div class="ncc-price">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
          <div class="ncc-change">${change.toFixed(2)}% (${activeWindow === 'day' ? 'Day' : '1-Mo'})</div>
          <div class="text-xs text-slate-400">Sector: ${sectorChange.toFixed(2)}%</div>
        </div>
      </div>

      <div class="ncc-grid">
        <div>
          <div class="text-xs font-bold text-slate-400 tracking-wider">RULES ENGINE</div>
          <div class="flex gap-2 mt-2">
            <div class="metric-pill-nordic flex-1">
              <div class="mpn-label">P/E RATIO</div>
              <div class="mpn-val ${pe.status === 'pass' ? 'text-emerald-600' : 'text-rose-600'}">${pe.value}</div>
            </div>
            <div class="metric-pill-nordic flex-1">
              <div class="mpn-label">ROCE</div>
              <div class="mpn-val text-emerald-600">${roce.value}</div>
            </div>
            <div class="metric-pill-nordic flex-1">
              <div class="mpn-label">DEBT/EQ</div>
              <div class="mpn-val text-emerald-600">${de.value}</div>
            </div>
          </div>
          <p class="text-xs text-slate-600 mt-3 leading-relaxed">
            <strong>Trigger:</strong> ${comp.triggerSummary}
          </p>
        </div>

        <div>
          <div class="text-xs font-bold text-slate-400 tracking-wider">SECTOR CONTEXT</div>
          <div class="text-xs font-semibold text-slate-800 mt-2">${comp.sectorContext.noteTitle}</div>
          <div class="quote-chip">"${comp.sectorContext.headwind}"</div>
          <div class="text-xs text-slate-400 mt-2">
            Severity: <strong class="text-slate-700">${comp.sectorContext.severity}</strong> &bull; Recovery: ${comp.sectorContext.recoveryCondition}
          </div>
        </div>

        <div>
          <div class="text-xs font-bold text-slate-400 tracking-wider">ACTION CHECKLIST</div>
          <div class="checklist-clean mt-2">
            ${comp.nextChecks.slice(0, 2).map(nc => `
              <div class="flex items-start gap-1 mt-1 text-slate-700">
                <span>&bull;</span> <span>${nc.task} <strong class="text-slate-400 text-xs">(${nc.targetDate})</strong></span>
              </div>
            `).join('')}
          </div>
        </div>
      </div>

      <div class="ncc-actions">
        <div class="flex gap-4">
          <button class="btn-clean-text" onclick="window.inspectCompanyNordic('${comp.isin}')">Deep Analysis (APP-02) &rarr;</button>
          <button class="btn-clean-text" onclick="window.openNordicDrawer('${comp.isin}')">Audit Evidence</button>
        </div>
        <button class="btn-nordic-outline" onclick="window.toggleWatchlistNordic('${comp.isin}')">
          ${comp.watchlistData && comp.watchlistData.saved ? '✓ In Watchlist' : '+ Add to Watchlist'}
        </button>
      </div>
    `;

    return card;
  }

  // Company Deep Analysis
  function renderCompanyTabs() {
    const el = document.getElementById("companyTabs");
    el.innerHTML = "";
    data.companies.forEach(c => {
      const btn = document.createElement("button");
      btn.className = `ct-pill ${c.isin === selectedIsin ? 'active' : ''}`;
      btn.textContent = `${c.ticker} (${c.conclusion})`;
      btn.onclick = () => {
        selectedIsin = c.isin;
        renderCompanyTabs();
        renderDeepCompany(c.isin);
      };
      el.appendChild(btn);
    });
  }

  function renderDeepCompany(isin) {
    const comp = data.companies.find(c => c.isin === isin) || data.companies[0];
    const container = document.getElementById("companyDeepContainer");

    container.innerHTML = `
      <div class="nordic-card p-6">
        <div class="flex-between border-b pb-4">
          <div>
            <div class="flex-center gap-3">
              <h2 class="text-2xl font-bold text-slate-900">${comp.name}</h2>
              <span class="badge ${comp.conclusionBadgeClass}"><span class="badge-dot"></span> ${comp.conclusion}</span>
            </div>
            <div class="text-xs text-slate-500 mt-1">
              Ticker: <strong class="font-mono">${comp.ticker}</strong> &bull; ISIN: ${comp.isin} &bull; Sector: ${comp.sectorName}
            </div>
          </div>
          <div class="text-right">
            <div class="text-2xl font-bold font-mono">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs text-slate-400">Date: ${comp.priceDate} (Session T)</div>
            <div class="text-xs font-semibold ${comp.corporateActionStatus.includes('distortion') ? 'text-rose-600' : 'text-emerald-600'}">
              ${comp.corporateActionStatus}
            </div>
          </div>
        </div>

        <div class="nordic-alert alert-blue mt-4">
          <div class="text-xs font-bold tracking-wider text-blue-900 uppercase">1. Trigger &amp; Price Alignment Check</div>
          <p class="text-xs text-blue-900 mt-1">${comp.triggerSummary}</p>
        </div>

        <!-- 3-Year Audited Financials -->
        <div class="mt-6">
          <h3 class="text-base font-bold text-slate-900 mb-2">3-Year Audited Financial Statements (₹ in Crore)</h3>
          <div class="table-container-nordic">
            <table class="nordic-table">
              <thead>
                <tr>
                  <th>Period</th>
                  <th>Basis</th>
                  <th class="text-right">Revenue</th>
                  <th class="text-right">Net Profit</th>
                  <th class="text-right">Operating Cash Flow</th>
                  <th class="text-right">Capex</th>
                  <th class="text-right">Free Cash Flow</th>
                </tr>
              </thead>
              <tbody>
                ${comp.financials.map(f => `
                  <tr>
                    <td><strong>${f.period}</strong></td>
                    <td><span class="badge-clean-neutral">${f.basis}</span></td>
                    <td class="text-right font-mono">₹${f.revenueCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.netProfitCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.ocfCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.capexCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono font-bold text-emerald-600">₹${f.fcfCr.toLocaleString('en-IN')}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Rules Engine Table -->
        <div class="mt-6">
          <h3 class="text-base font-bold text-slate-900 mb-2">Quality &amp; Valuation Rules Check</h3>
          <div class="table-container-nordic">
            <table class="nordic-table">
              <thead>
                <tr>
                  <th>Rule Name</th>
                  <th>Threshold</th>
                  <th>Evaluated Value</th>
                  <th>Status</th>
                  <th>Evidence Basis</th>
                </tr>
              </thead>
              <tbody>
                ${comp.checks.map(k => `
                  <tr>
                    <td><strong>${k.name}</strong></td>
                    <td class="font-mono text-xs">${k.rule}</td>
                    <td class="font-mono font-bold">${k.value}</td>
                    <td>
                      <span class="badge ${k.status === 'pass' ? 'badge-worth-researching' : (k.status === 'fail' ? 'badge-fundamental-concerns' : 'badge-insufficient-evidence')}">
                        ${k.status.toUpperCase()}
                      </span>
                    </td>
                    <td class="text-xs text-slate-600">${k.evidence}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Risks & Checklist Grid -->
        <div class="nordic-grid-2 mt-6 border-t pt-4">
          <div>
            <h4 class="text-sm font-bold text-slate-900 mb-2">Sector Pressures &amp; Company Headwinds</h4>
            <div class="quote-chip">${comp.sectorContext.headwind}</div>
            <ul class="text-xs list-disc pl-4 mt-2 space-y-1 text-slate-600">
              ${comp.companyRisks.map(r => `<li>${r}</li>`).join('')}
            </ul>
          </div>
          <div>
            <h4 class="text-sm font-bold text-slate-900 mb-2">Actionable Next Check Review Tasks</h4>
            <div class="checklist-clean">
              ${comp.nextChecks.map(nc => `
                <div class="flex items-center gap-2 mt-1">
                  <input type="checkbox" ${nc.done ? 'checked' : ''}>
                  <span class="text-xs ${nc.done ? 'line-through text-slate-400' : 'text-slate-800'}">${nc.task} (${nc.targetDate})</span>
                </div>
              `).join('')}
            </div>
            <button class="btn-nordic-primary w-full mt-4" onclick="window.toggleWatchlistNordic('${comp.isin}')">
              ${comp.watchlistData && comp.watchlistData.saved ? '✓ Saved in Watchlist' : 'Add to Watchlist'}
            </button>
          </div>
        </div>

      </div>
    `;
  }

  window.inspectCompanyNordic = function(isin) {
    selectedIsin = isin;
    renderCompanyTabs();
    renderDeepCompany(isin);
    window.navigateToScreen('analysis');
  };

  // Drawer
  window.openNordicDrawer = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    document.getElementById("nordicDrawerTitle").textContent = `${comp.name} Evidence Trace`;
    document.getElementById("nordicDrawerBody").innerHTML = `
      <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs mb-4">
        Snapshot: <strong>SNP-20260924-001</strong> &bull; Rule Version: <strong>${data.meta.ruleVersion}</strong>
      </div>
      <div class="space-y-3">
        ${comp.checks.map(c => `
          <div class="p-3 bg-white border border-slate-200 rounded-lg">
            <div class="flex-between">
              <strong class="text-xs text-slate-900">${c.name}</strong>
              <span class="badge ${c.status === 'pass' ? 'badge-worth-researching' : (c.status === 'fail' ? 'badge-fundamental-concerns' : 'badge-insufficient-evidence')}">${c.status}</span>
            </div>
            <div class="text-xs font-mono text-slate-500 mt-1">${c.rule} &bull; ${c.value}</div>
            <p class="text-xs text-slate-600 mt-1">${c.evidence}</p>
          </div>
        `).join('')}
      </div>
    `;

    document.getElementById("nordicDrawerBackdrop").classList.add("active");
  };

  window.closeNordicDrawer = function(e) {
    if (e && e.target !== e.currentTarget && !e.target.classList.contains("btn-close-clean")) return;
    document.getElementById("nordicDrawerBackdrop").classList.remove("active");
  };

  // Watchlist
  function renderWatchlist() {
    const el = document.getElementById("watchlistStack");
    const saved = data.companies.filter(c => c.watchlistData && c.watchlistData.saved);
    document.getElementById("watchlistCount").textContent = saved.length;

    if (saved.length === 0) {
      el.innerHTML = `<div class="p-8 text-center text-slate-400 text-sm">No companies saved.</div>`;
      return;
    }

    el.innerHTML = saved.map(c => `
      <div class="nordic-card p-4">
        <div class="flex-between">
          <div class="flex-center gap-2">
            <strong class="text-base text-slate-900">${c.name} (${c.ticker})</strong>
            <span class="badge ${c.conclusionBadgeClass}"><span class="badge-dot"></span> ${c.conclusion}</span>
          </div>
          <button class="btn-clean-text" onclick="window.toggleWatchlistNordic('${c.isin}')">Remove</button>
        </div>
        <div class="mt-3 grid grid-cols-2 gap-3 text-xs">
          <div class="p-3 bg-slate-50 rounded-lg">
            <div class="font-bold text-slate-400">MY THESIS</div>
            <div class="text-slate-800 mt-1">${c.watchlistData.thesis || 'No thesis entered.'}</div>
          </div>
          <div class="p-3 bg-slate-50 rounded-lg">
            <div class="font-bold text-slate-400">KEY CONCERNS</div>
            <div class="text-slate-800 mt-1">${c.watchlistData.concerns || 'None specified.'}</div>
          </div>
        </div>
      </div>
    `).join('');
  }

  window.toggleWatchlistNordic = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    if (!comp.watchlistData) {
      comp.watchlistData = { saved: true, thesis: "Decline valuation check.", concerns: "Sector drag.", nextReviewDate: "2026-10-15" };
    } else {
      comp.watchlistData.saved = !comp.watchlistData.saved;
    }

    renderBrief();
    renderWatchlist();
    showToast(`${comp.ticker} ${comp.watchlistData.saved ? 'added to' : 'removed from'} watchlist.`);
  };

  // Screener
  function renderNordicScreener() {
    const tbody = document.getElementById("nordicTableBody");
    const query = (document.getElementById("nordicSearch")?.value || "").toLowerCase();
    const sector = document.getElementById("nordicSector")?.value || "all";
    const conclusion = document.getElementById("nordicConclusion")?.value || "all";

    let filtered = data.companies.filter(c => {
      const matchQ = c.name.toLowerCase().includes(query) || c.ticker.toLowerCase().includes(query);
      const matchS = sector === "all" || c.sectorId === sector;
      const matchC = conclusion === "all" || c.conclusion === conclusion;
      return matchQ && matchS && matchC;
    });

    tbody.innerHTML = filtered.map(c => `
      <tr>
        <td>
          <a href="javascript:void(0)" onclick="window.inspectCompanyNordic('${c.isin}')" class="font-bold font-mono text-slate-900">${c.ticker}</a>
          <div class="text-xs text-slate-400">${c.name}</div>
        </td>
        <td><span class="text-xs text-slate-600">${c.sectorName}</span></td>
        <td class="text-right font-mono font-bold">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</td>
        <td class="text-right font-mono text-rose-600 font-bold">${c.dailyChangePercent.toFixed(2)}%</td>
        <td class="text-right font-mono text-rose-700">${c.monthlyChangePercent.toFixed(2)}%</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "valuation_pe")?.value || 'Unavailable'}</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "roce")?.value || 'Unavailable'}</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "debt_equity")?.value || 'Unavailable'}</td>
        <td><span class="badge ${c.conclusionBadgeClass} text-xs"><span class="badge-dot"></span> ${c.conclusion}</span></td>
        <td class="text-center">
          <input type="checkbox" ${compIsins.includes(c.isin) ? 'checked' : ''} onchange="window.toggleCompNordic('${c.isin}')">
        </td>
      </tr>
    `).join('');
  }

  window.filterNordicScreener = renderNordicScreener;

  window.toggleCompNordic = function(isin) {
    if (compIsins.includes(isin)) {
      compIsins = compIsins.filter(x => x !== isin);
    } else {
      if (compIsins.length >= 3) {
        showToast("Maximum 3 companies allowed for comparison.");
        renderNordicScreener();
        return;
      }
      compIsins.push(isin);
    }
    renderNordicScreener();
    renderNordicComparison();
  };

  window.clearNordicComparison = function() {
    compIsins = [];
    renderNordicScreener();
    renderNordicComparison();
  };

  function renderNordicComparison() {
    const container = document.getElementById("nordicCompMatrix");
    const banner = document.getElementById("crossSectorBanner");
    const comps = data.companies.filter(c => compIsins.includes(c.isin));

    if (comps.length === 0) {
      container.innerHTML = `<div class="p-6 text-center text-slate-400 text-sm">Select companies in table above to compare.</div>`;
      banner.style.display = "none";
      return;
    }

    const sectors = new Set(comps.map(c => c.sectorId));
    banner.style.display = sectors.size > 1 ? "block" : "none";

    container.innerHTML = `
      <table class="nordic-table">
        <thead>
          <tr>
            <th>Metrics</th>
            ${comps.map(c => `<th>${c.ticker} (${c.sectorName})</th>`).join('')}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Conclusion</strong></td>
            ${comps.map(c => `<td><span class="badge ${c.conclusionBadgeClass}">${c.conclusion}</span></td>`).join('')}
          </tr>
          <tr>
            <td><strong>P/E Multiple</strong></td>
            ${comps.map(c => `<td class="font-mono">${c.checks.find(x => x.id === "valuation_pe")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>ROCE</strong></td>
            ${comps.map(c => `<td class="font-mono font-bold">${c.checks.find(x => x.id === "roce")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Debt / Equity</strong></td>
            ${comps.map(c => `<td class="font-mono">${c.checks.find(x => x.id === "debt_equity")?.value || 'Unavailable'}</td>`).join('')}
          </tr>
          <tr>
            <td><strong>Free Cash Flow (FY25)</strong></td>
            ${comps.map(c => `<td class="font-mono font-bold text-emerald-600">₹${c.financials[c.financials.length-1].fcfCr.toLocaleString('en-IN')} Cr</td>`).join('')}
          </tr>
        </tbody>
      </table>
    `;
  }

  // Sector Notes
  function renderSectorNotes() {
    const el = document.getElementById("nordicSectorNotes");
    el.innerHTML = data.sectorResearchNotes.map(n => `
      <div class="p-3 bg-slate-50 border border-slate-200 rounded-lg">
        <div class="flex-between">
          <strong class="text-xs text-slate-900">${n.sectorName}</strong>
          <span class="badge-clean-neutral">${n.severity}</span>
        </div>
        <div class="text-xs font-semibold text-slate-800 mt-1">${n.title}</div>
        <p class="text-xs text-slate-600 mt-1">${n.summary}</p>
        <div class="text-xs text-slate-400 mt-2">Source: <a href="${n.sourceUrl}" target="_blank" class="text-indigo-600 underline">${n.sourceTitle}</a></div>
      </div>
    `).join('');
  }

  window.saveNordicRules = function() {
    data.meta.ruleVersion = "v1.3 (Updated)";
    document.getElementById("nordicRuleVer").textContent = "v1.3";
    showToast("Rule updated & recalculated to v1.3.");
  };

  // State Simulation
  window.switchNordicState = function(state) {
    const alertBox = document.getElementById("nordicAlertBox");
    const worthEl = document.getElementById("worthContainer");
    const watchEl = document.getElementById("watchContainer");

    alertBox.style.display = "none";

    if (state === "normal") {
      renderBrief();
      showToast("Restored normal state.");
      return;
    }

    if (state === "no-data") {
      alertBox.className = "nordic-alert alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 1: Initial Setup</strong> — No market data loaded yet. Run your first refresh.`;
      worthEl.innerHTML = `<div class="p-8 text-center text-slate-400">Database initialized. Ready for first refresh.</div>`;
      watchEl.innerHTML = ``;
    }
    else if (state === "refreshing") {
      alertBox.className = "nordic-alert alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 2: Refreshing Snapshot...</strong> — Fetching latest candles. Previous data preserved.`;
      renderBrief();
    }
    else if (state === "token-rejected") {
      alertBox.className = "nordic-alert alert-red";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 3: Token Expired</strong> — Upstox token rejected. Update <code>server.config</code>. Cached data preserved.`;
      renderBrief();
    }
    else if (state === "partial-failure") {
      alertBox.className = "nordic-alert alert-amber";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 4: Partial Failure</strong> — 1 company balance sheet missing. Coverage: 80%.`;
      renderBrief();
    }
    else if (state === "research-expired") {
      alertBox.className = "nordic-alert alert-amber";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 5: Research Expired</strong> — FMCG note >30 days. Completeness downgraded.`;
      renderBrief();
    }
    else if (state === "no-opportunities") {
      alertBox.className = "nordic-alert alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `<strong>State 6: No Qualifying Opportunities</strong> — No covered stock passed all rules.`;
      worthEl.innerHTML = `<div class="p-8 text-center text-slate-400">Zero qualifying candidates found for selected window.</div>`;
      watchEl.innerHTML = ``;
    }
  };

  function showToast(msg) {
    const hub = document.getElementById("nordicToastHub");
    const t = document.createElement("div");
    t.className = "nordic-toast";
    t.textContent = msg;
    hub.appendChild(t);
    setTimeout(() => t.remove(), 3000);
  }
})();
