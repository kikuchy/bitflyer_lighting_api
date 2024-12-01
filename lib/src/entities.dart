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