import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranapp/app/data/models/juz.dart' as j;
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/db/bookmark.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

DatabaseManager database = DatabaseManager.instance;

class DetailJuzController extends GetxController {
  AutoScrollController scrollC = AutoScrollController();
  final player = AudioPlayer();
  var hasScrolledFromBookmark = false.obs;

  /// Simpan state audio per ayat (key = number.inQuran)
  /// nilai: 'stop' | 'playing' | 'pause'
  final audioState = <int, String>{}.obs;

  /// Ayat yang sedang aktif diputar (key = inQuran)
  int? lastKey;

  int _keyFrom(j.Verses ayat) => ayat.number?.inQuran ?? -1;

  String stateFor(j.Verses ayat) => audioState[_keyFrom(ayat)] ?? 'stop';

  Future<void> addBookmark(
    bool lastRead,
    j.Juz juz,
    j.Verses ayat,
    int index,
    String surahName,
    int numberSurah,
  ) async {
    try {
      final db = await database.db;
      bool flagExist = false;

      if (lastRead == true) {
        // hanya boleh satu last_read
        await db.delete("bookmark", where: "last_read = 1");
      } else {
        // cek duplikasi untuk via=juz
        final juzNum = juz.juz ?? 0;
        final inSurah = ayat.number?.inSurah ?? 0;

        final checkData = await db.query(
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
              "juz = ? AND number_surah = ? AND ayat = ? AND via = 'juz' AND index_ayat = ? AND last_read = 0",
          whereArgs: [juzNum, numberSurah, inSurah, index],
        );

        if (checkData.isNotEmpty) flagExist = true;
      }

      if (!flagExist) {
        await db.insert("bookmark", {
          "surah": surahName,
          "number_surah": numberSurah,
          "ayat": ayat.number?.inSurah ?? 0,
          "juz": juz.juz ?? 0,
          "via": "juz",
          "index_ayat": index,
          "last_read": lastRead ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        if (Get.isDialogOpen == true) Get.back();
        Get.snackbar(
          "Berhasil",
          "Berhasil menambahkan bookmark",
          colorText: appWhite,
        );
      } else {
        Get.snackbar("Gagal", "Bookmark sudah ada", colorText: appWhite);
      }

      // debug: lihat isi tabel
      final data = await db.query("bookmark");
      // ignore: avoid_print
      print(data);
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan: ${e.toString()}",
        colorText: appWhite,
      );
    }
  }

  Future<void> playAudio(j.Verses ayat) async {
    final url = ayat.audio?.primary;
    if (url == null || url.isEmpty) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Audio tidak ada.",
      );
      return;
    }

    try {
      // set semua terakhir ke stop
      if (lastKey != null) {
        audioState[lastKey!] = 'stop';
      }

      final key = _keyFrom(ayat);
      lastKey = key;

      // reset player
      await player.stop();
      await player.setUrl(url);

      // set state -> playing
      audioState[key] = 'playing';
      audioState.refresh();

      await player.play();

      // selesai -> stop
      audioState[key] = 'stop';
      audioState.refresh();
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
    } catch (_) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat memutar audio.",
      );
    }
  }

  Future<void> pauseAudio(j.Verses ayat) async {
    try {
      await player.pause();
      final key = _keyFrom(ayat);
      audioState[key] = 'pause';
      audioState.refresh();
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
    } catch (_) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat pause audio.",
      );
    }
  }

  Future<void> resumeAudio(j.Verses ayat) async {
    try {
      await player.play();
      final key = _keyFrom(ayat);
      audioState[key] = 'playing';
      audioState.refresh();
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
    } catch (_) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat resume audio.",
      );
    }
  }

  Future<void> stopAudio(j.Verses ayat) async {
    try {
      await player.stop();
      final key = _keyFrom(ayat);
      audioState[key] = 'stop';
      audioState.refresh();
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
    } catch (_) {
      Get.defaultDialog(
        title: "Terjadi kesalahan",
        middleText: "Tidak dapat stop audio.",
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Saat track selesai otomatis -> set stop
    player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed && lastKey != null) {
        audioState[lastKey!] = 'stop';
        audioState.refresh();
      }
    });
  }

  @override
  void onClose() {
    player.stop();
    player.dispose();
    super.onClose();
  }

  /// Index surah aktif di Juz (kalau masih mau pakai state ini)
  int index = 0;
}
