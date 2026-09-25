import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/company.dart';
import '../../models/opportunity_brief.dart';
import '../../services/api_provider.dart';

/// Screen APP-01: Opportunity Brief (Home Screen)
class OpportunityBriefScreen extends ConsumerWidget {
  final Function(String isin)? onSelectCompany;

  const OpportunityBriefScreen({super.key, this.onSelectCompany});

  void _showEvidenceSheet(BuildContext context, Company comp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EvidenceBottomSheet(company: comp),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefAsync = ref.watch(briefDataProvider);
    final activeWindow = ref.watch(briefWindowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Opportunity Brief', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(briefDataProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.greenPass, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('24-Sep-2026 (T)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Text('Horizon: 1–3Y  •  Covered: 5/35', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      body: briefAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Error loading Opportunity Brief: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(briefDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (briefData) {
          final worthCandidates = briefData.worthResearching;
          final watchCandidates = briefData.watchAndWait;
          final isDay = activeWindow == 'day';

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(briefDataProvider),
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // 1. Decline Window Segmented Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DECLINE DISCOVERY:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          _WindowChip(
                            label: 'Daily (≤ -2%)',
                            isSelected: activeWindow == 'day',
                            onTap: () => ref.read(briefWindowProvider.notifier).state = 'day',
                          ),
                          _WindowChip(
                            label: '1-Mo (≤ -8%)',
                            isSelected: activeWindow == 'month',
                            onTap: () => ref.read(briefWindowProvider.notifier).state = 'month',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Horizontal Benchmark Stress Slider
                SizedBox(
                  height: 82,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _BenchmarkCard(
                        type: 'BROAD MARKET',
                        name: briefData.benchmarks.broadMarket.name,
                        change: isDay
                            ? '${briefData.benchmarks.broadMarket.dailyChangePercent.toStringAsFixed(2)}%'
                            : '${briefData.benchmarks.broadMarket.monthlyChangePercent.toStringAsFixed(2)}%',
                      ),
                      ...briefData.benchmarks.sectors.map((sec) => _BenchmarkCard(
                            type: sec.isProxy ? 'SECTOR PROXY' : 'SECTOR INDEX',
                            name: sec.name,
                            change: isDay
                                ? '${sec.dailyChangePercent.toStringAsFixed(2)}%'
                                : '${sec.monthlyChangePercent.toStringAsFixed(2)}%',
                            isProxy: sec.isProxy,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Primary Candidates: Worth Researching
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DESERVING ATTENTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.greenPassBg, borderRadius: BorderRadius.circular(12)),
                      child: Text('${worthCandidates.length} Qualified', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.greenPass)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (worthCandidates.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('No companies currently meet all positive fundamental criteria in this decline window.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                else
                  ...worthCandidates.map((comp) => _CandidateCard(
                        company: comp,
                        selectedWindow: activeWindow,
                        onEvidenceTap: () => _showEvidenceSheet(context, comp),
                        onWatchlistTap: () => ref.read(watchlistProvider.notifier).toggleWatchlist(comp),
                        onCardTap: () => onSelectCompany?.call(comp.isin),
                      )),

                const SizedBox(height: 16),

                // 4. Monitoring Queue: Watch and Wait
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('WATCH AND WAIT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppTheme.amberWarn)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.amberWarnBg, borderRadius: BorderRadius.circular(12)),
                      child: Text('${watchCandidates.length} Monitoring', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.amberWarn)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...watchCandidates.map((comp) => _CandidateCard(
                      company: comp,
                      selectedWindow: activeWindow,
                      onEvidenceTap: () => _showEvidenceSheet(context, comp),
                      onWatchlistTap: () => ref.read(watchlistProvider.notifier).toggleWatchlist(comp),
                      onCardTap: () => onSelectCompany?.call(comp.isin),
                    )),

                const SizedBox(height: 16),

                // 5. Exclusions Notice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            'Universe Exclusions Summary (${briefData.exclusionsSummary.totalCovered} Covered)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• ${briefData.exclusionsSummary.disqualifiedFundamental} disqualified due to fundamental valuation failure (Asian Paints P/E 46.5x vs benchmark 41.2x).\n'
                        '• ${briefData.exclusionsSummary.disqualifiedCorporateAction} disqualified due to unverified corporate action split distortion (Titan 1:1 bonus share restatement pending).\n'
                        '• ${briefData.exclusionsSummary.positiveNoDecline} stocks did not decline beyond the $activeWindow threshold.',
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WindowChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WindowChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }
}

class _BenchmarkCard extends StatelessWidget {
  final String type;
  final String name;
  final String change;
  final bool isProxy;

  const _BenchmarkCard({required this.type, required this.name, required this.change, this.isProxy = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(type, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              if (isProxy) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(2)),
                  child: const Text('PROXY', style: TextStyle(fontSize: 7, color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(change, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.redFail)),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final Company company;
  final String selectedWindow;
  final VoidCallback onEvidenceTap;
  final VoidCallback onWatchlistTap;
  final VoidCallback onCardTap;

  const _CandidateCard({
    required this.company,
    required this.selectedWindow,
    required this.onEvidenceTap,
    required this.onWatchlistTap,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDay = selectedWindow == 'day';
    final change = isDay ? company.dailyChangePercent : company.monthlyChangePercent;
    final benchmarkChange = isDay ? company.sectorDailyChange : company.sectorMonthlyChange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(company.ticker, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text(company.sectorName, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          ),
                        ],
                      ),
                      Text(company.name, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${company.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: change < 0 ? AppTheme.redFail : AppTheme.greenPass)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, size: 14, color: AppTheme.redFail),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Fell ${change.toStringAsFixed(2)}% vs sector benchmark ${benchmarkChange.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Three Check Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricBadge(label: 'ROCE', value: company.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value, status: 'pass'),
                  _MetricBadge(label: 'D/E', value: company.checks.firstWhere((chk) => chk.id == 'debt_equity', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value, status: 'pass'),
                  _MetricBadge(label: 'P/E', value: company.checks.firstWhere((chk) => chk.id == 'valuation_pe', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value, status: company.checks.firstWhere((chk) => chk.id == 'valuation_pe', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).status),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    icon: const Icon(Icons.analytics_outlined, size: 14),
                    label: const Text('View Evidence & Formulas', style: TextStyle(fontSize: 11)),
                    onPressed: onEvidenceTap,
                  ),
                  IconButton(
                    icon: Icon(company.isSavedInWatchlist ? Icons.bookmark : Icons.bookmark_border, size: 20, color: company.isSavedInWatchlist ? Colors.amber.shade800 : Colors.grey),
                    onPressed: onWatchlistTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final String status;

  const _MetricBadge({required this.label, required this.value, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == 'pass') {
      color = AppTheme.greenPass;
    } else if (status == 'fail') {
      color = AppTheme.redFail;
    } else {
      color = AppTheme.slateGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _EvidenceBottomSheet extends StatelessWidget {
  final Company company;

  const _EvidenceBottomSheet({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Audit Trace: ${company.ticker}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('FORMULA & PRECEDENCE PROOF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          ...company.checks.map((chk) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(chk.isPass ? Icons.check_circle : (chk.isFail ? Icons.cancel : Icons.help), size: 14, color: chk.isPass ? AppTheme.greenPass : (chk.isFail ? AppTheme.redFail : AppTheme.slateGrey)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${chk.name}: ${chk.value} — ${chk.evidence}', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),
          const Text(
            'Rule Precedence: Net profit > 0 and OCF > 0 are gating. If either fails, evaluation terminates immediately without generating scores.',
            style: TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
