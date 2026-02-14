import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/initial_screen_controller/init_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntroController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Slayder qismi
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: (index) => controller.currentPage.value = index,
            itemCount: controller.introData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Image.asset("${controller.introData[index]['icon']}"),
                    const SizedBox(height: 40),
                    Text(
                      controller.introData[index]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      controller.introData[index]['desc']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Pastki qism: Nuqtalar (Dots) va Tugma
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Nuqtalar (Indicators)
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.introData.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 5),
                      height: 8,
                      width: controller.currentPage.value == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 40),

                // Tugma
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => controller.next(),
                    child: Obx(() => Text(
                      controller.currentPage.value == controller.introData.length - 1
                          ? "Boshladik!"
                          : "Keyingisi",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}