import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/services/quran_cache_service.dart';

import 'app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  final box = GetStorage();

  Get.put(QuranCacheService());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: box.read("themeDark") == null ? themeLight : themeDark,
      title: "Application",
      initialRoute: Routes.INTRODUCTION,
      getPages: AppPages.routes,
    ),
  );
}
