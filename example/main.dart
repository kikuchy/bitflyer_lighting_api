import 'dart:io';

import 'package:bitflyer_lighting_api/bitflyer_lighting_api.dart';

void main() async {
  final publicApiClient = BitflyerPublicApiClient();
  final boardState =
      await publicApiClient.getBoardState(productCode: 'FX_BTC_JPY');
  print(boardState.state);

  final privateApiClient = BitflyerPrivateApiClient(
    apiKey: Platform.environment["BITFLYER_API_KEY"]!,
    apiSecret: Platform.environment["BITFLYER_API_SECRET"]!,
  );
  final balance = await privateApiClient.getBalance();
  print(balance.first.amount);

  final client = RealtimeApiClient();
  client.boardSnapshot(productCode: 'FX_BTC_JPY').listen((event) {
    print('--------------------------------');
    print(event.midPrice);
    print(event.bids.first.price);
    print(event.asks.first.price);
  });
}
