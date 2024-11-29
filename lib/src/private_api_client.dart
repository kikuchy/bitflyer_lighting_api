import 'dart:convert';
import 'package:bitflyer_lighting_api/src/exception.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class BitflyerPrivateApiClient {
  static const String _baseHost = 'api.bitflyer.com';
  static const String _basePath = '/v1';

  final String apiKey;
  final String apiSecret;
  final http.Client _httpClient;

  BitflyerPrivateApiClient({
    required this.apiKey,
    required this.apiSecret,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// 資産残高を取得
  Future<List<Balance>> getBalance() async {
    final response = await _get('/me/getbalance');
    return (response as List).map((json) => Balance.fromJson(json)).toList();
  }

  /// 証拠金の状態を取得
  Future<Collateral> getCollateral() async {
    final response = await _get('/me/getcollateral');
    return Collateral.fromJson(response);
  }

  /// 注文を出す
  Future<String> sendChildOrder({
    required String productCode,
    required String childOrderType,
    required String side,
    required double size,
    double? price,
    int? minuteToExpire,
    String? timeInForce,
  }) async {
    final response = await _post(
      '/me/sendchildorder',
      body: {
        'product_code': productCode,
        'child_order_type': childOrderType,
        'side': side,
        'size': size.toString(),
        if (price != null) 'price': price.toString(),
        if (minuteToExpire != null)
          'minute_to_expire': minuteToExpire.toString(),
        if (timeInForce != null) 'time_in_force': timeInForce,
      },
    );
    return response['child_order_acceptance_id'] as String;
  }

  /// 注文をキャンセル
  Future<void> cancelChildOrder({
    required String productCode,
    String? childOrderId,
    String? childOrderAcceptanceId,
  }) async {
    await _post(
      '/me/cancelchildorder',
      body: {
        'product_code': productCode,
        if (childOrderId != null) 'child_order_id': childOrderId,
        if (childOrderAcceptanceId != null)
          'child_order_acceptance_id': childOrderAcceptanceId,
      },
    );
  }

  /// 注文の一覧を取得
  Future<List<ChildOrder>> getChildOrders({
    required String productCode,
    String? childOrderState,
    int? count,
    int? before,
    int? after,
  }) async {
    final response = await _get(
      '/me/getchildorders',
      queryParameters: {
        'product_code': productCode,
        if (childOrderState != null) 'child_order_state': childOrderState,
        if (count != null) 'count': count.toString(),
        if (before != null) 'before': before.toString(),
        if (after != null) 'after': after.toString(),
      },
    );
    return (response as List).map((json) => ChildOrder.fromJson(json)).toList();
  }

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(_baseHost, '$_basePath$path', queryParameters);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final headers = _generateAuthHeaders('GET', path, timestamp);

    final response = await _httpClient.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.https(_baseHost, '$_basePath$path');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bodyString = body != null ? json.encode(body) : '';
    final headers = _generateAuthHeaders('POST', path, timestamp, bodyString);

    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: bodyString,
    );
    return _handleResponse(response);
  }

  Map<String, String> _generateAuthHeaders(
    String method,
    String path,
    String timestamp, [
    String body = '',
  ]) {
    final text = '$timestamp$method$_basePath$path$body';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final sign = hmac.convert(utf8.encode(text)).toString();

    return {
      'ACCESS-KEY': apiKey,
      'ACCESS-TIMESTAMP': timestamp,
      'ACCESS-SIGN': sign,
      'Content-Type': 'application/json',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw BitflyerApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    return json.decode(response.body);
  }

  void dispose() {
    _httpClient.close();
  }
}

/// 資産残高を表すクラス
class Balance {
  final String currencyCode;
  final double amount;
  final double available;

  Balance({
    required this.currencyCode,
    required this.amount,
    required this.available,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      currencyCode: json['currency_code'] as String,
      amount: json['amount'].toDouble(),
      available: json['available'].toDouble(),
    );
  }
}

/// 証拠金の状態を表すクラス
class Collateral {
  final double collateral;
  final double openPositionPnl;
  final double requireCollateral;
  final double keepRate;

  Collateral({
    required this.collateral,
    required this.openPositionPnl,
    required this.requireCollateral,
    required this.keepRate,
  });

  factory Collateral.fromJson(Map<String, dynamic> json) {
    return Collateral(
      collateral: json['collateral'].toDouble(),
      openPositionPnl: json['open_position_pnl'].toDouble(),
      requireCollateral: json['require_collateral'].toDouble(),
      keepRate: json['keep_rate'].toDouble(),
    );
  }
}

/// 注文情報を表すクラス
class ChildOrder {
  final int id;
  final String childOrderId;
  final String productCode;
  final String side;
  final String childOrderType;
  final double price;
  final double averagePrice;
  final double size;
  final String childOrderState;
  final DateTime expireDate;
  final DateTime childOrderDate;
  final String childOrderAcceptanceId;
  final double outstandingSize;
  final double cancelSize;
  final double executedSize;
  final double totalCommission;

  ChildOrder({
    required this.id,
    required this.childOrderId,
    required this.productCode,
    required this.side,
    required this.childOrderType,
    required this.price,
    required this.averagePrice,
    required this.size,
    required this.childOrderState,
    required this.expireDate,
    required this.childOrderDate,
    required this.childOrderAcceptanceId,
    required this.outstandingSize,
    required this.cancelSize,
    required this.executedSize,
    required this.totalCommission,
  });

  factory ChildOrder.fromJson(Map<String, dynamic> json) {
    return ChildOrder(
      id: json['id'] as int,
      childOrderId: json['child_order_id'] as String,
      productCode: json['product_code'] as String,
      side: json['side'] as String,
      childOrderType: json['child_order_type'] as String,
      price: json['price'].toDouble(),
      averagePrice: json['average_price'].toDouble(),
      size: json['size'].toDouble(),
      childOrderState: json['child_order_state'] as String,
      expireDate: DateTime.parse(json['expire_date'] as String),
      childOrderDate: DateTime.parse(json['child_order_date'] as String),
      childOrderAcceptanceId: json['child_order_acceptance_id'] as String,
      outstandingSize: json['outstanding_size'].toDouble(),
      cancelSize: json['cancel_size'].toDouble(),
      executedSize: json['executed_size'].toDouble(),
      totalCommission: json['total_commission'].toDouble(),
    );
  }
}
