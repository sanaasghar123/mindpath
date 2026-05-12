import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/next/next_controller.dart';

class NextView extends GetView<NextController> {
  const NextView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('next_title'.tr),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'next_body'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
