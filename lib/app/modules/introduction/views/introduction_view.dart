import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quranapp/app/routes/app_pages.dart';

import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({super.key});

  //const IntroductionView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Al-Quran Apps",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Sesibuk itukah kamu sampai belum membaca alquran?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 280,
              height: 280,
              child: Lottie.asset("assets/lotties/animasi-quran.json"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.HOME),
              child: Text("Mulai"),
            ),
          ],
        ),
      ),
    );
  }
}
