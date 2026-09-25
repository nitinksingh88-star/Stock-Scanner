import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/company.dart';
import '../../mock/mock_data.dart';

/// Screen APP-01: Opportunity Brief (Home Screen)
class OpportunityBriefScreen extends StatefulWidget {
  final Function(String isin)? onSelectCompany;

  const OpportunityBriefScreen({super.key, this.onSelectCompany});

  @override
  State<OpportunityBriefScreen> createState() => _OpportunityBriefScreenState();
}

class _OpportunityBriefScreenState extends State<OpportunityBriefScreen> {
  String _selectedWindow = 'day'; // 'day' or 'month'
  late List<Company> _companies;

  @override
  void initState() {
    super.initState();
    _companies = MockStockData.coveredUniverse;
  }

  void _toggleWatchlist(Company comp) {
    setState(() {
      comp.isSavedInWatchlist = !comp.isSavedInWatchlist;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${comp.ticker} ${comp.isSavedInWatchlist ? 'added to' : 'removed from'} watchlist'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEvidenceSheet(Company comp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EvidenceBottomSheet(company: comp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worthCandidates = _companies.where((c) => c.isWorthResearching).toList();
    final watchCandidates = _companies.where((c) => c.isWatchAndWait).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Opportunity Brief', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing completed trading session snapshot...')),
              );
            },
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
      body: ListView(
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
                      isSelected: _selectedWindow == 'day',
                      onTap: () => setState(() => _selectedWindow = 'day'),
                    ),
                    _WindowChip(
                      label: '1-Mo (≤ -8%)',
                      isSelected: _selectedWindow == 'month',
                      onTap: () => setState(() => _selectedWindow = 'month'),
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
              children: const [
                _BenchmarkCard(type: 'BROAD MARKET', name: 'NIFTY 50', change: '-1.35%'),
                _BenchmarkCard(type: 'SECTOR PROXY', name: 'IT Proxy (5 stocks)', change: '-2.40%', isProxy: true),
                _BenchmarkCard(type: 'SECTOR INDEX', name: 'Nifty FMCG', change: '-1.10%'),
                _BenchmarkCard(type: 'SECTOR INDEX', name: 'Healthcare', change: '-0.75%'),
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

          ...worthCandidates.map((comp) => _CandidateCard(
            company: comp,
            selectedWindow: _selectedWindow,
            onEvidenceTap: () => _showEvidenceSheet(comp),
            onWatchlistTap: () => _toggleWatchlist(comp),
            onCardTap: () => widget.onSelectCompany?.call(comp.isin),
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
            selectedWindow: _selectedWindow,
            onEvidenceTap: () => _showEvidenceSheet(comp),
            onWatchlistTap: () => _toggleWatchlist(comp),
            onCardTap: () => widget.onSelectCompany?.call(comp.isin),
          )),

          const SizedBox(height: 12),

          // 5. Exclusions Notice Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: const Text(
              'Exclusions Audit: 1 failed valuation (Asian Paints P/E 46.5x vs 41.2x), and 1 disqualified for unverified corporate action (Titan bonus issue).',
              style: TextStyle(fontSize: 11, color: Colors.black82),
            ),
          ),
        ],
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
              Text(type, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
              if (isProxy) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.amberWarnBg, borderRadius: BorderRadius.circular(3)),
                  child: const Text('PROXY', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppTheme.amberWarn)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(change, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.redFail)),
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
    final change = selectedWindow == 'day' ? company.dailyChangePercent : company.monthlyChangePercent;
    final pe = company.checks.firstWhere((x) => x.id == 'valuation_pe', orElse: () => const QualityCheck(id: '', name: '', status: '', value: 'N/A', rule: '', evidence: '', period: ''));
    final roce = company.checks.firstWhere((x) => x.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: '', value: 'N/A', rule: '', evidence: '', period: ''));
    final de = company.checks.firstWhere((x) => x.id == 'debt_equity', orElse: () => const QualityCheck(id: '', name: '', status: '', value: 'N/A', rule: '', evidence: '', period: ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name, Ticker, Price & Decline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(company.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                              child: Text(company.ticker, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Text(company.sectorName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${company.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('${change.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.redFail)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Metrics Row
              Row(
                children: [
                  _MetricPill(label: 'P/E vs SEC', value: pe.value, isPass: pe.isPass),
                  const SizedBox(width: 6),
                  _MetricPill(label: 'ROCE', value: roce.value, isPass: roce.isPass),
                  const SizedBox(width: 6),
                  _MetricPill(label: 'DEBT/EQ', value: de.value, isPass: de.isPass),
                ],
              ),
              const SizedBox(height: 10),

              // Trigger Statement
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: const Border(left: BorderSide(color: AppTheme.blueInfo, width: 3)),
                ),
                child: Text(company.triggerSummary, style: const TextStyle(fontSize: 11, color: Colors.black87)),
              ),
              const SizedBox(height: 10),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onCardTap,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    child: const Text('View Dossier →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: onEvidenceTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(60, 30),
                        ),
                        child: const Text('Evidence', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: onWatchlistTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(60, 30),
                          backgroundColor: company.isSavedInWatchlist ? Colors.grey.shade800 : AppTheme.blueInfo,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(company.isSavedInWatchlist ? '✓ Saved' : '+ Watch', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
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

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isPass;

  const _MetricPill({required this.label, required this.value, required this.isPass});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 1),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPass ? AppTheme.greenPass : AppTheme.redFail)),
          ],
        ),
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Text('${company.name} (${company.ticker})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('ISIN: ${company.isin}  •  Status: ${company.conclusion}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: [
                ...company.checks.map((k) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(k.status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: k.isPass ? AppTheme.greenPass : AppTheme.redFail)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Rule: ${k.rule}  •  Value: ${k.value}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(k.evidence, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
