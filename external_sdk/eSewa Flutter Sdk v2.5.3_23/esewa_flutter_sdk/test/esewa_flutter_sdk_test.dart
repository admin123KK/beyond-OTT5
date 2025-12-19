import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/constants.dart';

void main() {
  const MethodChannel channel = MethodChannel(METHOD_CHANNEL_NAME);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
