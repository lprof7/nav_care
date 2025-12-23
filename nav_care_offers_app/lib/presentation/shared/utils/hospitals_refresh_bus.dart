import 'package:flutter/foundation.dart';

class HospitalsRefreshBus {
  HospitalsRefreshBus._();

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  static int _pending = 0;

  static void notify() {
    _pending++;
    notifier.value++;
  }

  static bool consumePending() {
    if (_pending == 0) {
      return false;
    }
    _pending = 0;
    return true;
  }
}
