import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/brief/opportunity_brief_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: StockAdvisoryApp(),
    ),
  );
}

class StockAdvisoryApp extends StatelessWidget {
  const StockAdvisoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Advisory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.minimalLight,
      darkTheme: AppTheme.darkInstitutional,
      themeMode: ThemeMode.light,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentTabIndex = 0;
  String? _selectedIsin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          OpportunityBriefScreen(
            onSelectCompany: (isin) {
              setState(() {
                _selectedIsin = isin;
                _currentTabIndex = 1; // Switch to Analysis tab
              });
            },
          ),
          _PlaceholderScreen(title: 'Company Analysis (APP-02)', isin: _selectedIsin),
          const _PlaceholderScreen(title: 'Watchlist & Notes (APP-03)'),
          const _PlaceholderScreen(title: 'Universe Explore (APP-04)'),
          const _PlaceholderScreen(title: 'Settings & Rules (APP-05)'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Brief',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? isin;

  const _PlaceholderScreen({required this.title, this.isin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mobile_friendly, size: 64, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (isin != null) ...[
                const SizedBox(height: 8),
                Text('Active Company ISIN: $isin', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
              const SizedBox(height: 12),
              const Text(
                'Refer to AGENTS.md and ../mockup_by_agy/mobile/DEVELOPER_GUIDE.md to implement full widget tree.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
