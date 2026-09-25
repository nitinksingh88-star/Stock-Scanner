import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/company.dart';
import '../../services/api_provider.dart';

/// Screen APP-02: Company Analysis & Deep Dive Dossier
class CompanyAnalysisScreen extends ConsumerStatefulWidget {
  final String? initialIsin;
  final VoidCallback? onBack;

  const CompanyAnalysisScreen({
    super.key,
    this.initialIsin,
    this.onBack,
  });

  @override
  ConsumerState<CompanyAnalysisScreen> createState() => _CompanyAnalysisScreenState();
}

class _CompanyAnalysisScreenState extends ConsumerState<CompanyAnalysisScreen> {
  late String _activeIsin;

  @override
  void initState() {
    super.initState();
    _activeIsin = widget.initialIsin ?? 'INE467B01029'; // Default to TCS if none specified
  }

  @override
  void didUpdateWidget(covariant CompanyAnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsin != null && widget.initialIsin != _activeIsin) {
      setState(() {
        _activeIsin = widget.initialIsin!;
      });
    }
  }

  void _showPersonalNotesEditor(BuildContext context, Company company) {
    final thesisController = TextEditingController(text: company.personalThesis);
    final concernsController = TextEditingController(text: company.personalConcerns);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                  Text('Thesis & Notes: ${company.ticker}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('INVESTMENT THESIS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: thesisController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Why is this business high quality? (e.g. 48% ROCE, high cash conversion...)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              const Text('SPECIFIC CONCERNS & HEADWINDS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: concernsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What could break the thesis? (e.g. deal slowdown, margin compression...)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await ref.read(watchlistProvider.notifier).savePersonalNote(
                          company.isin,
                          thesis: thesisController.text.trim(),
                          concerns: concernsController.text.trim(),
                        );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Personal notes saved successfully')),
                      );
                      ref.invalidate(companyDetailProvider(_activeIsin));
                    }
                  },
                  child: const Text('Save Notes & Audit Trace', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyDetailProvider(_activeIsin));

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Company Analysis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        actions: [
          companyAsync.maybeWhen(
            data: (company) => IconButton(
              icon: Icon(
                company.isSavedInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: company.isSavedInWatchlist ? Colors.amber.shade800 : null,
              ),
              tooltip: company.isSavedInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
              onPressed: () async {
                await ref.read(watchlistProvider.notifier).toggleWatchlist(company);
                ref.invalidate(companyDetailProvider(_activeIsin));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        company.isSavedInWatchlist
                            ? '${company.ticker} removed from Watchlist'
                            : '${company.ticker} saved to Watchlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(companyDetailProvider(_activeIsin)),
          ),
        ],
      ),
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Error loading company: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(companyDetailProvider(_activeIsin)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (company) => _buildDossier(context, company),
      ),
    );
  }

  Widget _buildDossier(BuildContext context, Company c) {
    Color conclusionColor;
    if (c.isWorthResearching) {
      conclusionColor = AppTheme.greenPass;
    } else if (c.isWatchAndWait) {
      conclusionColor = AppTheme.amberWatch;
    } else if (c.isFundamentalConcerns) {
      conclusionColor = AppTheme.redFail;
    } else {
      conclusionColor = AppTheme.slateGrey;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Corporate Action Warning (if any)
        if (c.hasCorporateActionDistortion)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISQUALIFIED: Corporate Action Distortion',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.corporateActionStatus,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // 2. Company Identity Header Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            Text(c.ticker, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c.sectorName, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                            ),
                          ],
                        ),
                        Text(c.name, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${c.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${c.dailyChangePercent >= 0 ? "+" : ""}${c.dailyChangePercent.toStringAsFixed(2)}% today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: c.dailyChangePercent < 0 ? AppTheme.redFail : AppTheme.greenPass,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: conclusionColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: conclusionColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        c.conclusion.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: conclusionColor),
                      ),
                    ),
                    Text('ISIN: ${c.isin}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    c.triggerSummary,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Section: 3-Year Consolidated Financial Statements Table
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('3-Year Financial Statements',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Consolidated • ₹ Cr',
                          style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
                    headingRowHeight: 32,
                    dataRowMinHeight: 32,
                    dataRowMaxHeight: 36,
                    columns: const [
                      DataColumn(label: Text('Line Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      DataColumn(label: Text('FY23', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      DataColumn(label: Text('FY24', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      DataColumn(label: Text('FY25', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Revenue', style: TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.isNotEmpty ? '₹${c.financials[0].revenueCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 1 ? '₹${c.financials[1].revenueCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 2 ? '₹${c.financials[2].revenueCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Net Profit (PAT)', style: TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.isNotEmpty ? '₹${c.financials[0].netProfitCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 1 ? '₹${c.financials[1].netProfitCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 2 ? '₹${c.financials[2].netProfitCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Operating Cash Flow', style: TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.isNotEmpty ? '₹${c.financials[0].ocfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 1 ? '₹${c.financials[1].ocfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 2 ? '₹${c.financials[2].ocfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Capital Expenditure', style: TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.isNotEmpty ? '₹${c.financials[0].capexCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 1 ? '₹${c.financials[1].capexCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c.financials.length > 2 ? '₹${c.financials[2].capexCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12))),
                      ]),
                      DataRow(
                        color: MaterialStateProperty.all(Colors.blue.shade50.withOpacity(0.5)),
                        cells: [
                          const DataCell(Row(
                            children: [
                              Text('Free Cash Flow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.blueAccent)),
                            ],
                          )),
                          DataCell(Text(c.financials.isNotEmpty ? '₹${c.financials[0].fcfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DataCell(Text(c.financials.length > 1 ? '₹${c.financials[1].fcfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DataCell(Text(c.financials.length > 2 ? '₹${c.financials[2].fcfCr.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '* Free Cash Flow is explicitly derived as (Operating Cash Flow - Capital Expenditure).',
                  style: TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 4. Section: 5 Quality Checks Audit Table
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quality Rules & Precedence Audit',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Deterministic checks applied in order. Non-positive PAT or OCF terminates candidate.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...c.checks.map((chk) {
                  Color badgeColor;
                  IconData icon;
                  if (chk.isPass) {
                    badgeColor = AppTheme.greenPass;
                    icon = Icons.check_circle;
                  } else if (chk.isFail) {
                    badgeColor = AppTheme.redFail;
                    icon = Icons.cancel;
                  } else {
                    badgeColor = AppTheme.slateGrey;
                    icon = Icons.help_outline;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 16, color: badgeColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(chk.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(chk.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: badgeColor)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Rule: ${chk.rule}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text('Evidence: ${chk.evidence}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 5. Section: Sourced Sector Context Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sourced Sector Context',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.sectorContext.classification.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.sectorContext.noteTitle,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Reviewed: ${c.sectorContext.reviewedDate}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Divider(height: 16),
                const Text('SECTOR HEADWIND:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(c.sectorContext.headwind, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('REQUIRED RECOVERY CONDITION:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(c.sectorContext.recoveryCondition,
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening source: ${c.sectorContext.sourceUrl}')),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 14, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.sectorContext.sourceUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.blueAccent, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 6. Section: Next Verification Checks
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Verification Checks',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...c.nextChecks.map((t) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: t.done,
                      title: Text(t.task, style: TextStyle(fontSize: 12, decoration: t.done ? TextDecoration.lineThrough : null)),
                      subtitle: Text('Target: ${t.targetDate}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      onChanged: (val) {
                        setState(() {
                          t.done = val ?? false;
                        });
                      },
                    )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 7. Personal Thesis & Notes Card
        Card(
          color: Colors.blue.shade50.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Investment Thesis & Notes',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                      onPressed: () => _showPersonalNotesEditor(context, c),
                    ),
                  ],
                ),
                if (c.personalThesis.isNotEmpty) ...[
                  const Text('THESIS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text(c.personalThesis, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 8),
                ],
                if (c.personalConcerns.isNotEmpty) ...[
                  const Text('KEY CONCERNS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text(c.personalConcerns, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 8),
                ],
                if (c.personalThesis.isEmpty && c.personalConcerns.isEmpty)
                  const Text(
                    'No personal thesis added yet. Tap edit to record your fundamental conviction and risk limits.',
                    style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
