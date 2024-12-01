import 'dart:async';
import 'package:bitflyer_lighting_api/src/entities.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeApiClient {
  static const String _wsEndpoint =
      'wss://ws.lightstream.bitflyer.com/json-rpc';

  final WebSocketChannel _channel;
  late final Peer _client;
  late final StreamController<dynamic> _channelMessageController;
  final _subscribingChannels = <String, StreamController>{};

  RealtimeApiClient()
      : _channel = WebSocketChannel.connect(
          Uri.parse(_wsEndpoint),
        ) {
    ;
    _client = Peer(_channel.cast<String>());
    _client.listen();
    _channelMessageController = StreamController.broadcast();
    _client.registerMethod('channelMessage', (message) {
      _channelMessageController.add(message);
    });
  }

  Stream<Board> boardSnapshot({required String productCode}) {
    return _subscribe('lightning_board_snapshot_$productCode', Board.fromJson);
  }

  Stream<Board> board({required String productCode}) {
    return _subscribe('lightning_board_$productCode', Board.fromJson);
  }

  Stream<Ticker> ticker({required String productCode}) {
    return _subscribe('lightning_ticker_$productCode', Ticker.fromJson);
  }

  Stream<List<Execution>> executions({required String productCode}) {
    return _subscribe('lightning_executions_$productCode',
        (json) => [Execution.fromJson(json)]);
  }

  Stream<T> _subscribe<T>(
      String channelName, T Function(Map<String, dynamic>) fromJson) async* {
    await _channel.ready;
    assert(!_client.isClosed);
    final success = (await _client
        .sendRequest('subscribe', {'channel': channelName})) as bool?;
    if (!success!) {
      throw Exception('Failed to subscribe to channel: $channelName');
    }

    final controller = StreamController(
      onCancel: () {
        _unsubscribe(channelName);
      },
    );
    _subscribingChannels[channelName] = controller;

    unawaited(
      _channelMessageController.stream
          .where((message) {
            return message['channel'].asString == channelName;
          })
          .map((message) => message['message'].asMap)
          .pipe(controller.sink),
    );
    yield* controller.stream.cast<Map<String, dynamic>>().map(fromJson);
  }

  void _unsubscribe(String channelName) {
    _client.sendRequest('unsubscribe', {'channel': channelName});
    _subscribingChannels.remove(channelName);
  }

  Future<void> dispose() async {
    await Future.wait(
      _subscribingChannels.values.map((controller) => controller.close()),
    );
    await _client.close();
  }
}

class Execution {
  final int id;
  final String side;
  final double price;
  final double size;
  final DateTime execDate;

  Execution.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        side = json['side'],
        price = json['price'],
        size = json['size'],
        execDate = DateTime.parse(json['exec_date']);
}
