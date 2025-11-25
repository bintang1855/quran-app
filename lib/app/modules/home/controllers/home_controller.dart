import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/db/bookmark.dart';
import 'package:quranapp/app/data/models/juz.dart';
import 'package:quranapp/app/data/models/surah.dart';
import 'package:quranapp/app/data/services/quran_cache_service.dart';

import 'package:sqflite/sqflite.dart';

class HomeController extends GetxController {
  final QuranCacheService _cacheService = Get.find<QuranCacheService>();

  List<Surah> allSurah = [];
  List<Juz> allJuz = [];
  RxBool isDark = false.obs;

  bool isSurahLoaded = false;
  bool isJuzLoaded = false;

  DatabaseManager database = DatabaseManager.instance;

  Future<Map<String, dynamic>?> getLastRead() async {
    Database db = await database.db;
    List<Map<String, dynamic>> dataLastRead = await db.query(
      "bookmark",
      where: "last_read = 1",
    );
    if (dataLastRead.length == 0) {
      return null;
    } else {
      return dataLastRead.first;
    }
  }

  void deleteBookmark(int id) async {
    Database db = await database.db;
    await db.delete("bookmark", where: "id = $id");
    update();
    Get.back();
    Get.snackbar(
      "Berhasil",
      "Telah berhasil menghapus bookmark",
      colorText: appWhite,
    );
  }

  Future<List<Map<String, dynamic>>> getBookmark() async {
    Database db = await database.db;
    List<Map<String, dynamic>> allbookmarks = await db.query(
      "bookmark",
      where: "last_read != 1",
      orderBy: "surah",
    );
    return allbookmarks;
  }

  void chageThemeMode() async {
    Get.isDarkMode ? Get.changeTheme(themeLight) : Get.changeTheme(themeDark);
    isDark.toggle();

    final box = GetStorage();

    if (Get.isDarkMode) {
      box.remove("themeDark");
    } else {
      box.write("themeDark", true);
    }
  }

  Future<List<Surah>> getAllSurah() async {
    if (isSurahLoaded && allSurah.isNotEmpty) {
      return allSurah;
    }

    allSurah = await _cacheService.getAllSurah();
    isSurahLoaded = allSurah.isNotEmpty;

    return allSurah;
  }

  Future<List<Juz>> getAllJuz() async {
    if (isJuzLoaded && allJuz.isNotEmpty) {
      return allJuz;
    }

    allJuz = await _cacheService.getAllJuz();
    isJuzLoaded = allJuz.isNotEmpty;

    return allJuz;
  }
}
