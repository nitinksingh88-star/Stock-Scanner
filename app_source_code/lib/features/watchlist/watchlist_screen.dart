import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/company.dart';
import '../../services/api_provider.dart';

/// Screen APP-03: Persistent Watchlist & Personal Investment Notes
class WatchlistScreen extends ConsumerWidget {
  final Function(String isin)? onSelectCompany;

  const WatchlistScreen({super.key, this.onSelectCompany});

  void _showNotesEditor(BuildContext context, WidgetRef ref, Company company) {
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
                  hintText: 'Core investment thesis and moat validation...',
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
                  hintText: 'Near-term risks and triggers for thesis invalidation...',
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
                        const SnackBar(content: Text('Notes updated')),
                      );
                    }
                  },
                  child: const Text('Save Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
          ),
        ],
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Error loading watchlist: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (savedCompanies) {
          if (savedCompanies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Watchlist is Empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save companies from the Opportunity Brief or Universe Screener to track personal thesis and review triggers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: savedCompanies.length,
              itemBuilder: (context, index) {
                final company = savedCompanies[index];
                Color badgeColor;
                if (company.isWorthResearching) {
                  badgeColor = AppTheme.greenPass;
                } else if (company.isWatchAndWait) {
                  badgeColor = AppTheme.amberWatch;
                } else if (company.isFundamentalConcerns) {
                  badgeColor = AppTheme.redFail;
                } else {
                  badgeColor = AppTheme.slateGrey;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelectCompany?.call(company.isin),
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
                                      Text(company.ticker,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(company.sectorName,
                                            style: const TextStyle(fontSize: 10, color: Colors.black87)),
                                      ),
                                    ],
                                  ),
                                  Text(company.name, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${company.currentPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(
                                    '${company.dailyChangePercent >= 0 ? "+" : ""}${company.dailyChangePercent.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: company.dailyChangePercent < 0 ? AppTheme.redFail : AppTheme.greenPass,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  company.conclusion,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_note, size: 22, color: Colors.blueAccent),
                                    tooltip: 'Edit Notes',
                                    onPressed: () => _showNotesEditor(context, ref, company),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark_remove, size: 20, color: Colors.grey),
                                    tooltip: 'Remove',
                                    onPressed: () => ref.read(watchlistProvider.notifier).toggleWatchlist(company),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (company.personalThesis.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('MY THESIS:',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                  const SizedBox(height: 2),
                                  Text(company.personalThesis, style: const TextStyle(fontSize: 12)),
                                  if (company.personalConcerns.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    const Text('CONCERNS:',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    const SizedBox(height: 2),
                                    Text(company.personalConcerns, style: const TextStyle(fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
