// Mobile App Native Interactive Controller
(function() {
  const data = window.STOCK_ADVISORY_DATA;
  if (!data) return;

  let currentTab = "brief";
  let activeWindow = "day";
  let selectedIsin = "INE467B01029"; // TCS
  let compIsins = ["INE467B01029", "INE009A01021", "INE021A01026"];
  let currentTheme = "theme-minimal";

  window.addEventListener("DOMContentLoaded", () => {
    updateClock();
    setInterval(updateClock, 30000);
    renderMobileBrief();
    renderTickerScroll();
    renderDeepCompany(selectedIsin);
    renderMobileWatchlist();
    renderMobileScreener();
    renderMobileComparison();
    renderMobileSectorNotes();
  });

  function updateClock() {
    const now = new Date();
    const hrs = now.getHours();
    const mins = String(now.getMinutes()).padStart(2, '0');
    const clockEl = document.getElementById("statusClock");
    if (clockEl) clockEl.textContent = `${hrs}:${mins}`;
  }

  // Mobile Bottom Tab Navigation
  window.switchMobileTab = function(tabId) {
    currentTab = tabId;
    document.querySelectorAll(".m-tab-item").forEach(item => {
      item.classList.toggle("active", item.dataset.tab === tabId);
    });
    document.querySelectorAll(".mobile-screen").forEach(sec => {
      sec.classList.toggle("active", sec.id === `tab-${tabId}`);
    });

    const titles = {
      'brief': 'Opportunity Brief',
      'analysis': 'Company Analysis',
      'watchlist': 'Watchlist & Notes',
      'explore': 'Universe Explore',
      'settings': 'Settings & Notes'
    };
    document.getElementById("mobileHeaderTitle").textContent = titles[tabId] || 'Stock Advisory';

    // Scroll canvas to top
    document.getElementById("mobileCanvas").scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Window toggle
  window.switchMobileWindow = function(win) {
    activeWindow = win;
    document.getElementById("btnMDay").classList.toggle("active", win === "day");
    document.getElementById("btnMMonth").classList.toggle("active", win === "month");

    const isDay = win === "day";
    const bm = data.benchmarks;
    document.getElementById("mBmNifty").textContent = (isDay ? bm.broadMarket.dailyChangePercent : bm.broadMarket.monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("mBmIt").textContent = (isDay ? bm.sectors[0].dailyChangePercent : bm.sectors[0].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("mBmFmcg").textContent = (isDay ? bm.sectors[1].dailyChangePercent : bm.sectors[1].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("mBmPharma").textContent = (isDay ? bm.sectors[2].dailyChangePercent : bm.sectors[2].monthlyChangePercent).toFixed(2) + "%";

    renderMobileBrief();
    showMobileToast(`Window: ${isDay ? "Daily (≤ -2%)" : "1-Month (≤ -8%)"}`);
  };

  // Render Brief Tab
  function renderMobileBrief() {
    const worthEl = document.getElementById("mWorthList");
    const watchEl = document.getElementById("mWatchList");
    worthEl.innerHTML = "";
    watchEl.innerHTML = "";

    const worth = data.companies.filter(c => c.conclusion === "Worth researching");
    const watch = data.companies.filter(c => c.conclusion === "Watch and wait");

    document.getElementById("mWorthBadge").textContent = `${worth.length} Qualified`;
    document.getElementById("mWatchBadge").textContent = `${watch.length} Monitoring`;

    worth.forEach(c => worthEl.appendChild(createMobileCard(c)));
    watch.forEach(c => watchEl.appendChild(createMobileCard(c)));
  }

  function createMobileCard(comp) {
    const card = document.createElement("div");
    card.className = "m-candidate-card";

    const change = activeWindow === "day" ? comp.dailyChangePercent : comp.monthlyChangePercent;
    const pe = comp.checks.find(x => x.id === "valuation_pe");
    const roce = comp.checks.find(x => x.id === "roce");
    const de = comp.checks.find(x => x.id === "debt_equity");

    card.innerHTML = `
      <div class="m-cc-top" onclick="window.inspectMobileCompany('${comp.isin}')">
        <div>
          <div class="m-cc-name">${comp.name}</div>
          <div class="m-cc-meta">
            <span class="m-ticker-tag">${comp.ticker}</span>
            <span>${comp.sectorName}</span>
          </div>
        </div>
        <div class="m-price-box">
          <div class="m-price-val">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
          <div class="m-decline-tag">${change.toFixed(2)}%</div>
        </div>
      </div>

      <div class="m-metrics-row">
        <div class="m-metric-cell">
          <div class="mmc-label">P/E vs SEC</div>
          <div class="mmc-val ${pe.status === 'pass' ? 'mmc-pass' : 'mmc-fail'}">${pe.value}</div>
        </div>
        <div class="m-metric-cell">
          <div class="mmc-label">ROCE</div>
          <div class="mmc-val mmc-pass">${roce.value}</div>
        </div>
        <div class="m-metric-cell">
          <div class="mmc-label">DEBT / EQ</div>
          <div class="mmc-val mmc-pass">${de.value}</div>
        </div>
      </div>

      <div class="m-narrative-box">
        <strong>Trigger:</strong> ${comp.triggerSummary}
      </div>

      <div class="m-checks-snippet">
        <div class="m-check-bullet">&bull;</div>
        <span class="truncate">${comp.nextChecks[0].task}</span>
      </div>

      <div class="m-cc-actions">
        <button class="m-btn-text" onclick="window.inspectMobileCompany('${comp.isin}')">View Analysis &rarr;</button>
        <div class="flex gap-2">
          <button class="m-btn-pill" onclick="window.openMobileSheet('${comp.isin}')">Evidence</button>
          <button class="m-btn-pill" onclick="window.toggleMobileWatchlist('${comp.isin}')">
            ${comp.watchlistData && comp.watchlistData.saved ? '✓ Saved' : '+ Watch'}
          </button>
        </div>
      </div>
    `;

    return card;
  }

  // Ticker Selector for Analysis Tab
  function renderTickerScroll() {
    const el = document.getElementById("mTickerScroll");
    el.innerHTML = "";
    data.companies.forEach(c => {
      const btn = document.createElement("button");
      btn.className = `m-ticker-pill ${c.isin === selectedIsin ? 'active' : ''}`;
      btn.textContent = `${c.ticker} (${c.conclusion.split(' ')[0]})`;
      btn.onclick = () => {
        selectedIsin = c.isin;
        renderTickerScroll();
        renderDeepCompany(c.isin);
      };
      el.appendChild(btn);
    });
  }

  function renderDeepCompany(isin) {
    const comp = data.companies.find(c => c.isin === isin) || data.companies[0];
    const container = document.getElementById("mDeepContainer");

    container.innerHTML = `
      <div class="m-card">
        <div class="flex-between border-b pb-3">
          <div>
            <div class="text-base font-bold text-slate-900">${comp.name}</div>
            <div class="text-xs text-slate-500">${comp.sectorName} &bull; ${comp.ticker} &bull; ${comp.isin}</div>
          </div>
          <div class="text-right">
            <div class="text-lg font-bold font-mono">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs ${comp.corporateActionStatus.includes('distortion') ? 'text-red-600 font-bold' : 'text-emerald-700'}">
              ${comp.corporateActionStatus}
            </div>
          </div>
        </div>

        <div class="m-alert m-alert-blue mt-3">
          <strong>Discovery Trigger:</strong> ${comp.triggerSummary}
        </div>

        <!-- 3-Year Audited Financials -->
        <div class="mt-4">
          <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">3-Year Audited Statements (₹ Cr)</span>
          <div class="m-table-wrap">
            <table class="m-table">
              <thead>
                <tr>
                  <th>Period</th>
                  <th class="text-right">Revenue</th>
                  <th class="text-right">PAT</th>
                  <th class="text-right">OCF</th>
                  <th class="text-right">FCF</th>
                </tr>
              </thead>
              <tbody>
                ${comp.financials.map(f => `
                  <tr>
                    <td><strong>${f.period}</strong></td>
                    <td class="text-right font-mono">₹${f.revenueCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.netProfitCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.ocfCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono font-bold text-emerald-700">₹${f.fcfCr.toLocaleString('en-IN')}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Rules Engine Checklist -->
        <div class="mt-4">
          <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Quality &amp; Valuation Rules</span>
          <div class="space-y-2 mt-2">
            ${comp.checks.map(k => `
              <div class="p-2 border rounded text-xs flex-between bg-slate-50">
                <div>
                  <strong>${k.name}</strong>
                  <div class="text-slate-500 text-xs font-mono">${k.value} (${k.rule})</div>
                </div>
                <span class="badge ${k.status === 'pass' ? 'badge-worth-researching' : 'badge-fundamental-concerns'} text-xs">
                  ${k.status.toUpperCase()}
                </span>
              </div>
            `).join('')}
          </div>
        </div>

        <!-- Sourced Headwinds & Actionable Checks -->
        <div class="mt-4 border-t pt-3">
          <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Sector Pressure &amp; Risks</span>
          <p class="text-xs text-slate-700 mt-1 italic">"${comp.sectorContext.headwind}"</p>
          <div class="mt-3">
            <span class="text-xs font-bold text-slate-900 block mb-1">Investigation Checklist:</span>
            ${comp.nextChecks.map(nc => `
              <div class="flex items-center gap-2 text-xs py-1">
                <input type="checkbox" ${nc.done ? 'checked' : ''}>
                <span class="${nc.done ? 'line-through text-slate-400' : 'text-slate-800'}">${nc.task} (${nc.targetDate})</span>
              </div>
            `).join('')}
          </div>
          <button class="bento-btn-primary w-full mt-4 text-xs" onclick="window.toggleMobileWatchlist('${comp.isin}')">
            ${comp.watchlistData && comp.watchlistData.saved ? '✓ Saved in Watchlist' : '+ Add to Watchlist'}
          </button>
        </div>

      </div>
    `;
  }

  window.inspectMobileCompany = function(isin) {
    selectedIsin = isin;
    renderTickerScroll();
    renderDeepCompany(isin);
    window.switchMobileTab('analysis');
  };

  // Bottom Sheet for Evidence
  window.openMobileSheet = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    document.getElementById("mSheetTitle").textContent = `${comp.name} Evidence Audit`;
    document.getElementById("mSheetBody").innerHTML = `
      <div class="p-2 bg-slate-100 rounded text-xs mb-3 font-mono">
        Snapshot: SNP-20260924-001 | Version: ${data.meta.ruleVersion}
      </div>
      <div class="space-y-3">
        ${comp.checks.map(c => `
          <div class="p-3 border rounded-lg bg-white">
            <div class="flex-between">
              <strong>${c.name}</strong>
              <span class="badge ${c.status === 'pass' ? 'badge-worth-researching' : 'badge-fundamental-concerns'}">${c.status}</span>
            </div>
            <div class="text-xs font-mono text-slate-500 mt-1">${c.rule} &bull; ${c.value}</div>
            <p class="text-xs text-slate-600 mt-1">${c.evidence}</p>
          </div>
        `).join('')}
      </div>
    `;

    document.getElementById("mSheetBackdrop").classList.add("active");
  };

  window.closeMobileSheet = function(e) {
    if (e && e.target !== e.currentTarget && !e.target.classList.contains("sheet-close-btn") && !e.target.classList.contains("sheet-handle-bar") && !e.target.classList.contains("sheet-handle")) return;
    document.getElementById("mSheetBackdrop").classList.remove("active");
  };

  // Watchlist Tab
  function renderMobileWatchlist() {
    const el = document.getElementById("mWatchlistList");
    const saved = data.companies.filter(c => c.watchlistData && c.watchlistData.saved);
    document.getElementById("mWatchBadgeCount").textContent = saved.length;

    if (saved.length === 0) {
      el.innerHTML = `<div class="p-8 text-center text-slate-400 text-xs">Watchlist is empty. Tap "+ Watch" on any card.</div>`;
      return;
    }

    el.innerHTML = saved.map(c => `
      <div class="m-card">
        <div class="flex-between">
          <div>
            <div class="text-sm font-bold text-slate-900">${c.name} (${c.ticker})</div>
            <div class="text-xs text-slate-400">${c.isin} &bull; ${c.conclusion}</div>
          </div>
          <button class="m-btn-pill text-xs" onclick="window.toggleMobileWatchlist('${c.isin}')">Remove</button>
        </div>
        <div class="mt-2 text-xs">
          <div class="p-2 bg-slate-50 rounded mt-1"><strong>Thesis:</strong> ${c.watchlistData.thesis || 'None'}</div>
          <div class="p-2 bg-slate-50 rounded mt-1"><strong>Concerns:</strong> ${c.watchlistData.concerns || 'None'}</div>
        </div>
      </div>
    `).join('');
  }

  window.toggleMobileWatchlist = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    if (!comp.watchlistData) {
      comp.watchlistData = { saved: true, thesis: "Decline research thesis.", concerns: "Sector delay.", nextReviewDate: "2026-10-15" };
    } else {
      comp.watchlistData.saved = !comp.watchlistData.saved;
    }

    renderMobileBrief();
    renderMobileWatchlist();
    showMobileToast(`${comp.ticker} ${comp.watchlistData.saved ? 'added to' : 'removed from'} watchlist`);
  };

  // Screener
  function renderMobileScreener() {
    const el = document.getElementById("mScreenerStack");
    const q = (document.getElementById("mSearchInput")?.value || "").toLowerCase();
    const sector = document.getElementById("mSectorSelect")?.value || "all";
    const conclusion = document.getElementById("mConclusionSelect")?.value || "all";

    let filtered = data.companies.filter(c => {
      const mQ = c.name.toLowerCase().includes(q) || c.ticker.toLowerCase().includes(q);
      const mS = sector === "all" || c.sectorId === sector;
      const mC = conclusion === "all" || c.conclusion === conclusion;
      return mQ && mS && mC;
    });

    el.innerHTML = filtered.map(c => `
      <div class="m-card">
        <div class="flex-between">
          <div>
            <div class="font-bold text-sm text-slate-900" onclick="window.inspectMobileCompany('${c.isin}')">${c.ticker} — ${c.name}</div>
            <div class="text-xs text-slate-500">${c.sectorName}</div>
          </div>
          <div class="text-right">
            <div class="font-mono font-bold text-sm">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs text-rose-600 font-bold font-mono">${c.dailyChangePercent.toFixed(2)}%</div>
          </div>
        </div>
        <div class="flex-between mt-2 pt-2 border-t text-xs">
          <span>P/E: <strong>${c.checks.find(x => x.id === "valuation_pe")?.value || 'N/A'}</strong></span>
          <span>ROCE: <strong>${c.checks.find(x => x.id === "roce")?.value || 'N/A'}</strong></span>
          <label class="flex items-center gap-1 cursor-pointer">
            <input type="checkbox" ${compIsins.includes(c.isin) ? 'checked' : ''} onchange="window.toggleMobileCompare('${c.isin}')">
            <span>Compare</span>
          </label>
        </div>
      </div>
    `).join('');
  }

  window.filterMobileScreener = renderMobileScreener;

  window.toggleMobileCompare = function(isin) {
    if (compIsins.includes(isin)) {
      compIsins = compIsins.filter(x => x !== isin);
    } else {
      if (compIsins.length >= 3) {
        showMobileToast("Maximum 3 companies for comparison");
        renderMobileScreener();
        return;
      }
      compIsins.push(isin);
    }
    renderMobileScreener();
    renderMobileComparison();
  };

  window.clearMobileCompare = function() {
    compIsins = [];
    renderMobileScreener();
    renderMobileComparison();
  };

  function renderMobileComparison() {
    const container = document.getElementById("mCompMatrixBox");
    const warn = document.getElementById("mCrossWarning");
    const comps = data.companies.filter(c => compIsins.includes(c.isin));

    if (comps.length === 0) {
      container.innerHTML = `<div class="p-4 text-center text-slate-400 text-xs">Select 2-3 companies to compare.</div>`;
      warn.style.display = "none";
      return;
    }

    const sectors = new Set(comps.map(c => c.sectorId));
    warn.style.display = sectors.size > 1 ? "block" : "none";

    container.innerHTML = `
      <div class="m-table-wrap">
        <table class="m-table">
          <thead>
            <tr>
              <th>Metric</th>
              ${comps.map(c => `<th>${c.ticker}</th>`).join('')}
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Verdict</td>
              ${comps.map(c => `<td><span class="badge ${c.conclusionBadgeClass} text-xs">${c.conclusion.split(' ')[0]}</span></td>`).join('')}
            </tr>
            <tr>
              <td>P/E</td>
              ${comps.map(c => `<td class="font-mono">${c.checks.find(x => x.id === "valuation_pe")?.value || 'N/A'}</td>`).join('')}
            </tr>
            <tr>
              <td>ROCE</td>
              ${comps.map(c => `<td class="font-mono font-bold">${c.checks.find(x => x.id === "roce")?.value || 'N/A'}</td>`).join('')}
            </tr>
            <tr>
              <td>Free Cash Flow</td>
              ${comps.map(c => `<td class="font-mono font-bold text-emerald-700">₹${c.financials[c.financials.length-1].fcfCr.toLocaleString('en-IN')} Cr</td>`).join('')}
            </tr>
          </tbody>
        </table>
      </div>
    `;
  }

  function renderMobileSectorNotes() {
    const el = document.getElementById("mSectorNotesList");
    el.innerHTML = data.sectorResearchNotes.map(n => `
      <div class="p-2 border rounded bg-slate-50 text-xs">
        <div class="flex-between">
          <strong>${n.sectorName}</strong>
          <span class="badge badge-insufficient-evidence">${n.severity}</span>
        </div>
        <div class="text-xs font-bold text-slate-800 mt-1">${n.title}</div>
        <p class="text-xs text-slate-600 mt-1">${n.summary}</p>
        <div class="text-xs text-blue-600 underline mt-1"><a href="${n.sourceUrl}" target="_blank">Source Link</a></div>
      </div>
    `).join('');
  }

  window.saveMobileRules = function() {
    data.meta.ruleVersion = "v1.3 (Mobile)";
    document.getElementById("mRuleTag").textContent = "v1.3";
    showMobileToast("Rules saved & recalculated to v1.3");
  };

  // Theme Switcher for Mobile
  const themes = ["theme-minimal", "theme-editorial", "theme-dark", "theme-bento"];
  window.cycleMobileTheme = function() {
    const idx = themes.indexOf(currentTheme);
    const nextTheme = themes[(idx + 1) % themes.length];
    window.setMobileTheme(nextTheme);
  };

  window.setMobileTheme = function(themeClass) {
    currentTheme = themeClass;
    document.body.className = `mobile-viewport-body ${themeClass}`;
    
    document.getElementById("thBtnMinimal").classList.toggle("active", themeClass === "theme-minimal");
    document.getElementById("thBtnEditorial").classList.toggle("active", themeClass === "theme-editorial");
    document.getElementById("thBtnDark").classList.toggle("active", themeClass === "theme-dark");
    document.getElementById("thBtnBento").classList.toggle("active", themeClass === "theme-bento");

    showMobileToast(`Theme: ${themeClass.replace('theme-', '').toUpperCase()}`);
  };

  // State Simulation
  window.switchMobileState = function(state) {
    const alertBox = document.getElementById("mobileAlertBox");
    const worthEl = document.getElementById("mWorthList");
    const watchEl = document.getElementById("mWatchList");

    alertBox.style.display = "none";

    if (state === "normal") {
      renderMobileBrief();
      showMobileToast("Restored Normal State");
      return;
    }

    if (state === "no-data") {
      alertBox.className = "m-alert m-alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 1: No data yet. Run initial refresh.`;
      worthEl.innerHTML = `<div class="p-6 text-center text-slate-400 text-xs">Ready for first refresh.</div>`;
      watchEl.innerHTML = ``;
    }
    else if (state === "refreshing") {
      alertBox.className = "m-alert m-alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 2: Refreshing in background... (Cache visible)`;
      renderMobileBrief();
    }
    else if (state === "token-rejected") {
      alertBox.className = "m-alert m-alert-red";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 3: Token Auth Failure. Cached data preserved.`;
      renderMobileBrief();
    }
    else if (state === "partial-failure") {
      alertBox.className = "m-alert m-alert-amber";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 4: Partial Failure. 1 stock missing. Coverage: 80%.`;
      renderMobileBrief();
    }
    else if (state === "research-expired") {
      alertBox.className = "m-alert m-alert-amber";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 5: Research Expired (&gt;30d). Completeness downgraded.`;
      renderMobileBrief();
    }
    else if (state === "no-opportunities") {
      alertBox.className = "m-alert m-alert-blue";
      alertBox.style.display = "block";
      alertBox.innerHTML = `State 6: No qualifying opportunities found.`;
      worthEl.innerHTML = `<div class="p-6 text-center text-slate-400 text-xs">Zero qualified opportunities.</div>`;
      watchEl.innerHTML = ``;
    }
  };

  window.triggerMobileRefresh = function() {
    showMobileToast("↻ Refreshing completed session snapshot...");
  };

  function showMobileToast(msg) {
    const t = document.getElementById("mToast");
    t.textContent = msg;
    t.classList.add("show");
    setTimeout(() => t.classList.remove("show"), 2500);
  }
})();
