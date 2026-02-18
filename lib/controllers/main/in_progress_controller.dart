import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class InProgressController extends GetxController {
  var selectedTab = 0.obs;
  final PageController pageController = PageController();

  void setTab(int index) {
    selectedTab.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    selectedTab.value = index;
  }
}