<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

[bitFlyer Lighting API](https://lightning.bitflyer.com/docs?lang=ja) Client for Dart

## Features

* Simple
* Light weight
* Minimum dependencies

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
// Public API
final client = BitflyerPublicApiClient();
final markets = await client.getMarkets();

// Private API
final client = BitflyerPrivateApiClient(
  apiKey: 'your_api_key',
  apiSecret: 'your_api_secret', 
);
final balance = await client.getBalance();
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
