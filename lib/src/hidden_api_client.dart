import 'dart:convert';

import 'package:bitflyer_lighting_api/bitflyer_lighting_api.dart';
import 'package:http/http.dart' as http;

class BitflyerHiddenApiClient {
  static const _baseHost = 'lightchart.bitflyer.com';
  static const _basePath = '/api';
  final http.Client _httpClient;

  BitflyerHiddenApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Ohlcv>> getOhlcv({
    required String symbol,
    required Period period,
    DateTime? before,
  }) async {
    final response = await _get('/ohlc', queryParameters: {
      'symbol': symbol,
      'period': switch (period) {
        Period.minute => 'm',
        Period.hour => 'h',
        Period.day => 'd',
      },
      if (before != null) 'before': before.millisecondsSinceEpoch.toString(),
    });
    return (response as List).map((json) => Ohlcv.fromJson(json)).toList();
  }

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(
      _baseHost,
      '$_basePath$path',
      queryParameters,
    );

    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw BitflyerApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    return json.decode(response.body);
  }
}

enum Period {
  minute,
  hour,
  day,
}

class Ohlcv {
  final int open;
  final int high;
  final int low;
  final int close;
  final double volume;
  final double dayVolume;
  final DateTime timestamp;

  Ohlcv.fromJson(List<dynamic> json)
      : open = json[1],
        high = json[2],
        low = json[3],
        close = json[4],
        volume = json[5],
        dayVolume = json[6],
        timestamp = DateTime.fromMillisecondsSinceEpoch(json[0]);

    @override
  String toString() {
    return 'Ohlcv(open: $open, high: $high, low: $low, close: $close, volume: $volume, dayVolume: $dayVolume, timestamp: $timestamp)';
  }
}
