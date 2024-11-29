import 'dart:convert';
import 'package:bitflyer_lighting_api/src/exception.dart';
import 'package:http/http.dart' as http;

class BitflyerPublicApiClient {
  static const String _baseHost = 'api.bitflyer.com';
  static const String _basePath = '/v1';
  final http.Client _httpClient;

  BitflyerPublicApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// マーケット一覧を取得
  Future<List<Market>> getMarkets() async {
    final response = await _get('/getmarkets');
    return (response as List).map((json) => Market.fromJson(json)).toList();
  }

  /// 板情報を取得
  Future<Board> getBoard({required String productCode}) async {
    final response = await _get(
      '/getboard',
      queryParameters: {'product_code': productCode},
    );
    return Board.fromJson(response);
  }

  /// ティッカー情報を取得
  Future<Ticker> getTicker({required String productCode}) async {
    final response = await _get(
      '/getticker',
      queryParameters: {'product_code': productCode},
    );
    return Ticker.fromJson(response);
  }

  /// 約定履歴を取
  Future<List<Execution>> getExecutions({
    required String productCode,
    int? count,
    int? before,
    int? after,
  }) async {
    final response = await _get(
      '/getexecutions',
      queryParameters: {
        'product_code': productCode,
        if (count != null) 'count': count.toString(),
        if (before != null) 'before': before.toString(),
        if (after != null) 'after': after.toString(),
      },
    );
    return (response as List).map((json) => Execution.fromJson(json)).toList();
  }

  /// 板の状態を取得
  Future<BoardState> getBoardState({required String productCode}) async {
    final response = await _get(
      '/getboardstate',
      queryParameters: {'product_code': productCode},
    );
    return BoardState.fromJson(response);
  }

  /// 取引所の状態を取得
  Future<Health> getHealth({required String productCode}) async {
    final response = await _get(
      '/gethealth',
      queryParameters: {'product_code': productCode},
    );
    return Health.fromJson(response);
  }

  Future<FundingRate> getFundingRate({required String productCode}) async {
    final response = await _get(
      '/getfundingrate',
      queryParameters: {'product_code': productCode},
    );
    return FundingRate.fromJson(response);
  }

  Future<CorporateLeverage> getCorporateLeverage() async {
    final response = await _get('/getcorporateleverage');
    return CorporateLeverage.fromJson(response);
  }

  /// チャットの履歴を取得
  Future<List<Chat>> getChats({DateTime? fromDate}) async {
    final response = await _get(
      '/getchats',
      queryParameters:
          fromDate != null ? {'from_date': fromDate.toIso8601String()} : null,
    );
    return (response as List).map((json) => Chat.fromJson(json)).toList();
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

  void dispose() {
    _httpClient.close();
  }
}

/// マーケット情報を表すクラス
class Market {
  final String productCode;
  final String marketType;

  Market({
    required this.productCode,
    required this.marketType,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      productCode: json['product_code'] as String,
      marketType: json['market_type'] as String,
    );
  }
}

/// 板情報を表すクラス
class Board {
  final double midPrice;
  final List<BoardOrder> bids;
  final List<BoardOrder> asks;

  Board({
    required this.midPrice,
    required this.bids,
    required this.asks,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      midPrice: json['mid_price'].toDouble(),
      bids: (json['bids'] as List).map((e) => BoardOrder.fromJson(e)).toList(),
      asks: (json['asks'] as List).map((e) => BoardOrder.fromJson(e)).toList(),
    );
  }
}

/// 板の注文情報を表すクラス
class BoardOrder {
  final double price;
  final double size;

  BoardOrder({
    required this.price,
    required this.size,
  });

  factory BoardOrder.fromJson(Map<String, dynamic> json) {
    return BoardOrder(
      price: json['price'].toDouble(),
      size: json['size'].toDouble(),
    );
  }
}

/// ティッカー情報を表すクラス
class Ticker {
  final String productCode;
  final BoardStateStatus state;
  final DateTime timestamp;
  final int tickId;
  final double bestBid;
  final double bestAsk;
  final double bestBidSize;
  final double bestAskSize;
  final double totalBidDepth;
  final double totalAskDepth;
  final double marketBidSize;
  final double marketAskSize;
  final double ltp;
  final double volume;
  final double volumeByProduct;

  Ticker({
    required this.productCode,
    required this.state,
    required this.timestamp,
    required this.tickId,
    required this.bestBid,
    required this.bestAsk,
    required this.bestBidSize,
    required this.bestAskSize,
    required this.totalBidDepth,
    required this.totalAskDepth,
    required this.marketBidSize,
    required this.marketAskSize,
    required this.ltp,
    required this.volume,
    required this.volumeByProduct,
  });

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      productCode: json['product_code'] as String,
      state: BoardStateStatus.fromString(json['state'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      tickId: json['tick_id'] as int,
      bestBid: json['best_bid'].toDouble(),
      bestAsk: json['best_ask'].toDouble(),
      bestBidSize: json['best_bid_size'].toDouble(),
      bestAskSize: json['best_ask_size'].toDouble(),
      totalBidDepth: json['total_bid_depth'].toDouble(),
      totalAskDepth: json['total_ask_depth'].toDouble(),
      marketBidSize: json['market_bid_size'].toDouble(),
      marketAskSize: json['market_ask_size'].toDouble(),
      ltp: json['ltp'].toDouble(),
      volume: json['volume'].toDouble(),
      volumeByProduct: json['volume_by_product'].toDouble(),
    );
  }
}

/// 約定履歴を表すクラス
class Execution {
  final int id;
  final String side;
  final double price;
  final double size;
  final DateTime execDate;
  final String buyChildOrderAcceptanceId;
  final String sellChildOrderAcceptanceId;

  Execution({
    required this.id,
    required this.side,
    required this.price,
    required this.size,
    required this.execDate,
    required this.buyChildOrderAcceptanceId,
    required this.sellChildOrderAcceptanceId,
  });

  factory Execution.fromJson(Map<String, dynamic> json) {
    return Execution(
      id: json['id'] as int,
      side: json['side'] as String,
      price: json['price'].toDouble(),
      size: json['size'].toDouble(),
      execDate: DateTime.parse(json['exec_date'] as String),
      buyChildOrderAcceptanceId:
          json['buy_child_order_acceptance_id'] as String,
      sellChildOrderAcceptanceId:
          json['sell_child_order_acceptance_id'] as String,
    );
  }
}

/// 板の状態を表すenum
enum BoardStateStatus {
  RUNNING,
  CLOSED,
  STARTING,
  PREOPEN,
  CIRCUIT_BREAK,
  AWAITING_SQ,
  MATURED;

  factory BoardStateStatus.fromString(String value) {
    // CIRCUIT BREAKはスペースを含むため、特別な処理が必要
    if (value == 'CIRCUIT BREAK') {
      return BoardStateStatus.CIRCUIT_BREAK;
    }
    return BoardStateStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw ArgumentError('Invalid board state status: $value'),
    );
  }
}

/// 板の状態を表すクラス
class BoardState {
  final HealthStatus health;
  final BoardStateStatus state;
  final Map<String, dynamic>? data;

  BoardState({
    required this.health,
    required this.state,
    this.data,
  });

  factory BoardState.fromJson(Map<String, dynamic> json) {
    return BoardState(
      health: HealthStatus.fromString(json['health'] as String),
      state: BoardStateStatus.fromString(json['state'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

/// 取引所の状態を表すenum
enum HealthStatus {
  NORMAL,
  BUSY,
  VERY_BUSY,
  SUPER_BUSY,
  STOP;

  factory HealthStatus.fromString(String value) {
    return HealthStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw ArgumentError('Invalid health status: $value'),
    );
  }
}

/// 取引所の状態を表すクラス
class Health {
  final HealthStatus status;

  Health({
    required this.status,
  });

  factory Health.fromJson(Map<String, dynamic> json) {
    return Health(
      status: HealthStatus.fromString(json['status'] as String),
    );
  }
}

class FundingRate{
  final double currentFundingRate;
  final DateTime nextFundingRateSettledate;

  FundingRate({
    required this.currentFundingRate,
    required this.nextFundingRateSettledate,
  });

  factory FundingRate.fromJson(Map<String, dynamic> json) {
    return FundingRate(
      currentFundingRate: json['current_funding_rate'].toDouble(),
      nextFundingRateSettledate: DateTime.parse(json['next_funding_rate_settledate'] as String),
    );
  }
}

/// チャットの履歴を表すクラス
class Chat {
  final String nickname;
  final String message;
  final DateTime date;

  Chat({
    required this.nickname,
    required this.message,
    required this.date,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      nickname: json['nickname'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class CorporateLeverage {
  final double currentMax;
  final DateTime currentStartDate;
  final double? nextMax;
  final DateTime? nextStartDate;

  CorporateLeverage({
    required this.currentMax,
    required this.currentStartDate,
    this.nextMax,
    this.nextStartDate,
  });

  factory CorporateLeverage.fromJson(Map<String, dynamic> json) {
    return CorporateLeverage(
      currentMax: json['current_max'].toDouble(),
      currentStartDate: DateTime.parse(json['current_startdate']),
      nextMax: json['next_max']?.toDouble(),
      nextStartDate: json['next_startdate'] != null 
        ? DateTime.parse(json['next_startdate'])
        : null,
    );
  }
}
