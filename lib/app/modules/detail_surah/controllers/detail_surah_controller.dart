import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/db/bookmark.dart';
import 'package:quranapp/app/data/models/detailsurah.dart';
import 'package:quranapp/app/data/services/quran_cache_service.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:sqflite/sqlite_api.dart';

class DetailSurahController extends GetxController {
  final QuranCacheService _cacheService = Get.find<QuranCacheService>();

  AutoScrollController scrollC = AutoScrollController();
  final player = AudioPlayer();

  Verse? lastVerse;

  DatabaseManager database = DatabaseManager.instance;

  Future<void> addBookmark(
    bool lastRead,
    Detailsurah surah,
    Verse ayat,
    int indexAyat,
  ) async {
    final db = await database.db;
    bool flagExist = false;
    if (lastRead == true) {
      await db.delete("bookmark", where: "last_read = 1");
    } else {
      List checkData = await db.query(
        "bookmark",
        columns: [
          "surah",
          "number_surah",
          "ayat",
          "juz",
          "via",
          "index_ayat",
          "last_read",
        ],
        where:
            "surah = '${surah.name?.transliteration?.id!.replaceAll("'", "")}' and number_surah = ${surah.number!} and ayat = ${ayat.number?.inSurah} and juz = ${ayat.meta!.juz!} and via = 'surah' and index_ayat = $indexAyat and last_read = 0",
      );
      if (checkData.isNotEmpty) {
        flagExist = true;
      }
    }

    if (flagExist == false) {
      await db.insert("bookmark", {
        "surah": "${surah.name?.transliteration?.id!.replaceAll("'", "")}",
        "number_surah": surah.number!,
        "ayat": ayat.number?.inSurah ?? 0,
        "juz": ayat.meta?.juz ?? 0,
        "via": "surah",
        "index_ayat": indexAyat,
        "last_read": lastRead ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      Get.back();
      Get.snackbar(
        "Berhasil",
        "Berhasil menambahkan bookmark",
        colorText: appWhite,
      );
    } else {
      Get.back();
      Get.snackbar("Gagal", "Bookmark sudah ada", colorText: appWhite);
    }
  }

  Future<Detailsurah> getDetailSurah(String id) async {
    final detailSurah = await _cacheService.getDetailSurah(id);

    if (detailSurah != null) {
      return detailSurah;
    }

    throw Exception('Gagal memuat detail surah');
  }

  void stopAudio(Verse ayat) async {
    try {
      await player.stop();
      ayat.kondisiAudio = "stop";
      update();
    } on PlayerException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: e.message.toString(),
      );
    } on PlayerInterruptedException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Connection aborted: ${e.message}",
      );
    } catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat stop audio.",
      );
    }
  }

  void resumeAudio(Verse ayat) async {
    try {
      ayat.kondisiAudio = "playing";
      update();
      await player.play();
      ayat.kondisiAudio = "stop";
      update();
    } on PlayerException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: e.message.toString(),
      );
    } on PlayerInterruptedException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Connection aborted: ${e.message}",
      );
    } catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat resume audio.",
      );
    }
  }

  void pauseAudio(Verse ayat) async {
    try {
      await player.pause();
      ayat.kondisiAudio = "pause";
      update();
    } on PlayerException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: e.message.toString(),
      );
    } on PlayerInterruptedException catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Connection aborted: ${e.message}",
      );
    } catch (e) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat pause audio.",
      );
    }
  }

  void playAudio(Verse? ayat) async {
    if (ayat?.audio?.primary != null) {
      try {
        lastVerse ??= ayat;
        lastVerse!.kondisiAudio = "stop";
        lastVerse = ayat;
        lastVerse!.kondisiAudio = "stop";
        update();
        await player.stop();
        await player.setUrl(ayat!.audio!.primary!);
        ayat.kondisiAudio = "playing";
        update();
        await player.play();
        ayat.kondisiAudio = "stop";
        update();
        await player.stop();
      } on PlayerException catch (e) {
        Get.defaultDialog(
          title: "Terjadi kesalahan",
          middleText: e.message.toString(),
        );
      } on PlayerInterruptedException catch (e) {
        Get.defaultDialog(
          title: "Terjadi kesalahan",
          middleText: "Connection aborted: ${e.message}",
        );
      } catch (e) {
        Get.defaultDialog(
          title: "Terjadi kesalahan",
          middleText: "Tidak dapat memutar audio.",
        );
      }
    } else {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Audio tidak ada.",
      );
    }
  }

  @override
  void onClose() {
    player.stop();
    player.dispose();
    super.onClose();
  }
}
