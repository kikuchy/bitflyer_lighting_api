import 'package:bitflyer_lighting_api/src/entities.dart';
import 'package:bitflyer_lighting_api/src/hidden_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitflyer_lighting_api/bitflyer_lighting_api.dart';

void main() {
  group("public api", () {
    test('markets', () async {
      final client = BitflyerPublicApiClient();
      final markets = await client.getMarkets();
      expect(markets.isNotEmpty, true);
    });

    test('board', () async {
      final client = BitflyerPublicApiClient();
      final board = await client.getBoard(productCode: 'BTC_JPY');
      expect(board.asks.isNotEmpty, true);
      expect(board.bids.isNotEmpty, true);
    });

    test('tickers', () async {
      final client = BitflyerPublicApiClient();
      final ticker = await client.getTicker(productCode: 'BTC_JPY');
      expect(ticker.state, BoardStateStatus.RUNNING);
    });

    test('executions', () async {
      final client = BitflyerPublicApiClient();
      final executions = await client.getExecutions(productCode: 'BTC_JPY');
      expect(executions.isNotEmpty, true);
    });

    test('board state', () async {
      final client = BitflyerPublicApiClient();
      final boardStatus = await client.getBoardState(productCode: 'BTC_JPY');
      expect(boardStatus.state, BoardStateStatus.RUNNING);
    });

    test('health', () async {
      final client = BitflyerPublicApiClient();
      final health = await client.getHealth(productCode: 'BTC_JPY');
      expect(health.status, HealthStatus.NORMAL);
    });

    test('funding rate', () async {
      final client = BitflyerPublicApiClient();
      final fundingRate =
          await client.getFundingRate(productCode: 'FX_BTC_JPY');
      expect(fundingRate.currentFundingRate, isNonZero);
    });

    test('corporate leverage', () async {
      final client = BitflyerPublicApiClient();
      final leverage = await client.getCorporateLeverage();
      expect(leverage.currentMax, isPositive);
    });

    test('chats', () async {
      final client = BitflyerPublicApiClient();
      final chats = await client.getChats();
      expect(chats.isNotEmpty, true);
    });
  });

  group('hidden api', () {
    test('ohlcv', () async {
      final client = BitflyerHiddenApiClient();
      final ohlcv = await client.getOhlcv(
        symbol: 'FX_BTC_JPY',
        period: Period.minute,
        before: DateTime.now(),
      );
      expect(ohlcv.isNotEmpty, true);
    });
  });
}
