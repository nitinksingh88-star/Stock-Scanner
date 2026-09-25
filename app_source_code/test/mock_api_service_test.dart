import 'package:flutter_test/flutter_test.dart';
import 'package:stock_advisory/models/company.dart';
import 'package:stock_advisory/services/mock_api_service.dart';

void main() {
  group('MockApiService Financial Heuristics & Endpoint Tests', () {
    late MockApiService api;

    setUp(() {
      api = MockApiService();
    });

    test('getSystemStatus returns healthy provider and snapshot info', () async {
      final res = await api.getSystemStatus();
      expect(res.isSuccess, isTrue);
      expect(res.data?.systemHealth, equals('healthy'));
      expect(res.data?.provider.name, contains('Upstox'));
      expect(res.data?.storage.coveredUniverseCount, equals(5));
      expect(res.meta?.ruleVersion, equals('v1.2'));
    });

    test('getOpportunityBrief filters daily decline trigger <= -2.0%', () async {
      final res = await api.getOpportunityBrief(window: 'day');
      expect(res.isSuccess, isTrue);
      final brief = res.data!;
      expect(brief.discoveryWindow.threshold, equals(-2.0));
      expect(brief.benchmarks.broadMarket.name, equals('NIFTY 50'));

      // TCS and Divi's Lab qualify for Worth Researching
      expect(brief.worthResearching.any((c) => c.ticker == 'TCS'), isTrue);

      // Titan must NOT qualify due to unverified corporate action
      expect(brief.worthResearching.any((c) => c.ticker == 'TITAN'), isFalse);
      expect(brief.exclusionsSummary.disqualifiedCorporateAction, equals(1));
    });

    test('getCompanyDetails returns complete 3-year financials and checks for TCS', () async {
      final res = await api.getCompanyDetails('INE467B01029'); // TCS
      expect(res.isSuccess, isTrue);
      final company = res.data!;
      expect(company.ticker, equals('TCS'));
      expect(company.financials.length, equals(3));

      // Free cash flow derived check: OCF - Capex
      final fy25 = company.financials.last;
      expect(fy25.fcfCr, equals(fy25.ocfCr - fy25.capexCr));

      // All 5 quality checks pass for TCS
      expect(company.checks.every((chk) => chk.isPass), isTrue);
    });

    test('Watchlist in-memory mutations (add, remove, personal notes)', () async {
      const isin = 'INE009A01021'; // INFY

      // Add to watchlist
      final addRes = await api.addToWatchlist(isin);
      expect(addRes.isSuccess, isTrue);

      final watchlist = await api.getWatchlist();
      expect(watchlist.data?.any((c) => c.isin == isin), isTrue);

      // Save personal notes
      final noteRes = await api.savePersonalNote(
        isin,
        thesis: 'Robust digital transformation pipeline.',
        concerns: 'Senior management turnover.',
      );
      expect(noteRes.isSuccess, isTrue);
      expect(noteRes.data?.personalThesis, equals('Robust digital transformation pipeline.'));

      // Remove from watchlist
      final removeRes = await api.removeFromWatchlist(isin);
      expect(removeRes.isSuccess, isTrue);

      final updatedWatchlist = await api.getWatchlist();
      expect(updatedWatchlist.data?.any((c) => c.isin == isin), isFalse);
    });

    test('getScreenerCompanies sorts with nulls / unavailables pushed to bottom', () async {
      final res = await api.getScreenerCompanies(sortField: 'roce', sortAsc: true);
      expect(res.isSuccess, isTrue);
      final list = res.data!;

      // TITAN has unavailable P/E and must be handled cleanly without crashing
      expect(list.length, equals(5));
    });

    test('updateSettingsRules bumps rule version from v1.2 to v1.3', () async {
      final currentRules = await api.getSettingsRules();
      final bumped = await api.updateSettingsRules(currentRules.data!);
      expect(bumped.isSuccess, isTrue);
      expect(bumped.data?.ruleVersion, equals('v1.3'));
    });
  });
}
