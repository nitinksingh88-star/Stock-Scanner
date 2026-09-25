import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/analysis/company_analysis_screen.dart';
import 'features/brief/opportunity_brief_screen.dart';
import 'features/screener/explore_screener_screen.dart';
import 'features/settings/settings_rules_screen.dart';
import 'features/watchlist/watchlist_screen.dart';

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
  String _selectedIsin = 'INE467B01029'; // Default to TCS

  void _navigateToAnalysis(String isin) {
    setState(() {
      _selectedIsin = isin;
      _currentTabIndex = 1; // Switch to Analysis tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // Tab 0: APP-01 Opportunity Brief
          OpportunityBriefScreen(
            onSelectCompany: _navigateToAnalysis,
          ),

          // Tab 1: APP-02 Company Analysis Dossier
          CompanyAnalysisScreen(
            initialIsin: _selectedIsin,
            onBack: () => setState(() => _currentTabIndex = 0),
          ),

          // Tab 2: APP-03 Watchlist & Personal Notes
          WatchlistScreen(
            onSelectCompany: _navigateToAnalysis,
          ),

          // Tab 3: APP-04 Universe Screener & 3-Company Compare
          ExploreScreenerScreen(
            onSelectCompany: _navigateToAnalysis,
          ),

          // Tab 4: APP-05 Settings, System Diagnostics & Rules Engine
          const SettingsRulesScreen(),
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
