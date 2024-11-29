class BitflyerApiException implements Exception {
  final int statusCode;
  final String body;

  BitflyerApiException({
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    return 'BitflyerApiException: $statusCode - $body';
  }
}
