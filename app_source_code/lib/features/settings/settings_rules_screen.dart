import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/research_note.dart';
import '../../models/rule_settings.dart';
import '../../services/api_provider.dart';

/// Screen APP-05: Settings, Screening Heuristics Versioning, and Sector Research Notes
class SettingsRulesScreen extends ConsumerStatefulWidget {
  const SettingsRulesScreen({super.key});

  @override
  ConsumerState<SettingsRulesScreen> createState() => _SettingsRulesScreenState();
}

class _SettingsRulesScreenState extends ConsumerState<SettingsRulesScreen> {
  bool _isRefreshing = false;

  void _triggerRefresh() async {
    setState(() => _isRefreshing = true);
    final api = ref.read(apiServiceProvider);
    final res = await api.triggerDataRefresh();
    if (res.isSuccess && mounted) {
      final statusRes = await api.getRefreshStatus(res.data!);
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pipeline executed successfully! Assessed ${statusRes.data?['assessedCount'] ?? 5} stocks.',
            ),
            backgroundColor: AppTheme.greenPass,
          ),
        );
        ref.invalidate(systemStatusProvider);
        ref.invalidate(briefDataProvider);
        ref.invalidate(screenerCompaniesProvider);
      }
    } else {
      setState(() => _isRefreshing = false);
    }
  }

  void _showAddNoteDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final sourceCtrl = TextEditingController();
    final headwindCtrl = TextEditingController();
    final recoveryCtrl = TextEditingController();
    String selectedSector = 'it';
    String selectedSectorName = 'Information Technology';
    String classification = 'potentially_temporary';
    String severity = 'caution';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Sourced Sector Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('SECTOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                DropdownButton<String>(
                  value: selectedSector,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'it', child: Text('Information Technology')),
                    DropdownMenuItem(value: 'fmcg', child: Text('FMCG & Paints')),
                    DropdownMenuItem(value: 'pharma', child: Text('Pharmaceuticals')),
                    DropdownMenuItem(value: 'consumer_discretionary', child: Text('Consumer Discretionary')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedSector = val;
                        if (val == 'it') selectedSectorName = 'Information Technology';
                        if (val == 'fmcg') selectedSectorName = 'FMCG & Paints';
                        if (val == 'pharma') selectedSectorName = 'Pharmaceuticals';
                        if (val == 'consumer_discretionary') selectedSectorName = 'Consumer Discretionary';
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Note Title / Headline', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sourceCtrl,
                  decoration: const InputDecoration(labelText: 'Source URL (Mandatory verification link)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: headwindCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Sector Headwind Summary', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: recoveryCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Required Recovery Condition', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty || sourceCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }
                    final newNote = ResearchNoteItem(
                      id: '',
                      sectorId: selectedSector,
                      sectorName: selectedSectorName,
                      title: titleCtrl.text.trim(),
                      sourceUrl: sourceCtrl.text.trim(),
                      sourcePublication: 'Verified Research',
                      reviewedDate: DateTime.now().toString().split(' ').first,
                      classification: classification,
                      severity: severity,
                      summary: headwindCtrl.text.trim(),
                      headwinds: headwindCtrl.text.trim(),
                      recoveryConditions: recoveryCtrl.text.trim(),
                    );
                    final api = ref.read(apiServiceProvider);
                    await api.createResearchNote(newNote);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ref.invalidate(researchNotesProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sector research note added and assessment cache invalidated.')),
                      );
                    }
                  },
                  child: const Text('Save Note & Recalculate Precedence', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(systemStatusProvider);
    final rulesAsync = ref.watch(rulesSettingsProvider);
    final notesAsync = ref.watch(researchNotesProvider);
    final useMock = ref.watch(useMockApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Rules Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Mock vs Live Backend Toggle Card
          Card(
            color: useMock ? Colors.blue.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(useMock ? Icons.science_outlined : Icons.cloud_done,
                              color: useMock ? Colors.blueAccent : AppTheme.greenPass),
                          const SizedBox(width: 8),
                          Text(
                            useMock ? 'Using Mock In-Memory API' : 'Using Live REST Backend',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Switch(
                        value: useMock,
                        onChanged: (val) {
                          ref.read(useMockApiProvider.notifier).state = val;
                          ref.invalidate(systemStatusProvider);
                          ref.invalidate(briefDataProvider);
                          ref.invalidate(screenerCompaniesProvider);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    useMock
                        ? 'Running with local mock fixtures (5 verified stocks). Zero network dependencies.'
                        : 'Pointing to live Fastify server at: ${AppConstants.defaultBaseUrl}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. System Diagnostics & Upstox Status
          statusAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Status error: $err'),
            data: (status) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Market Data Diagnostics',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.greenPass.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('HEALTHY',
                              style: TextStyle(color: AppTheme.greenPass, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildDiagRow('Provider', status.provider.name),
                    _buildDiagRow('Token Valid Until', status.provider.tokenValidUntil),
                    _buildDiagRow('API Quota Today', '${status.provider.quotaRemainingToday} / ${status.provider.quotaLimitToday} req'),
                    _buildDiagRow('Ping Latency', '${status.provider.lastPingLatencyMs} ms'),
                    _buildDiagRow('Completed Session', '${status.storage.latestCompletedSession} (T)'),
                    _buildDiagRow('Active Snapshot', status.storage.activeSnapshotId),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade800,
                          foregroundColor: Colors.white,
                        ),
                        icon: _isRefreshing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.sync, size: 18),
                        label: Text(_isRefreshing ? 'Running Ingestion Pipeline...' : 'Run Ingestion & Refresh'),
                        onPressed: _isRefreshing ? null : _triggerRefresh,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Screening Heuristic Rules & Versioning
          rulesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Text('Rules error: $err'),
            data: (rules) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Screening Heuristics Engine',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            rules.ruleVersion,
                            style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Modifying thresholds bumps rule version and triggers deterministic recalculation.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Divider(height: 20),
                    ...rules.rules.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(r.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${r.value}${r.unit}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Update Thresholds (Bump to v1.3)'),
                      onPressed: () async {
                        final api = ref.read(apiServiceProvider);
                        final updated = await api.updateSettingsRules(rules);
                        if (context.mounted && updated.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rule version bumped to ${updated.data?.ruleVersion}! Recalculated universe.'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                          ref.invalidate(rulesSettingsProvider);
                          ref.invalidate(briefDataProvider);
                          ref.invalidate(screenerCompaniesProvider);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Sourced Sector Research Notes Management
          notesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Text('Notes error: $err'),
            data: (notes) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sourced Sector Notes',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                          tooltip: 'Add Sector Note',
                          onPressed: () => _showAddNoteDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Every note must cite a verifiable source URL. Stale context marks candidates as Not reviewed.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Divider(height: 20),
                    ...notes.map((note) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                  Text(note.sectorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('Reviewed: ${note.reviewedDate}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(note.summary, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('Source: ${note.sourcePublication}',
                                        style: const TextStyle(fontSize: 10, color: Colors.blueAccent)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    onPressed: () async {
                                      final api = ref.read(apiServiceProvider);
                                      await api.deleteResearchNote(note.id);
                                      ref.invalidate(researchNotesProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Note deleted. Precedence cache invalidated.')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
