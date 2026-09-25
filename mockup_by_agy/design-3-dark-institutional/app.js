// Stock Advisory - Institutional Dark Terminal Controller
(function() {
  const data = window.STOCK_ADVISORY_DATA;
  if (!data) return;

  let currentScreen = "brief";
  let activeWindow = "day";
  let selectedIsin = "INE467B01029";
  let compIsins = ["INE467B01029", "INE009A01021", "INE021A01026"];

  window.addEventListener("DOMContentLoaded", () => {
    renderTermBrief();
    renderTickerButtons();
    renderTermDeep(selectedIsin);
    renderTermWatchlist();
    renderTermScreener();
    renderTermComparison();
    renderTermSectorNotes();
  });

  window.navigateToScreen = function(screenId) {
    currentScreen = screenId;
    document.querySelectorAll(".term-nav-btn").forEach(btn => {
      btn.classList.toggle("active", btn.dataset.screen === screenId);
    });
    document.querySelectorAll(".term-screen").forEach(sec => {
      sec.classList.toggle("active", sec.id === `screen-${screenId}`);
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  window.switchDeclineWindow = function(win) {
    activeWindow = win;
    document.getElementById("btnDay").classList.toggle("active", win === "day");
    document.getElementById("btnMonth").classList.toggle("active", win === "month");

    const isDay = win === "day";
    const bm = data.benchmarks;
    document.getElementById("bmNifty").textContent = (isDay ? bm.broadMarket.dailyChangePercent : bm.broadMarket.monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmIt").textContent = (isDay ? bm.sectors[0].dailyChangePercent : bm.sectors[0].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmFmcg").textContent = (isDay ? bm.sectors[1].dailyChangePercent : bm.sectors[1].monthlyChangePercent).toFixed(2) + "%";
    document.getElementById("bmPharma").textContent = (isDay ? bm.sectors[2].dailyChangePercent : bm.sectors[2].monthlyChangePercent).toFixed(2) + "%";

    renderTermBrief();
    showTermToast(`WINDOW_UPDATED: ${win.toUpperCase()}`);
  };

  function renderTermBrief() {
    const worthEl = document.getElementById("termWorthGrid");
    const watchEl = document.getElementById("termWatchGrid");
    worthEl.innerHTML = "";
    watchEl.innerHTML = "";

    const worth = data.companies.filter(c => c.conclusion === "Worth researching");
    const watch = data.companies.filter(c => c.conclusion === "Watch and wait");

    document.getElementById("worthCounter").textContent = `[${worth.length}_QUALIFIED]`;
    document.getElementById("watchCounter").textContent = `[${watch.length}_MONITORING]`;

    worth.forEach(c => worthEl.appendChild(createTermCard(c, false)));
    watch.forEach(c => watchEl.appendChild(createTermCard(c, true)));
  }

  function createTermCard(comp, isAmber) {
    const card = document.createElement("div");
    card.className = `term-card ${isAmber ? 'card-amber' : ''}`;

    const change = activeWindow === "day" ? comp.dailyChangePercent : comp.monthlyChangePercent;
    const pe = comp.checks.find(x => x.id === "valuation_pe");
    const roce = comp.checks.find(x => x.id === "roce");
    const de = comp.checks.find(x => x.id === "debt_equity");

    card.innerHTML = `
      <div class="tcard-head">
        <div>
          <div class="flex-center gap-3">
            <span class="font-mono font-bold text-base term-white">${comp.ticker}</span>
            <span class="font-mono text-xs term-dim">${comp.isin}</span>
            <span class="font-mono text-xs ${isAmber ? 'term-amber' : 'term-green'} font-bold">[${comp.conclusion.toUpperCase().replace(/ /g, '_')}]</span>
          </div>
          <div class="text-xs text-slate-400 mt-1">${comp.name} &bull; ${comp.sectorName}</div>
        </div>
        <div class="text-right font-mono">
          <div class="text-lg font-bold term-white">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
          <div class="text-xs term-red font-bold">${change.toFixed(2)}% (${activeWindow === 'day' ? 'DAY' : '1MO'})</div>
        </div>
      </div>

      <div class="tcard-body">
        <div>
          <div class="term-dim text-xs font-mono mb-2">[RULES_CHECK]</div>
          <div class="grid grid-cols-3 gap-2">
            <div class="t-metric-cell">
              <div class="tm-label">P/E vs SEC</div>
              <div class="tm-val ${pe.status === 'pass' ? 'term-green' : 'term-red'}">${pe.value}</div>
            </div>
            <div class="t-metric-cell">
              <div class="tm-label">ROCE</div>
              <div class="tm-val term-green">${roce.value}</div>
            </div>
            <div class="t-metric-cell">
              <div class="tm-label">DEBT/EQ</div>
              <div class="tm-val term-green">${de.value}</div>
            </div>
          </div>
          <div class="text-xs text-slate-300 mt-2 font-mono">${comp.triggerSummary}</div>
        </div>

        <div>
          <div class="term-dim text-xs font-mono mb-2">[SECTOR_CONTEXT]</div>
          <div class="text-xs term-white font-mono font-bold">${comp.sectorContext.noteTitle}</div>
          <div class="text-xs text-slate-400 mt-1 italic">"${comp.sectorContext.headwind}"</div>
          <div class="text-xs term-cyan font-mono mt-2">SEVERITY: ${comp.sectorContext.severity.toUpperCase()}</div>
        </div>

        <div>
          <div class="term-dim text-xs font-mono mb-2">[NEXT_CHECKLIST]</div>
          <div class="space-y-1 font-mono text-xs">
            ${comp.nextChecks.slice(0, 2).map(nc => `
              <div class="text-slate-300">&bull; ${nc.task} <span class="term-dim">(${nc.targetDate})</span></div>
            `).join('')}
          </div>
        </div>
      </div>

      <div class="flex-between border-t border-slate-800 pt-3 mt-3">
        <div class="flex gap-4">
          <button class="font-mono text-xs term-cyan hover:underline cursor-pointer" onclick="window.inspectTermTicker('${comp.isin}')">&gt; INSPECT_DOSSIER</button>
          <button class="font-mono text-xs term-dim hover:term-white cursor-pointer" onclick="window.openTermModal('${comp.isin}')">&gt; AUDIT_FORMULA</button>
        </div>
        <button class="btn-term-action" onclick="window.toggleTermWatchlist('${comp.isin}')">
          ${comp.watchlistData && comp.watchlistData.saved ? '[SAVED_IN_DB]' : '[+WATCHLIST]'}
        </button>
      </div>
    `;

    return card;
  }

  function renderTickerButtons() {
    const el = document.getElementById("termTickerButtons");
    el.innerHTML = "";
    data.companies.forEach(c => {
      const btn = document.createElement("button");
      btn.className = `t-ticker-btn ${c.isin === selectedIsin ? 'active' : ''}`;
      btn.textContent = `${c.ticker}`;
      btn.onclick = () => {
        selectedIsin = c.isin;
        renderTickerButtons();
        renderTermDeep(c.isin);
      };
      el.appendChild(btn);
    });
  }

  function renderTermDeep(isin) {
    const comp = data.companies.find(c => c.isin === isin) || data.companies[0];
    const container = document.getElementById("termDeepContainer");

    container.innerHTML = `
      <div class="term-panel p-6 font-mono">
        <div class="flex-between border-b border-slate-800 pb-3">
          <div>
            <div class="flex-center gap-3">
              <span class="text-xl font-bold term-white">${comp.name} (${comp.ticker})</span>
              <span class="term-cyan font-bold">[${comp.conclusion.toUpperCase()}]</span>
            </div>
            <div class="text-xs term-dim mt-1">EXCHANGE_KEY: ${comp.exchangeKey} | ISIN: ${comp.isin}</div>
          </div>
          <div class="text-right">
            <div class="text-xl font-bold term-white">₹${comp.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</div>
            <div class="text-xs term-dim">SESSION_T: ${comp.priceDate}</div>
            <div class="text-xs ${comp.corporateActionStatus.includes('distortion') ? 'term-red font-bold' : 'term-green'}">
              ${comp.corporateActionStatus}
            </div>
          </div>
        </div>

        <div class="term-banner banner-cyan mt-3">
          <strong>TRIGGER_AUDIT:</strong> ${comp.triggerSummary}
        </div>

        <!-- 3-Year Financials -->
        <div class="mt-6">
          <div class="term-dim text-xs mb-2">3-YEAR_HISTORICAL_AUDITED_STATEMENTS (INR_CRORE)</div>
          <table class="term-table">
            <thead>
              <tr>
                <th>PERIOD</th>
                <th>BASIS</th>
                <th class="text-right">REVENUE</th>
                <th class="text-right">NET_PROFIT</th>
                <th class="text-right">OPERATING_CF</th>
                <th class="text-right">CAPEX</th>
                <th class="text-right">FREE_CASH_FLOW</th>
              </tr>
            </thead>
            <tbody>
              ${comp.financials.map(f => `
                <tr>
                  <td>${f.period}</td>
                  <td>${f.basis}</td>
                  <td class="text-right">₹${f.revenueCr.toLocaleString('en-IN')}</td>
                  <td class="text-right">₹${f.netProfitCr.toLocaleString('en-IN')}</td>
                  <td class="text-right">₹${f.ocfCr.toLocaleString('en-IN')}</td>
                  <td class="text-right">₹${f.capexCr.toLocaleString('en-IN')}</td>
                  <td class="text-right term-green font-bold">₹${f.fcfCr.toLocaleString('en-IN')}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>

        <!-- Rules Table -->
        <div class="mt-6">
          <div class="term-dim text-xs mb-2">DETERMINISTIC_RULES_EVALUATION</div>
          <table class="term-table">
            <thead>
              <tr>
                <th>RULE_IDENTIFIER</th>
                <th>THRESHOLD</th>
                <th>EVALUATED_VAL</th>
                <th>VERDICT</th>
                <th>STATEMENT_EVIDENCE</th>
              </tr>
            </thead>
            <tbody>
              ${comp.checks.map(k => `
                <tr>
                  <td><strong>${k.name}</strong></td>
                  <td class="term-dim">${k.rule}</td>
                  <td class="font-bold term-white">${k.value}</td>
                  <td class="${k.status === 'pass' ? 'term-green font-bold' : (k.status === 'fail' ? 'term-red font-bold' : 'term-dim')}">[${k.status.toUpperCase()}]</td>
                  <td class="text-xs text-slate-300">${k.evidence}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>

        <!-- Next Check Audit -->
        <div class="mt-6 border-t border-slate-800 pt-4">
          <div class="term-dim text-xs mb-2">ACTIONABLE_NEXT_CHECKS</div>
          <div class="space-y-1 text-xs">
            ${comp.nextChecks.map(nc => `
              <div>[${nc.done ? 'X' : ' '}] ${nc.task} &bull; TARGET: ${nc.targetDate}</div>
            `).join('')}
          </div>
        </div>

      </div>
    `;
  }

  window.inspectTermTicker = function(isin) {
    selectedIsin = isin;
    renderTickerButtons();
    renderTermDeep(isin);
    window.navigateToScreen('analysis');
  };

  window.openTermModal = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    document.getElementById("termModalTitle").textContent = `EVIDENCE_LOG: ${comp.ticker}`;
    document.getElementById("termModalBody").innerHTML = `
      <div class="p-2 bg-slate-900 border border-slate-700 mb-3">
        SNAPSHOT_ID: SNP-20260924-001 | RULE_VER: ${data.meta.ruleVersion}
      </div>
      <div class="space-y-3">
        ${comp.checks.map(c => `
          <div class="border border-slate-800 p-2">
            <div class="flex-between">
              <span class="term-white font-bold">${c.name}</span>
              <span class="${c.status === 'pass' ? 'term-green' : 'term-red'} font-bold">[${c.status.toUpperCase()}]</span>
            </div>
            <div class="term-dim mt-1">RULE: ${c.rule} | VALUE: ${c.value}</div>
            <div class="text-slate-300 mt-1">${c.evidence}</div>
          </div>
        `).join('')}
      </div>
    `;

    document.getElementById("termModalBackdrop").classList.add("active");
  };

  window.closeTermModal = function(e) {
    if (e && e.target !== e.currentTarget && !e.target.classList.contains("term-close-btn")) return;
    document.getElementById("termModalBackdrop").classList.remove("active");
  };

  // Watchlist
  function renderTermWatchlist() {
    const el = document.getElementById("termWatchlistList");
    const saved = data.companies.filter(c => c.watchlistData && c.watchlistData.saved);
    document.getElementById("termWatchCount").textContent = saved.length;

    if (saved.length === 0) {
      el.innerHTML = `<div class="p-6 text-center term-dim font-mono">DATABASE_EMPTY: No entries.</div>`;
      return;
    }

    el.innerHTML = saved.map(c => `
      <div class="term-card font-mono">
        <div class="flex-between">
          <div>
            <strong class="text-base term-white">${c.ticker}</strong>
            <span class="term-dim text-xs ml-2">${c.isin} &bull; ${c.conclusion}</span>
          </div>
          <button class="btn-term-action text-xs" onclick="window.toggleTermWatchlist('${c.isin}')">[REMOVE]</button>
        </div>
        <div class="grid grid-cols-2 gap-3 mt-3 text-xs">
          <div class="p-2 bg-slate-900 border border-slate-800">
            <span class="term-cyan">THESIS:</span> ${c.watchlistData.thesis || 'NONE'}
          </div>
          <div class="p-2 bg-slate-900 border border-slate-800">
            <span class="term-red">CONCERNS:</span> ${c.watchlistData.concerns || 'NONE'}
          </div>
        </div>
      </div>
    `).join('');
  }

  window.toggleTermWatchlist = function(isin) {
    const comp = data.companies.find(c => c.isin === isin);
    if (!comp) return;

    if (!comp.watchlistData) {
      comp.watchlistData = { saved: true, thesis: "Decline assessment.", concerns: "Client delays.", nextReviewDate: "2026-10-15" };
    } else {
      comp.watchlistData.saved = !comp.watchlistData.saved;
    }

    renderTermBrief();
    renderTermWatchlist();
    showTermToast(`WATCHLIST_COMMIT: ${comp.ticker} -> ${comp.watchlistData.saved ? 'SAVED' : 'PURGED'}`);
  };

  // Screener
  function renderTermScreener() {
    const tbody = document.getElementById("termTableBody");
    const q = (document.getElementById("termSearch")?.value || "").toLowerCase();
    const sector = document.getElementById("termSector")?.value || "all";
    const conclusion = document.getElementById("termConclusion")?.value || "all";

    let filtered = data.companies.filter(c => {
      const mQ = c.name.toLowerCase().includes(q) || c.ticker.toLowerCase().includes(q);
      const mS = sector === "all" || c.sectorId === sector;
      const mC = conclusion === "all" || c.conclusion === conclusion;
      return mQ && mS && mC;
    });

    tbody.innerHTML = filtered.map(c => `
      <tr>
        <td>
          <a href="javascript:void(0)" onclick="window.inspectTermTicker('${c.isin}')" class="term-cyan font-bold">${c.ticker}</a>
        </td>
        <td>${c.sectorName}</td>
        <td class="text-right font-bold">₹${c.currentPrice.toLocaleString('en-IN', {minimumFractionDigits: 2})}</td>
        <td class="text-right term-red font-bold">${c.dailyChangePercent.toFixed(2)}%</td>
        <td class="text-right term-red">${c.monthlyChangePercent.toFixed(2)}%</td>
        <td class="text-right">${c.checks.find(x => x.id === "valuation_pe")?.value || 'N/A'}</td>
        <td class="text-right">${c.checks.find(x => x.id === "roce")?.value || 'N/A'}</td>
        <td class="text-right">${c.checks.find(x => x.id === "debt_equity")?.value || 'N/A'}</td>
        <td><span class="${c.conclusion.includes('Worth') ? 'term-green font-bold' : (c.conclusion.includes('Watch') ? 'term-amber' : 'term-red')}">[${c.conclusion.toUpperCase()}]</span></td>
        <td class="text-center">
          <input type="checkbox" ${compIsins.includes(c.isin) ? 'checked' : ''} onchange="window.toggleTermCompare('${c.isin}')">
        </td>
      </tr>
    `).join('');
  }

  window.filterTermScreener = renderTermScreener;

  window.toggleTermCompare = function(isin) {
    if (compIsins.includes(isin)) {
      compIsins = compIsins.filter(x => x !== isin);
    } else {
      if (compIsins.length >= 3) {
        showTermToast("LIMIT_EXCEEDED: MAX 3 ITEMS");
        renderTermScreener();
        return;
      }
      compIsins.push(isin);
    }
    renderTermScreener();
    renderTermComparison();
  };

  window.clearTermComparison = function() {
    compIsins = [];
    renderTermScreener();
    renderTermComparison();
  };

  function renderTermComparison() {
    const container = document.getElementById("termMatrixWrap");
    const banner = document.getElementById("termCrossBanner");
    const comps = data.companies.filter(c => compIsins.includes(c.isin));

    if (comps.length === 0) {
      container.innerHTML = `<div class="p-4 text-center term-dim font-mono">SELECT_ITEMS_FROM_TABLE</div>`;
      banner.style.display = "none";
      return;
    }

    const sectors = new Set(comps.map(c => c.sectorId));
    banner.style.display = sectors.size > 1 ? "block" : "none";

    container.innerHTML = `
      <table class="term-table font-mono">
        <thead>
          <tr>
            <th>METRIC</th>
            ${comps.map(c => `<th>${c.ticker}</th>`).join('')}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>VERDICT</td>
            ${comps.map(c => `<td><span class="${c.conclusion.includes('Worth') ? 'term-green' : 'term-amber'} font-bold">[${c.conclusion.toUpperCase()}]</span></td>`).join('')}
          </tr>
          <tr>
            <td>P/E_RATIO</td>
            ${comps.map(c => `<td>${c.checks.find(x => x.id === "valuation_pe")?.value || 'N/A'}</td>`).join('')}
          </tr>
          <tr>
            <td>ROCE</td>
            ${comps.map(c => `<td class="term-green font-bold">${c.checks.find(x => x.id === "roce")?.value || 'N/A'}</td>`).join('')}
          </tr>
          <tr>
            <td>DEBT/EQUITY</td>
            ${comps.map(c => `<td>${c.checks.find(x => x.id === "debt_equity")?.value || 'N/A'}</td>`).join('')}
          </tr>
        </tbody>
      </table>
    `;
  }

  function renderTermSectorNotes() {
    const el = document.getElementById("termSectorNotes");
    el.innerHTML = data.sectorResearchNotes.map(n => `
      <div class="border border-slate-800 p-3 bg-slate-900">
        <div class="flex-between">
          <strong class="term-cyan">${n.sectorName}</strong>
          <span class="term-amber font-bold">[${n.severity.toUpperCase()}]</span>
        </div>
        <div class="term-white text-xs mt-1 font-bold">${n.title}</div>
        <p class="text-xs text-slate-400 mt-1">${n.summary}</p>
        <div class="text-xs term-dim mt-2">SOURCE: <a href="${n.sourceUrl}" target="_blank" class="term-cyan underline">${n.sourceTitle}</a></div>
      </div>
    `).join('');
  }

  window.saveTermRules = function() {
    data.meta.ruleVersion = "v1.3 (TERM_RECALC)";
    document.getElementById("termRuleVer").textContent = "[v1.3]";
    showTermToast("RULES_UPDATED: SNAPSHOT_RECOMPUTED (v1.3)");
  };

  window.switchTermState = function(state) {
    const box = document.getElementById("termAlertBox");
    const worthEl = document.getElementById("termWorthGrid");
    const watchEl = document.getElementById("termWatchGrid");

    box.style.display = "none";

    if (state === "normal") {
      renderTermBrief();
      showTermToast("NORMAL_STATE_RESTORED");
      return;
    }

    if (state === "no-data") {
      box.className = "term-banner banner-cyan";
      box.style.display = "block";
      box.innerHTML = `STATE_01: NO_DATA_INITIALIZED &bull; Execute initial completed trading session ingestion.`;
      worthEl.innerHTML = `<div class="p-6 text-center term-dim font-mono">DATABASE_UNPOPULATED</div>`;
      watchEl.innerHTML = ``;
    }
    else if (state === "refreshing") {
      box.className = "term-banner banner-cyan";
      box.style.display = "block";
      box.innerHTML = `STATE_02: REFRESH_RUNNING (JOB_ID: JOB-20260925-081) &bull; Cache intact.`;
      renderTermBrief();
    }
    else if (state === "token-rejected") {
      box.className = "term-banner banner-red";
      box.style.display = "block";
      box.innerHTML = `STATE_03: TOKEN_AUTH_FAILURE (HTTP 401) &bull; Token expired. Cached snapshot preserved.`;
      renderTermBrief();
    }
    else if (state === "partial-failure") {
      box.className = "term-banner banner-amber";
      box.style.display = "block";
      box.innerHTML = `STATE_04: PARTIAL_PROVIDER_FAILURE &bull; 1 company balance sheet timed out. Coverage: 80%.`;
      renderTermBrief();
    }
    else if (state === "research-expired") {
      box.className = "term-banner banner-amber";
      box.style.display = "block";
      box.innerHTML = `STATE_05: RESEARCH_NOTE_EXPIRED &bull; Sector note >30 days. Completeness downgraded.`;
      renderTermBrief();
    }
    else if (state === "no-opportunities") {
      box.className = "term-banner banner-cyan";
      box.style.display = "block";
      box.innerHTML = `STATE_06: ZERO_QUALIFYING_OPPORTUNITIES &bull; All universe companies failed criteria.`;
      worthEl.innerHTML = `<div class="p-6 text-center term-dim font-mono">ZERO_QUALIFYING_CANDIDATES</div>`;
      watchEl.innerHTML = ``;
    }
  };

  function showTermToast(msg) {
    const box = document.getElementById("termToasts");
    const t = document.createElement("div");
    t.className = "term-toast";
    t.textContent = `> ${msg}`;
    box.appendChild(t);
    setTimeout(() => t.remove(), 2800);
  }
})();
