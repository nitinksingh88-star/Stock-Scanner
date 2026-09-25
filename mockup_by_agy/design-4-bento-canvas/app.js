// Stock Advisory - Bento Modular Analytical Canvas Controller
(function() {
  const data = window.STOCK_ADVISORY_DATA;
  if (!data) return;

  let currentScreen = "brief";
  let activeWindow = "day";
  let selectedIsin = "INE467B01029"; // TCS
  let compIsins = ["INE467B01029", "INE009A01021", "INE021A01026"];

  window.addEventListener("DOMContentLoaded", () => {
    renderBentoBrief();
    renderBentoCompanyPills();
    renderBentoDeepView(selectedIsin);
    renderBentoWatchlist();
    renderBentoScreener();
    renderBentoComparison();
    renderBentoSectorNotes();
  });

  window.navigateToScreen = function(screenId) {
    currentScreen = screenId;
    document.querySelectorAll(".bento-tab").forEach(tab => {
      tab.classList.toggle("active", tab.dataset.screen === screenId);
    });
    document.querySelectorAll(".bento-screen").forEach(sec => {
      sec.classList.toggle("active", sec.id === `screen-${screenId}`);
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  window.switchDeclineWindow = function(win) {
    activeWindow = win;
    document.getElementById("btnBentoDay").classList.toggle("active", win === "day");
    document.getElementById("btnBentoMonth").classList.toggle("active", win === "month");

    const isDay = win === "day";
    const bm = data.benchmarks;
    document.getElementById("bmNifty").textContent = (isDay ? bm.broadMarket.dailyChangePercent : bm.broadMarket.monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmIt").textContent = (isDay ? bm.sectors[0].dailyChangePercent : bm.sectors[0].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmFmcg").textContent = (isDay ? bm.sectors[1].dailyChangePercent : bm.sectors[1].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmPharma").textContent = (isDay ? bm.sectors[2].dailyChangePercent : bm.sectors[2].monthlyChangePercent).toFixed(2) + "%";

    renderBentoBrief();
    showBentoToast(`Window changed to ${win === 'day' ? 'Daily' : '1-Month'}`);
  };

  function renderBentoBrief() {
    const worthEl = document.getElementById("bentoWorthList");
    const watchEl = document.getElementById("bentoWatchList");
    worthEl.innerHTML = "";
    watchEl.innerHTML = "";

    const worth = data.companies.filter(c => c.conclusion === "Worth researching");
    const watch = data.companies.filter(c => c.conclusion === "Watch and wait");

    document.getElementById("bentoWorthCount").textContent = `${worth.length} Qualified`;
    document.getElementById("bentoWatchCountBadge").textContent = `${watch.length} Monitoring`;

    worth.forEach(c => worthEl.appendChild(createBentoCard(c)));
    watch.forEach(c => watchEl.appendChild(createBentoCard(c)));
  }

  function createBentoCard(comp) {
    const card = document.createElement("div");
    card.className = "bento-candidate-tile";

    const change = activeWindow === "day" ? comp.dailyChangePercent : comp.monthlyChangePercent;
    const pe = comp.checks.find(x => x.id === "valuation_pe");
    const roce = comp.checks.find(x => x.id === "roce");
    const de = comp.checks.find(x => x.id === "debt_equity");

    card.innerHTML = `
      <div>
        <div class="bct-head">
          <div>
            <div class="flex-center gap-2">
              <span class="bct-title">${comp.name}</span>
              <span class="bct-ticker">${comp.ticker}</span>
            </div>
            <div class="text-xs text-zinc-400 mt-1">${comp.sectorName} &bull; ISIN: ${comp.isin}</div>
          </div>
          <div class="text-right">
            <div class="text-base font-bold font-mono">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs text-rose-600 font-bold font-mono">${change.toFixed(2)}% (${activeWindow === 'day' ? 'Day' : '1-Mo'})</div>
          </div>
        </div>

        <div class="grid grid-cols-3 gap-2 mt-3">
          <div class="bento-pill-stat">
            <div class="bps-label">P/E vs SEC</div>
            <div class="bps-val ${pe.status === 'pass' ? 'text-emerald-600' : 'text-rose-600'}">${pe.value}</div>
          </div>
          <div class="bento-pill-stat">
            <div class="bps-label">ROCE</div>
            <div class="bps-val text-emerald-600">${roce.value}</div>
          </div>
          <div class="bento-pill-stat">
            <div class="bps-label">DEBT/EQ</div>
            <div class="bps-val text-emerald-600">${de.value}</div>
          </div>
        </div>

        <p class="text-xs text-zinc-600 mt-3 leading-relaxed">
          <strong>Trigger:</strong> ${comp.triggerSummary}
        </p>

        <div class="bct-quote">
          "${comp.sectorContext.headwind}"
        </div>
      </div>

      <div class="flex-between border-t border-zinc-100 pt-3 mt-4">
        <div class="flex gap-3">
          <button class="bento-btn-sm" onclick="window.inspectBentoCompany('${comp.isin}')">Analysis Dossier &rarr;</button>
          <button class="bento-btn-sm" onclick="window.openBentoModal('${comp.isin}')">Audit Evidence</button>
        </div>
        <button class="bento-btn-sm" onclick="window.toggleBentoWatchlist('${comp.isin}')">
          ${comp.watchlistData && comp.watchlistData.saved ? '✓ Saved' : '+ Watchlist'}
        </button>
      </div>
    `;

    return card;
  }

  function renderBentoCompanyPills() {
    const el = document.getElementById("bentoCompanyPills");
    el.innerHTML = "";
    data.companies.forEach(c => {
      const btn = document.createElement("button");
      btn.className = `bp-btn ${c.isin === selectedIsin ? 'active' : ''}`;
      btn.textContent = `${c.ticker} (${c.conclusion})`;
      btn.onclick = () => {
        selectedIsin = c.isin;
        renderBentoCompanyPills();
        renderBentoDeepView(c.isin);
      };
      el.appendChild(btn);
    });
  }

  function renderBentoDeepView(isin) {
    const comp = data.companies.find(c => c.isin === isin) || data.companies[0];
    const container = document.getElementById("bentoDeepViewContainer");

    container.innerHTML = `
      <div class="bento-tile">
        <div class="flex-between border-b border-zinc-100 pb-3">
          <div>
            <h2 class="text-2xl font-bold text-zinc-900">${comp.name} (${comp.ticker})</h2>
            <div class="text-xs text-zinc-400 mt-1">${comp.sectorName} &bull; ISIN: ${comp.isin}</div>
          </div>
          <div class="text-right">
            <div class="text-2xl font-bold font-mono">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs text-zinc-400">Date: ${comp.priceDate}</div>
            <div class="text-xs font-semibold ${comp.corporateActionStatus.includes('distortion') ? 'text-rose-600' : 'text-emerald-700'}">
              ${comp.corporateActionStatus}
            </div>
          </div>
        </div>

        <div class="bento-alert alert-blue mt-4">
          <div class="text-xs font-bold uppercase text-blue-900">Trigger Audit</div>
          <p class="text-xs text-blue-900 mt-1">${comp.triggerSummary}</p>
        </div>

        <!-- 3-Year Financials -->
        <div class="mt-6">
          <h3 class="text-base font-bold text-zinc-900 mb-2">3-Year Audited Annual Financials (₹ Cr)</h3>
          <div class="overflow-x-auto">
            <table class="bento-table">
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
                    <td><span class="bento-chip-neutral text-xs">${f.basis}</span></td>
                    <td class="text-right font-mono">₹${f.revenueCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.netProfitCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.ocfCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono">₹${f.capexCr.toLocaleString('en-IN')}</td>
                    <td class="text-right font-mono font-bold text-emerald-700">₹${f.fcfCr.toLocaleString('en-IN')}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Rules Table -->
        <div class="mt-6">
          <h3 class="text-base font-bold text-zinc-900 mb-2">Rules Engine Checklist</h3>
          <div class="overflow-x-auto">
            <table class="bento-table">
              <thead>
                <tr>
                  <th>Rule Name</th>
                  <th>Threshold</th>
                  <th>Actual Value</th>
                  <th>Verdict</th>
                  <th>Evidence Basis</th>
                </tr>
              </thead>
              <tbody>
                ${comp.checks.map(k => `
                  <tr>
                    <td><strong>${k.name}</strong></td>
                    <td class="text-xs font-mono text-zinc-500">${k.rule}</td>
                    <td class="font-mono font-bold">${k.value}</td>
                    <td>
                      <span class="badge ${k.status === 'pass' ? 'badge-worth-researching' : (k.status === 'fail' ? 'badge-fundamental-concerns' : 'badge-insufficient-evidence')}">
                        ${k.status.toUpperCase()}
                      </span>
                    </td>
                    <td class="text-xs text-zinc-600">${k.evidence}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Next Check Tasks -->
        <div class="mt-6 border-t border-zinc-100 pt-4">
          <h4 class="text-sm font-bold text-zinc-900 mb-2">Actionable Next Review Checklist</h4>
          <div class="space-y-1">
            ${comp.nextChecks.map(nc => `
              <div class="flex items-center gap-2 text-xs">
                <input type="checkbox" ${nc.done ? 'checked' : ''}>
                <span class="${nc.done ? 'line-through text-zinc-400' : 'text-zinc-800'}">${nc.task} (${nc.targetDate})</span>
              </div>
            `).join('')}
          </div>
        </div>

      </div>
    `;
  }

  window.inspectBentoCompany = function(isin) {
    selectedIsin = isin;
    renderBentoCompanyPills();
    renderBentoDeepView(isin);
    window.navigateToScreen('analysis');
  };

  window.openBentoModal = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    document.getElementById("bentoModalTitle").textContent = `${comp.name} Evidence Audit`;
    document.getElementById("bentoModalBody").innerHTML = `
      <div class="p-3 bg-zinc-100 rounded-lg mb-3">
        Snapshot: SNP-20260924-001 &bull; Rule Version: ${data.meta.ruleVersion}
      </div>
      <div class="space-y-2">
        ${comp.checks.map(c => `
          <div class="p-3 border border-zinc-200 rounded-lg">
            <div class="flex-between">
              <strong>${c.name}</strong>
              <span class="badge ${c.status === 'pass' ? 'badge-worth-researching' : 'badge-fundamental-concerns'}">${c.status}</span>
            </div>
            <div class="text-xs font-mono text-zinc-500 mt-1">${c.rule} &bull; ${c.value}</div>
            <div class="text-xs text-zinc-600 mt-1">${c.evidence}</div>
          </div>
        `).join('')}
      </div>
    `;

    document.getElementById("bentoModalBackdrop").classList.add("active");
  };

  window.closeBentoModal = function(e) {
    if (e && e.target !== e.currentTarget && !e.target.classList.contains("bento-close-btn")) return;
    document.getElementById("bentoModalBackdrop").classList.remove("active");
  };

  // Watchlist
  function renderBentoWatchlist() {
    const el = document.getElementById("bentoWatchlistContainer");
    const saved = data.companies.filter(c => c.watchlistData && c.watchlistData.saved);
    document.getElementById("bentoWatchCount").textContent = saved.length;

    if (saved.length === 0) {
      el.innerHTML = `<div class="p-6 text-center text-zinc-400 text-sm">Watchlist is currently empty.</div>`;
      return;
    }

    el.innerHTML = saved.map(c => `
      <div class="bento-subcard">
        <div class="flex-between">
          <div>
            <strong class="text-base text-zinc-900">${c.name} (${c.ticker})</strong>
            <div class="text-xs text-zinc-400">${c.isin} &bull; ${c.conclusion}</div>
          </div>
          <button class="bento-btn-sm" onclick="window.toggleBentoWatchlist('${c.isin}')">Remove</button>
        </div>
        <div class="mt-3 text-xs">
          <div class="p-2 bg-zinc-200 rounded mt-1"><strong>Thesis:</strong> ${c.watchlistData.thesis || 'None'}</div>
          <div class="p-2 bg-zinc-200 rounded mt-1"><strong>Concerns:</strong> ${c.watchlistData.concerns || 'None'}</div>
        </div>
      </div>
    `).join('');
  }

  window.toggleBentoWatchlist = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    if (!comp.watchlistData) {
      comp.watchlistData = { saved: true, thesis: "Evaluating opportunity.", concerns: "Sector delay.", nextReviewDate: "2026-10-15" };
    } else {
      comp.watchlistData.saved = !comp.watchlistData.saved;
    }

    renderBentoBrief();
    renderBentoWatchlist();
    showBentoToast(`${comp.ticker} watchlist updated.`);
  };

  // Screener
  function renderBentoScreener() {
    const tbody = document.getElementById("bentoTableBody");
    const q = (document.getElementById("bentoSearch")?.value || "").toLowerCase();
    const sector = document.getElementById("bentoSector")?.value || "all";
    const conclusion = document.getElementById("bentoConclusion")?.value || "all";

    let filtered = data.companies.filter(c => {
      const mQ = c.name.toLowerCase().includes(q) || c.ticker.toLowerCase().includes(q);
      const mS = sector === "all" || c.sectorId === sector;
      const mC = conclusion === "all" || c.conclusion === conclusion;
      return mQ && mS && mC;
    });

    tbody.innerHTML = filtered.map(c => `
      <tr>
        <td>
          <a href="javascript:void(0)" onclick="window.inspectBentoCompany('${c.isin}')" class="font-bold text-zinc-900">${c.ticker}</a>
          <div class="text-xs text-zinc-400">${c.name}</div>
        </td>
        <td>${c.sectorName}</td>
        <td class="text-right font-mono font-bold">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</td>
        <td class="text-right font-mono text-rose-600 font-bold">${c.dailyChangePercent.toFixed(2)}%</td>
        <td class="text-right font-mono text-rose-700">${c.monthlyChangePercent.toFixed(2)}%</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "valuation_pe")?.value || 'Unavailable'}</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "roce")?.value || 'Unavailable'}</td>
        <td class="text-right font-mono">${c.checks.find(x => x.id === "debt_equity")?.value || 'Unavailable'}</td>
        <td><span class="badge ${c.conclusionBadgeClass} text-xs">${c.conclusion}</span></td>
        <td class="text-center">
          <input type="checkbox" ${compIsins.includes(c.isin) ? 'checked' : ''} onchange="window.toggleBentoCompare('${c.isin}')">
        </td>
      </tr>
    `).join('');
  }

  window.filterBentoScreener = renderBentoScreener;

  window.toggleBentoCompare = function(isin) {
    if (compIsins.includes(isin)) {
      compIsins = compIsins.filter(x => x !== isin);
    } else {
      if (compIsins.length >= 3) {
        showBentoToast("Max 3 items allowed in comparison.");
        renderBentoScreener();
        return;
      }
      compIsins.push(isin);
    }
    renderBentoScreener();
    renderBentoComparison();
  };

  window.clearBentoComparison = function() {
    compIsins = [];
    renderBentoScreener();
    renderBentoComparison();
  };

  function renderBentoComparison() {
    const container = document.getElementById("bentoMatrixContainer");
    const banner = document.getElementById("bentoCrossBanner");
    const comps = data.companies.filter(c => compIsins.includes(c.isin));

    if (comps.length === 0) {
      container.innerHTML = `<div class="p-6 text-center text-zinc-400 text-sm">Select companies in screener table to compare side-by-side.</div>`;
      banner.style.display = "none";
      return;
    }

    const sectors = new Set(comps.map(c => c.sectorId));
    banner.style.display = sectors.size > 1 ? "block" : "none";

    container.innerHTML = `
      <table class="bento-table">
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
            <td><strong>Free Cash Flow (FY25)</strong></td>
            ${comps.map(c => `<td class="font-mono font-bold text-emerald-700">₹${c.financials[c.financials.length-1].fcfCr.toLocaleString('en-IN')} Cr</td>`).join('')}
          </tr>
        </tbody>
      </table>
    `;
  }

  function renderBentoSectorNotes() {
    const el = document.getElementById("bentoSectorNotesList");
    el.innerHTML = data.sectorResearchNotes.map(n => `
      <div class="bento-subcard">
        <div class="flex-between">
          <strong class="text-xs font-bold text-zinc-900">${n.sectorName}</strong>
          <span class="bento-chip-neutral">${n.severity}</span>
        </div>
        <div class="text-xs font-bold text-zinc-800 mt-1">${n.title}</div>
        <p class="text-xs text-zinc-600 mt-1">${n.summary}</p>
        <div class="text-xs text-zinc-400 mt-2">Source: <a href="${n.sourceUrl}" target="_blank" class="text-blue-600 underline">${n.sourceTitle}</a></div>
      </div>
    `).join('');
  }

  window.saveBentoRules = function() {
    data.meta.ruleVersion = "v1.3 (Bento)";
    document.getElementById("bentoRuleVer").textContent = "v1.3";
    showBentoToast("Rules saved & recalculated.");
  };

  window.switchBentoState = function(state) {
    const box = document.getElementById("bentoAlertBox");
    const worthEl = document.getElementById("bentoWorthList");
    const watchEl = document.getElementById("bentoWatchList");

    box.style.display = "none";

    if (state === "normal") {
      renderBentoBrief();
      showBentoToast("Restored normal state.");
      return;
    }

    if (state === "no-data") {
      box.className = "bento-alert alert-blue";
      box.style.display = "block";
      box.innerHTML = `State 1: Initial Setup — No market data loaded yet. Connect token and run first refresh.`;
      worthEl.innerHTML = `<div class="p-6 text-center text-zinc-400">Database ready for initial refresh.</div>`;
      watchEl.innerHTML = ``;
    }
    else if (state === "refreshing") {
      box.className = "bento-alert alert-blue";
      box.style.display = "block";
      box.innerHTML = `State 2: Refreshing Snapshot... — Ingesting provider data. Previous snapshot visible.`;
      renderBentoBrief();
    }
    else if (state === "token-rejected") {
      box.className = "bento-alert alert-red";
      box.style.display = "block";
      box.innerHTML = `State 3: Token Auth Failure — Upstox token rejected. Update credential. Cached data preserved.`;
      renderBentoBrief();
    }
    else if (state === "partial-failure") {
      box.className = "bento-alert alert-amber";
      box.style.display = "block";
      box.innerHTML = `State 4: Partial Failure — 1 company balance sheet missing. Coverage: 80%.`;
      renderBentoBrief();
    }
    else if (state === "research-expired") {
      box.className = "bento-alert alert-amber";
      box.style.display = "block";
      box.innerHTML = `State 5: Research Expired — FMCG note >30 days. Completeness downgraded.`;
      renderBentoBrief();
    }
    else if (state === "no-opportunities") {
      box.className = "bento-alert alert-blue";
      box.style.display = "block";
      box.innerHTML = `State 6: Zero Qualifying Opportunities — No covered stock passed all rules.`;
      worthEl.innerHTML = `<div class="p-6 text-center text-zinc-400">Zero opportunities found.</div>`;
      watchEl.innerHTML = ``;
    }
  };

  function showBentoToast(msg) {
    const box = document.getElementById("bentoToasts");
    const t = document.createElement("div");
    t.className = "b-toast";
    t.textContent = msg;
    box.appendChild(t);
    setTimeout(() => t.remove(), 2800);
  }
})();
