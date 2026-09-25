import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/company.dart';
import '../../models/compare_result.dart';
import '../../services/api_provider.dart';

/// Screen APP-04: Universe Screener with Multi-Factor Sorting & 3-Company Comparison
class ExploreScreenerScreen extends ConsumerStatefulWidget {
  final Function(String isin)? onSelectCompany;

  const ExploreScreenerScreen({super.key, this.onSelectCompany});

  @override
  ConsumerState<ExploreScreenerScreen> createState() => _ExploreScreenerScreenState();
}

class _ExploreScreenerScreenState extends ConsumerState<ExploreScreenerScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _showCompareModal(BuildContext context, List<String> isins) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CompareBottomSheet(selectedIsins: isins),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenerAsync = ref.watch(screenerCompaniesProvider);
    final selectedIsins = ref.watch(compareSelectedIsinsProvider);
    final activeSector = ref.watch(screenerSectorFilterProvider);
    final activeConclusion = ref.watch(screenerConclusionFilterProvider);
    final sortField = ref.watch(screenerSortFieldProvider);
    final sortAsc = ref.watch(screenerSortAscProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universe Screener', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(screenerCompaniesProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ticker, name, or ISIN...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(screenerSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) {
                ref.read(screenerSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // 2. Sector Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('All Sectors', activeSector == null, () {
                  ref.read(screenerSectorFilterProvider.notifier).state = null;
                }),
                const SizedBox(width: 6),
                _buildFilterChip('IT', activeSector == 'it', () {
                  ref.read(screenerSectorFilterProvider.notifier).state = 'it';
                }),
                const SizedBox(width: 6),
                _buildFilterChip('FMCG', activeSector == 'fmcg', () {
                  ref.read(screenerSectorFilterProvider.notifier).state = 'fmcg';
                }),
                const SizedBox(width: 6),
                _buildFilterChip('Pharma', activeSector == 'pharma', () {
                  ref.read(screenerSectorFilterProvider.notifier).state = 'pharma';
                }),
                const SizedBox(width: 6),
                _buildFilterChip('Discretionary', activeSector == 'consumer_discretionary', () {
                  ref.read(screenerSectorFilterProvider.notifier).state = 'consumer_discretionary';
                }),
              ],
            ),
          ),

          // 3. Sorting & Conclusion Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Conclusion filter
                DropdownButton<String?>(
                  value: activeConclusion,
                  hint: const Text('All Conclusions', style: TextStyle(fontSize: 12)),
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Conclusions', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Worth researching', child: Text('Worth researching', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Watch and wait', child: Text('Watch and wait', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Fundamental concerns', child: Text('Fundamental concerns', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Insufficient evidence', child: Text('Insufficient evidence', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    ref.read(screenerConclusionFilterProvider.notifier).state = val;
                  },
                ),

                // Sort Dropdown
                Row(
                  children: [
                    const Text('Sort:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 4),
                    DropdownButton<String?>(
                      value: sortField,
                      hint: const Text('Default', style: TextStyle(fontSize: 12)),
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Default', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ticker', child: Text('Ticker A-Z', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'change', child: Text('Decline %', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'roce', child: Text('ROCE (nulls last)', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        ref.read(screenerSortFieldProvider.notifier).state = val;
                      },
                    ),
                    IconButton(
                      icon: Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                      onPressed: () {
                        ref.read(screenerSortAscProvider.notifier).state = !sortAsc;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 4. Results List
          Expanded(
            child: screenerAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (companies) {
                if (companies.isEmpty) {
                  return const Center(child: Text('No companies match the selected filters.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: companies.length,
                  itemBuilder: (ctx, idx) {
                    final comp = companies[idx];
                    final isSelected = selectedIsins.contains(comp.isin);

                    Color badgeColor;
                    if (comp.isWorthResearching) {
                      badgeColor = AppTheme.greenPass;
                    } else if (comp.isWatchAndWait) {
                      badgeColor = AppTheme.amberWatch;
                    } else if (comp.isFundamentalConcerns) {
                      badgeColor = AppTheme.redFail;
                    } else {
                      badgeColor = AppTheme.slateGrey;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isSelected ? const BorderSide(color: Colors.blueAccent, width: 2) : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => widget.onSelectCompany?.call(comp.isin),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Selection checkbox for comparison (up to 3)
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      final current = List<String>.from(selectedIsins);
                                      if (val == true) {
                                        if (current.length >= 3) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Maximum 3 companies can be compared simultaneously.'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        current.add(comp.isin);
                                      } else {
                                        current.remove(comp.isin);
                                      }
                                      ref.read(compareSelectedIsinsProvider.notifier).state = current;
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(comp.ticker,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(width: 6),
                                            Text(comp.sectorName,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                        Text(comp.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('₹${comp.currentPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(
                                        '${comp.dailyChangePercent >= 0 ? "+" : ""}${comp.dailyChangePercent.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: comp.dailyChangePercent < 0 ? AppTheme.redFail : AppTheme.greenPass,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      comp.conclusion,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('ROCE: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        comp.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                  },
                );
              },
            ),
          ),

          // 5. Compare Sticky Action Bar (visible when at least 2 selected)
          if (selectedIsins.length >= 2)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade900,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedIsins.length}/3 selected for comparison',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                      ),
                      onPressed: () => _showCompareModal(context, selectedIsins),
                      child: const Text('Compare Side-by-Side', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      showCheckmark: false,
      padding: EdgeInsets.zero,
      onSelected: (_) => onSelected(),
    );
  }
}

/// Slide-up Side-by-Side Comparison Bottom Sheet
class _CompareBottomSheet extends ConsumerWidget {
  final List<String> selectedIsins;

  const _CompareBottomSheet({required this.selectedIsins});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareAsync = ref.watch(comparisonResultProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Side-by-Side Comparison', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: compareAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading comparison: $err')),
              data: (data) {
                if (data.companies.isEmpty) {
                  return const Center(child: Text('Select 2 or 3 companies to view side-by-side metrics.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Cross-Sector Warning Alert
                    if (data.crossSectorWarning != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data.crossSectorWarning!,
                                style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Side-by-side company headers
                    Row(
                      children: [
                        const SizedBox(width: 140, child: Text('Metric', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
                        ...data.companies.map((c) => Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.ticker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(c.sectorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            )),
                      ],
                    ),
                    const Divider(height: 20),

                    // Metrics Rows
                    ...data.rows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(row.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                            ...data.companies.map((c) {
                              final val = row.valuesByIsin[c.isin] ?? '—';
                              final status = row.statusByIsin[c.isin];
                              Color textColor = Colors.black87;
                              if (status == true) textColor = AppTheme.greenPass;
                              if (status == false) textColor = AppTheme.redFail;

                              return Expanded(
                                child: Text(
                                  val,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: status != null ? FontWeight.bold : FontWeight.normal,
                                    color: textColor,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
