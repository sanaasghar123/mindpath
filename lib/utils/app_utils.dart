import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppUtils {
  static void hideKeyboard() {
    final context = Get.context;
    if (context == null) return;
    FocusScope.of(context).unfocus();
  }
}

